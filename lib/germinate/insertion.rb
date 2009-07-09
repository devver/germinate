require 'fattr'

class Germinate::Insertion
  attr_reader :library
  attr_reader :selector

  def initialize(selector, library)
    @selector = selector
    @library  = library
  end

  def resolve
    library[selector]
  end
end
