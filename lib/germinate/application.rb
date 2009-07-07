class Germinate::Application
  attr_writer :formatter

  def format(source, output=$stdout, errors=$stderr)
    formatter = make_formatter(output)
    formatter.start!
    source.each_line do |input_line|
      formatter.add_line!(input_line)
    end
    formatter.finish!
  end

  private

  def make_formatter(output)
    @formatter || Germinate::Formatter.new(output)
  end
end
