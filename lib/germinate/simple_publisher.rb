class Germinate::SimplePublisher < Germinate::Publisher
  def publish!(output, extra_options={})
    input.each do |line|
      output.puts(line)
    end
  end
end
