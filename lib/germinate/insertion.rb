require 'fattr'
require 'ick'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

class Germinate::Insertion
  include Germinate::SharedStyleAttributes
  Ick::Returning.belongs_to(self)

  attr_reader :library
  attr_reader :selector

  fattr(:log) { Germinate.logger }

  def initialize(selector, library, template={})
    copy_shared_style_attributes_from(template)
    @selector = selector
    @library  = library
  end

  def to_s
    "Insertion[#{selector}]"
  end

  def resolve
    returning(library[selector, self, self]) do |hunk|
      log.debug "Resolved #{self} to #{hunk}"
    end
  end
end
