require 'alter_ego'
require 'ick'
require 'forwardable'
require 'fattr'

# The Reader is responsible for reading a source file, breaking it down into
# into its constituent chunks of text, code, etc., assigning names to them, and
# filing them away in a Librarian.  It is also responsible for interpreting any
# special control lines found in the input document.
class Germinate::Reader
  include AlterEgo
  extend Forwardable
  Ick::Returning.belongs_to(self)

  CONTROL_PATTERN  = /^(\s*([^\s\\]+)?\s*):([A-Z0-9_]+):\s*(.*)?\s*$/

  attr_reader :librarian
  attr_reader :current_section
  attr_reader :section_count
  fattr(:log) { Germinate.logger }
  
  def_delegators :librarian, 
                 :comment_prefix, 
                 :comment_prefix=, 
                 :comment_prefix_known?
  
  state :initial, :default => true do
    handle :add_line!, :first_line!

    transition :to => :text, :on => :text!
    transition :to => :code, :on => :code!
    transition :to => :front_matter, :on => :front_matter!
  end

  state :front_matter do
    handle :add_line!, :add_front_matter!

    transition :to => :text, :on => :text!
    transition :to => :code, :on => :code!
  end

  state :code do
    handle :add_line!, :add_code!

    on_enter do
      if librarian.section_names.include?(sample_name)
        librarian.add_insertion!(sample_name, "@#{sample_name}", {})
      end
    end

    transition :to => :text, :on => :text!
    transition :to => :code, :on => :code!
    transition :to => :finished, :on => :finish!
  end
  
  state :text do
    handle :add_line!, :add_text!

    transition :to => :text, :on => :text!
    transition :to => :code, :on => :code!
    transition :to => :finished, :on => :finish!
  end

  state :finished do

  end

  def initialize(librarian, source_path=nil)
    @librarian       = librarian
    @section_count   = 0
    @current_section = "SECTION0"
    @line_number     = 0
    @source_path     = source_path ? Pathname(source_path) : nil
    librarian.source_path = @source_path
  end

  # Read a line
  def <<(line)
    @line_number += 1
    unless handle_control_line!(line)
      add_line!(unescape(line))
    end
  end

  def increment_section_count!
    self.section_count = section_count.succ
    self.current_section = automatic_section_name
  end

  private

  attr_writer :current_section
  attr_writer :section_count

  def first_line!(line)
    front_matter!
    add_front_matter!(line)
  end

  def add_front_matter!(line)
    librarian.add_front_matter!(line)
  end

  def add_text!(line)
    if uncommented?(line) && non_blank?(line)
      code!
      add_code!(line)
    else
      librarian.add_text!(current_section, line)
    end
  end

  def add_code!(line)
    librarian.add_code!(current_section, line)
  end

  def handle_control_line!(line)
    if match_data = CONTROL_PATTERN.match(line)
      comment_chars  = match_data[1]
      keyword        = match_data[3]
      argument_text  = match_data[4]
      arguments      = YAML.load("[ #{argument_text} ]")

      if comment_chars && !comment_chars.empty? && !comment_prefix_known?
        self.comment_prefix = comment_chars
      end
      case keyword
      when "TEXT"   then text_control_line!(*arguments)
      when "SAMPLE" then sample_control_line!(*arguments)
      when "CUT"    then cut_control_line!(*arguments)
      when "END"    then end_control_line!(*arguments)
      when "INSERT" then insert_control_line!(*arguments)
      when "BRACKET_CODE" then bracket_code_control_line!(*arguments)
      when "PROCESS" then process_control_line!(*arguments)
      when "PUBLISHER" then publisher_control_line!(*arguments)
      when "SET"    then set_control_line!(line, *arguments)
      else 
        log.warn "Ignoring unknown directive #{keyword} at line #{@line_number}"
      end
      librarian.add_control!(line)
      true
    else
      false
    end
  end
  
  def text_control_line!(section_name=nil)
    increment_section_count!
    self.current_section = section_name || automatic_section_name
    text!
  end

  def cut_control_line!
    increment_section_count!
    code!
  end

  def end_control_line!
    increment_section_count!
    code!
  end

  def sample_control_line!(sample_name=current_section, options={})
    increment_section_count!
    self.sample_name = sample_name || automatic_section_name
    librarian.set_code_attributes!(
      sample_name,
      options_to_style_attributes(options))
    code!
  end

  def bracket_code_control_line!(open_bracket=nil, close_bracket=nil)
    librarian.code_open_bracket = open_bracket
    librarian.code_close_bracket = close_bracket
  end

  def insert_control_line!(selector=nil, options={})
    librarian.add_insertion!(
      current_section, 
      Germinate::Selector.new(selector, current_section),
      options_to_style_attributes(options))
  end

  def process_control_line!(process_name, command)
    librarian.add_process!(process_name, command)
  end

  def publisher_control_line!(name, type, options={})
    librarian.add_publisher!(name, type, symbolize_keys(options))
  end

  def set_control_line!(line, name, value)
    librarian.set_variable!(line, @line_number, name, value)
  end

  def sample_name=(name)
    self.current_section = name
  end

  def sample_name
    self.current_section
  end

  def automatic_section_name
    "SECTION#{section_count}"
  end

  def parse_section_name(text)
    name = YAML.load(text)
    if name && !name.empty?
      name.to_s
    else
      nil
    end
  end
  
  def non_blank?(line)
    /^\s*$/ !~ line
  end

  def uncommented?(line)
    if comment_prefix_known?
      comment_pattern !~ line
    else
      false
    end
  end

  def comment_pattern
    /^#{Regexp.escape(comment_prefix.rstrip)}/
  end

  def unescape(line)
    line.sub(/\\(:[A-Z0-9_]+:)/, '\1') 
  end

  def options_to_style_attributes(options)
    returning({}) do |attributes|
      if options.key?("brackets")
        attributes[:code_open_bracket] = options.fetch("brackets").first
        attributes[:code_close_bracket] = options.fetch("brackets").last
      end
      if options["disable_transforms"]
        Germinate::TextTransforms.singleton_methods.each do |transform|
          attributes[transform.to_sym] = false
        end
      end
      attributes
    end
  end

  def symbolize_keys(hash)
    hash.inject({}){|result, (key, value)|
      new_key = case key
                when String then key.to_sym
                else key
                end
      new_value = case value
                  when Hash then symbolize_keys(value)
                  else value
                  end
      result[new_key] = new_value
      result
    }
  end
end
