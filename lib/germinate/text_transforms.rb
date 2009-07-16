# A library of text transforms.  Each public module method returns a callable
# object which can be used to transform an array of lines.
module Germinate::TextTransforms

  IDENTITY_TRANSFORM = lambda {|hunk| hunk}
  def self.join_lines
    lambda { |hunk|
      paragraphs = hunk.inject([[]]) { |result, line|
        case line
        when /\S/
          result.last << line.strip
        else
          result << [line]
          result << []
        end
        result
      }
      paragraphs.delete_if{|p| p.empty?}
      hunk.dup.replace(paragraphs.map {|paragraph|
        paragraph.join(" ")
      })
    }
  end

  def self.strip_blanks
    lambda { |hunk|
      result = hunk.dup
      result.shift until result.first =~ /\S/ || result.empty?
      result.pop until result.last =~ /\S/ || result.empty?
      result
    }
  end

  def self.erase_comments(comment_prefix="")
    lambda { |hunk|
      hunk.dup.map! do |line|
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
    }
  end

  def self.uncomment(comment_prefix="")
    lambda { |hunk|
      hunk.dup.map! do |line|
        if comment_prefix
          line.sub(/^#{Regexp.escape(comment_prefix.rstrip)}\s*/,"")
        else
          line
        end
      end
    }
  end

  def self.rstrip_lines
    lambda { |hunk|
      hunk.dup.map!{|line| line.to_s.rstrip}
    }
  end

  def self.bracket(open_bracket=nil, close_bracket=nil)
    lambda { |hunk|
      result = hunk.dup
      result.clear
      result << (open_bracket || hunk.code_open_bracket)
      result.push(*Array(hunk))
      result << (close_bracket || hunk.code_close_bracket)
      result.compact!
      result
    }
  end

  def self.pipeline(pipeline=nil)
    lambda do |hunk|
      pipeline ||= hunk.pipeline
      pipeline.call(hunk)
    end
  end
end
