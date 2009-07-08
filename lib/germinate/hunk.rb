class Germinate::Hunk < ::Array
  attr_accessor :comment_prefix

  def initialize(contents, comment_prefix=nil)
    super(contents)
    self.comment_prefix = comment_prefix
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

