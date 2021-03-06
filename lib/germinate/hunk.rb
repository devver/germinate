require 'pathname'
require 'ick'
require 'fattr'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

# A Hunk represents a chunk of content.  There are different types of Hunk, like
# Code or Text, which may be formatted differently by the Formatter.  At its
# most basic a Hunk is just a list of Strings, each one representing a single
# line.
class Germinate::Hunk < ::Array
  include Germinate::SharedStyleAttributes
  Ick::Returning.belongs_to(self)

  def initialize(contents=[], template = {})
    super(contents)
    copy_shared_style_attributes_from(template)
  end

  def to_s
    "#{self.class.name}[#{origin}](#{self.size} lines)"
  end

  # return a copy with leading and trailing whitespace lines removed
  def strip
    Germinate::TextTransforms.strip_blanks.call(self)
  end

  def resolve_insertions
    dup.map!{ |line_or_insertion|
      if line_or_insertion.respond_to?(:resolve)
        line_or_insertion.resolve
      else
        line_or_insertion
      end
    }
  end

  def format_with(formatter)
    raise "Unresolved hunk cannot be formatted!" unless resolved?
    if nested_hunks?
      group_hunks.each do |hunk|
        hunk.format_with(formatter)
      end
    else
      yield formatter
    end
  end

  def inspect
    attrs = Germinate::SharedStyleAttributes.fattrs.inject({}) {|attrs, key|
      attrs[key] = send(key)
      attrs
    }
    "#{self.class}:#{super}:#{attrs.inspect}:#{object_id}"
  end

  def [](*args)
    returning(super) do |slice|
      if slice.kind_of?(Germinate::Hunk)
        slice.copy_shared_style_attributes_from(self)
      end
    end
  end

  def slice(*args)
    returning(super) do |slice|
      if slice.kind_of?(Germinate::Hunk)
        slice.copy_shared_style_attributes_from(self)
      end
    end
  end

  def index_matching(pattern, start_index=0)
    (start_index...(size)).each { |i|
      return i if pattern === self[i]
    }
    nil
  end

  def whole_file?
    false
  end

  private

  def resolved?
    !unresolved_hunks?
  end

  def unresolved_hunks?
    any?{|line| line.respond_to?(:resolve)}
  end

  def nested?
    unresolved_hunks? || nested_hunks?
  end
  
  def nested_hunks?
    any?{|line| line.respond_to?(:format_with)}
  end

  def group_hunks
    return self unless nested?
    groups = inject([empty_dup]) { |hunks, line_or_hunk|
      if line_or_hunk.respond_to?(:format_with)
        hunks << line_or_hunk
        hunks << empty_dup
      else
        hunks.last << line_or_hunk
      end
      hunks
    }
    groups.delete_if{|g| g.empty?}
    groups
  end

  # An empty duplicate retains metadata but has no lines
  def empty_dup
    returning(dup) do |duplicate|
      duplicate.clear
    end
  end

end

# Represents a hunk of article text
class Germinate::TextHunk < Germinate::Hunk
  def initialize(contents = [], template = {})
    self.join_lines        = true
    self.strip_blanks      = true
    self.rstrip_lines      = true
    self.uncomment         = true
    self.expand_insertions = true
    self.flatten_nested    = true
    super
  end

  def format_with(formatter)
    super(formatter) do |formatter|
      formatter.format_text!(self, comment_prefix)
    end
  end
end

# Represents a hunk of source code
class Germinate::CodeHunk < Germinate::Hunk
  def initialize(contents = [], template = {})
    self.strip_blanks = true
    self.bracket      = true
    super
  end

  def code_open_bracket=(new_value)
    super
  end

  def code_close_bracket=(new_value)
    super
  end


  def format_with(formatter)
    super(formatter) do |formatter|
      formatter.format_code!(self, comment_prefix)
    end
  end
end

class Germinate::NullHunk < Germinate::Hunk
end

# Represents a the entire text of a file on disk
class Germinate::FileHunk < Germinate::CodeHunk
  def initialize(lines, template)
    super(lines, template)
    raise ArgumentError, "Path required" if source_path.nil?
  end

  def whole_file?
    true
  end
end

