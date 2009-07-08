require 'ick'
require 'fattr'

class Germinate::ArticleFormatter
  Ick::Returning.belongs_to self

  fattr :comment_prefix
  fattr :join_lines             => true
  fattr :strip_blanks           => true
  fattr :rstrip_newlines        => true
  fattr :uncomment              => true
  fattr :rstrip_lines           => true

  def initialize(output_stream=$stdout)
    @output_stream  = output_stream
    @first_output   = true
  end

  def start!
  end

  def finish!
  end

  def format!(hunk)
    @output_stream.puts unless first_output?
    hunk.format_with(self)
    @first_output = false if first_output?
  end

  def format_text!(hunk, comment_prefix=nil)
    text_transforms.inject(hunk) do |hunk, transform|
      transform.call(hunk)
    end.each do |line|
      @output_stream.puts(line)
    end
  end

  def format_code!(hunk, comment_prefix=nil)
    code_transforms.inject(hunk) do |hunk, transform|
      transform.call(hunk)
    end.each do |line|
      @output_stream.puts(line)
    end
  end

  private

  def first_output?
    @first_output
  end

  def text_transforms
    returning([]) do |transforms|
      transforms << Germinate::TextTransforms.strip_blanks if strip_blanks?
      if uncomment?
        transforms << Germinate::TextTransforms.uncomment(comment_prefix) 
      end
      transforms << Germinate::TextTransforms.join_lines if join_lines?
      transforms << Germinate::TextTransforms.rstrip_lines if rstrip_lines?
    end
  end

  def code_transforms
    returning([]) do |transforms|
      transforms << Germinate::TextTransforms.strip_blanks if strip_blanks?
      transforms << Germinate::TextTransforms.rstrip_lines if rstrip_lines?
    end
  end
end
