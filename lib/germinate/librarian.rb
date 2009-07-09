require 'orderedhash'
require 'fattr'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

# The Librarian is responsible for organizing all the chunks of content derived
# from reading a source file and making them available for later re-assembly and
# formatting.
class Germinate::Librarian
  include Germinate::SharedStyleAttributes

  attr_reader   :lines
  attr_reader   :text_lines
  attr_reader   :code_lines
  attr_reader   :front_matter_lines

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

  def add_insertion!(section, selector)
    insertion = Germinate::Insertion.new(selector, self)
    @sections[section] << insertion
  end

  def set_code_attributes!(sample, attributes)
    attributes.each_pair do |key, value| 
      @samples[sample].send(key, value) unless value.nil?
    end
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

  def has_sample?(sample_name)
    @samples.key?(sample_name)
  end

  def [](selector)
    selector = case selector
               when Germinate::Selector then selector
               else Germinate::Selector.new(selector, "SECTION0")
               end
    sample = 
      case selector.selector_type
      when :code then sample(selector.key)
      when :special then 
        case selector.key
        when "SOURCE" then Germinate::CodeHunk.new(lines, self)
        when "CODE"   then Germinate::CodeHunk.new(code_lines, self)
        when "TEXT"   then Germinate::CodeHunk.new(text_lines, self)
        else raise "Unknown special section '$#{selector.key}'"
        end
      else
        raise Exception, 
              "Unknown selector type #{selector.selector_type.inspect}"
      end
    sample[selector.start_offset_for_slice..selector.end_offset_for_slice]
  end

  def section_names
    @sections.keys
  end

  def sample_names
    @samples.keys
  end

  private

  def add_line!(line)
    @lines << line
  end
end
