require 'fattr'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

class Germinate::Insertion
  include Germinate::SharedStyleAttributes

  attr_reader :library
  attr_reader :selector

  def initialize(selector, library, template={})
    copy_shared_style_attributes_from(template)
    @selector = selector
    @library  = library
  end

  def resolve
    returning(library[selector]) do |hunk|
      hunk.copy_shared_style_attributes_from(self, false)
    end
  end
end
