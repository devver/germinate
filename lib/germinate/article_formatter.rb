class Germinate::ArticleFormatter
  attr_accessor :comment_prefix

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
    hunk.strip.map{|l| uncomment(l, comment_prefix)}.each do |line|
      @output_stream.puts(line.rstrip)
    end
  end

  def format_code!(hunk, comment_prefix=nil)
    hunk.strip.each do |line|
      @output_stream.puts(line.rstrip)
    end
  end

  private

  def first_output?
    @first_output
  end

  def uncomment(line, comment_prefix=nil)
    if comment_prefix
      if match_data = /^\s*(#{comment_prefix})+\s*/.match(line)
        offset = match_data.begin(0)
        length = match_data[0].length
        line_copy = line.dup
        line_copy[offset, length] = (" " * length)
        line_copy
      else
        line
      end
    else
      line
    end
  end
end
