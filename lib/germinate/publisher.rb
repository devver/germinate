require 'fattr'
require File.expand_path("publisher", File.dirname(__FILE__))

class Germinate::Publisher
  Fattr :identifier

  fattr :name
  fattr :librarian
  fattr :options

  @registered_publishers = {}

  def self.make(name, identifier, librarian, options)
    @registered_publishers.fetch(identifier).new(name, librarian, options)
  rescue IndexError => error
    raise error.exception("Unknown publisher type #{identifier.inspect}")
  end

  def self.register_publisher_type(identifier, klass)
    @registered_publishers[identifier] = klass
  end

  def self.identifier(*args)
    if args.empty?
      @identifier
    else
      id = args.first
      self.identifier = id
      Germinate::Publisher.register_publisher_type(id, self)
    end
  end

  def initialize(name, librarian, options)
    self.name      = name
    self.librarian = librarian
    self.options   = options
  end
end
