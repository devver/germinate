require 'orderedhash'
require 'fattr'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

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
    @sections           = OrderedHash.new do |hash, key| hash[key] = [] end
    @samples            = OrderedHash.new do |hash, key| hash[key] = [] end
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

  def comment_prefix_known?
    !comment_prefix.nil?
  end

  def section(section_name)
    Array(@sections[section_name])
  end

  def sample(sample_name)
    Array(@samples[sample_name])
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
