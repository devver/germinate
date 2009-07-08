require 'alter_ego'
require 'forwardable'

class Germinate::Reader
  include AlterEgo
  extend Forwardable

  CONTROL_KEYWORDS = %w[TEXT SAMPLE CUT END INSERT]
  CONTROL_PATTERN  = /^\s*(\S+)?\s*:(#{CONTROL_KEYWORDS.join('|')}):\s*(.*)?\s*$/

  attr_reader :librarian
  attr_reader :current_section
  attr_reader :section_count
  
  def_delegators :librarian, :comment_prefix, :comment_prefix=, :comment_prefix_known?
  
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

    transition :to => :text, :on => :text!
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

  def initialize(librarian)
    @librarian       = librarian
    @section_count   = 0
    @current_section = "SECTION0"
  end

  # Read a line
  def <<(line)
    unless handle_control_line!(line)
      add_line!(line)
    end
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

  def increment_section_count!
    self.section_count = section_count.succ
  end

  def handle_control_line!(line)
    if match_data = CONTROL_PATTERN.match(line)
      comment_chars  = match_data[1]
      keyword        = match_data[2]
      argument_text  = match_data[3]
      arguments      = YAML.load("[ #{argument_text} ]")
      if comment_chars && !comment_prefix_known?
        self.comment_prefix = comment_chars
      end
      case keyword
      when "TEXT"   then text_control_line!(*arguments)
      when "SAMPLE" then sample_control_line!(*arguments)
      when "CUT"    then cut_control_line!(*arguments)
      when "END"    then end_control_line!(*arguments)
      when "INSERT" then insert_control_line!(*arguments)
      else raise "Unknown keyword '#{keyword}'"
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

  def sample_control_line!(sample_name=nil, options={})
    increment_section_count!
    self.sample_name = sample_name || automatic_section_name
    code!
  end

  def sample_name=(name)
    self.current_section = name
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
    /^\s*(#{comment_prefix})/
  end
end
