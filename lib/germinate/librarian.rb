require 'orderedhash'
require 'fattr'
require 'ick'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

# The Librarian is responsible for organizing all the chunks of content derived
# from reading a source file and making them available for later re-assembly and
# formatting.
class Germinate::Librarian
  include Germinate::SharedStyleAttributes
  Ick::Returning.belongs_to(self)

  class VariableStore < OrderedHash
    def initialize(librarian)
      super()
      @librarian = librarian
    end

    def []=(key, value)
      if key?(key)
        variable = fetch(key)
        variable.replace(value.to_s)
        variable.update_source_line!(@librarian.comment_prefix)
      else
        variable = 
          case value
          when Germinate::Variable
            value
          else
            line_number = @librarian.lines.length + 1
            line        = ""
            Germinate::Variable.new(
              key, value, line, @librarian.source_path, line_number)
          end
        variable.update_source_line!(@librarian.comment_prefix)
        store(key, variable)
        @librarian.log.debug "Appending #{variable.line.inspect} to lines"
        @librarian.lines << variable.line
      end
      @librarian.updated = true
    end

  end
    
  attr_reader   :lines
  attr_reader   :text_lines
  attr_reader   :code_lines
  attr_reader   :front_matter_lines

  fattr         :source_path => nil

  fattr(:log) { Germinate.logger }
  fattr(:variables) { VariableStore.new(self) }
  fattr(:updated) { false }
  fattr(:source_file) { Germinate::SourceFile.new(source_path) }

  def initialize
    @lines              = []
    @text_lines         = []
    @code_lines         = []
    @front_matter_lines = []
    @sections           = OrderedHash.new do |hash, key| 
      hash[key] = Germinate::TextHunk.new([], shared_style_attributes)
    end
    @samples            = OrderedHash.new do |hash, key| 
      hash[key] = Germinate::CodeHunk.new([], shared_style_attributes)
    end
    @processes = {'_transform' => Germinate::TransformProcess.new}
    @publishers = OrderedHash.new
  end

  def add_front_matter!(line)
    add_line!(line)
    @front_matter_lines << line
  end

  def add_control!(line)
    add_line!(line)
  end

  def add_text!(section, line)
    add_line!(line)
    @text_lines << line
    @sections[section] << line
  end

  def add_code!(sample, line)
    add_line!(line)
    @code_lines << line
    @samples[sample] << line
  end

  def add_insertion!(section, selector, attributes)
    insertion = Germinate::Insertion.new(selector, self, attributes)
    @sections[section] << insertion
    @text_lines << insertion
  end

  def set_code_attributes!(sample, attributes)
    attributes.each_pair do |key, value| 
      @samples[sample].send(key, value) unless value.nil?
    end
  end

  def add_process!(process_name, command)
    @processes[process_name] = 
      Germinate::ShellProcess.new(process_name, command, variables)
  end

  def add_publisher!(name, identifier, options)
    @publishers[name] = Germinate::Publisher.make(name, identifier, self, options)
  end

  def store_changes!
    source_file.write!(lines)
  end

  def set_variable!(line, line_number, name, value)
    variables.store(name,Germinate::Variable.new(name, value, line, source_path, line_number))
  end

  def comment_prefix_known?
    !comment_prefix.nil?
  end

  def section(section_name)
    unless has_section?(section_name)
      raise IndexError, 
            "No text section named '#{section_name}'.  "\
            "Known sections: #{@sections.keys.join(', ')}"
    end
    Array(@sections[section_name])
  end

  def has_section?(section_name)
    @sections.key?(section_name)
  end

  def sample(sample_name)
    unless has_sample?(sample_name)
      raise IndexError,
            "No code sample named '#{sample_name}'.  "\
            "Known samples: #{@samples.keys.join(', ')}"
    end
    Array(@samples[sample_name])
  end

  # Fetch a process by name
  def process(process_name)
    @processes.fetch(process_name)
  rescue IndexError => error
    raise error.exception("Unknown process #{process_name.inspect}")
  end

  def process_names
    @processes.keys
  end

  def publisher_names
    @publishers.keys
  end

  # fetch a publisher by name
  def publisher(publisher_name)
    @publishers.fetch(publisher_name)
  rescue IndexError => error
    raise error.exception("Unknown publisher #{publisher_name.inspect}")
  end

  def has_sample?(sample_name)
    @samples.key?(sample_name)
  end

  # TODO Too big, refactor.
  def [](selector, origin="<Unknown>", template={})
    log.debug "Selecting #{selector}, from #{origin}"
    selector = case selector
               when Germinate::Selector then selector
               else Germinate::Selector.new(selector, "SECTION0", origin)
               end
    sample = 
      case selector.selector_type
      when :code then 
        sample(selector.key)
      when :special then 
        case selector.key
        when "SOURCE" 
          source_hunk = 
            if selector.whole?
              Germinate::FileHunk.new(lines, self)
            else
              Germinate::CodeHunk.new(lines, self)
            end
          source_hunk.disable_all_transforms!
          source_hunk
        when "CODE"   then Germinate::CodeHunk.new(code_lines, self)
        when "TEXT"   then Germinate::TextHunk.new(text_lines, self)
        else raise "Unknown special section '$#{selector.key}'"
        end
      else
        raise Exception, 
              "Unknown selector type #{selector.selector_type.inspect}"
      end

    sample.copy_shared_style_attributes_from(template)
    sample.origin.source_path ||= source_path
    sample.origin.selector    ||= selector

    sample = if selector.excerpt_output?
               excerpt(execute_pipeline(sample, selector.pipeline), selector)
             else
               execute_pipeline(excerpt(sample, selector), selector.pipeline)
             end
    sample
  end

  def section_names
    @sections.keys
  end

  def sample_names
    @samples.keys
  end

  # Given a list of process names or a '|'-delimited string, return a Pipeline
  # object representing a super-process of all the named processes chained
  # together.
  def make_pipeline(process_names_or_string)
    names = 
      if process_names_or_string.kind_of?(String)
        process_names_or_string.split("|")
      else
        process_names_or_string
      end
    processes = names.map{|n| process(n)}
    Germinate::Pipeline.new(processes)
  end

  private

  def excerpt(sample, selector)
    # TODO make excerpting just another TextTransform
    start_offset = start_offset(sample, selector)
    end_offset   = end_offset(sample, selector, start_offset)
    case selector.delimiter
    when '..' then sample[start_offset..end_offset]
    when '...' then sample[start_offset...end_offset]
    when ','   then sample[start_offset, selector.length]
    when nil   then sample.dup.replace([sample[start_offset]])
    else raise "Don't understand delimiter #{selector.delimiter.inspect}"
    end
  end

  def add_line!(line)
    line.chomp!
    line << "\n"
    @lines << line
  end

  def start_offset(hunk, selector)
    offset = selector.start_offset_for_slice
    case offset
    when Integer then offset
    when Regexp  then 
      returning(hunk.index_matching(offset)) do |index|
        if index.nil?
          raise "Cannot find line matching #{offset.inspect} in #{selector}"
        end
      end
    else 
      raise "Don't know how to use #{offset.inspect} as an offset"
    end
  end

  def end_offset(hunk, selector, start_offset)
    offset = selector.end_offset_for_slice
    case offset
    when Integer, nil then offset
    when Regexp then 
      returning(hunk.index_matching(offset, start_offset)) do |index|
        if index.nil?
          raise "Cannot find line matching #{offset.inspect} in #{selector}"
        end
      end
    else
      raise "Don't know how to use #{offset.inspect} as an offset"
    end
  end

  def execute_pipeline(hunk, names)
    make_pipeline(names).call(hunk)
  end
end
