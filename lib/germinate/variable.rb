class Germinate::Variable < String
  attr_reader   :name
  attr_reader   :origin
  attr_reader   :line

  def initialize(name, value, line, source_path, line_number)
    super(value.to_s)
    @name = name
    @line = line
    @origin = Germinate::Origin.new(source_path, line_number)
  end

  def update_source_line!(comment_prefix)
    line.replace(make_control_line(comment_prefix))
  end

  private
  
  def make_control_line(comment_prefix)
    "#{comment_prefix}:SET: '#{name}', '#{self}'\n"
  end

end
