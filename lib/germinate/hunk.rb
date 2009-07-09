require 'ick'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

# A Hunk represents a chunk of content.  There are different types of Hunk, like
# Code or Text, which may be formatted differently by the Formatter.  At its
# most basic a Hunk is just a list of Strings, each one representing a single
# line.
class Germinate::Hunk < ::Array
  include Germinate::SharedStyleAttributes
  Ick::Returning.belongs_to(self)

  def initialize(contents=[], attributes = {})
    super(contents)
    attributes.each_pair do |key, value|
      send(key, value)
    end
  end

  def initialize_copy(from)
    super
    Germinate::SharedStyleAttributes.fattrs.each do |key|
      send(key, from.send(key))
    end
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

class Germinate::TextHunk < Germinate::Hunk
  def format_with(formatter)
    super(formatter) do |formatter|
      formatter.format_text!(self, comment_prefix)
    end
  end
end

class Germinate::CodeHunk < Germinate::Hunk
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

