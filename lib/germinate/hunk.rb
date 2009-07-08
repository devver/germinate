require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

# A Hunk represents a chunk of content.  There are different types of Hunk, like
# Code or Text, which may be formatted differently by the Formatter.  At its
# most basic a Hunk is just a list of Strings, each one representing a single
# line.
class Germinate::Hunk < ::Array
  include Germinate::SharedStyleAttributes

  def initialize(contents=[], attributes = {})
    super(contents)
    attributes.each_pair do |key, value|
      send(key, value)
    end
  end

  # return a copy with leading and trailing whitespace lines removed
  def strip
    Germinate::TextTransforms.strip_blanks.call(self)
  end

  private

end

class Germinate::TextHunk < Germinate::Hunk
  def format_with(formatter)
    formatter.format_text!(self, comment_prefix)
  end
end

class Germinate::CodeHunk < Germinate::Hunk
  def format_with(formatter)
    formatter.format_code!(self, comment_prefix)
  end
end

