require File.expand_path("insertion", File.dirname(__FILE__))

class Germinate::ImplicitInsertion < Germinate::Insertion
  def resolve
    super
  rescue IndexError
    Germinate::NullHunk.new
  end
end
