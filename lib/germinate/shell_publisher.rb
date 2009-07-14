class Germinate::ShellPublisher < Germinate::Publisher
  identifier 'shell'

  def publish!(output, extra_options={})
    process = Germinate::Process.new(name, options.fetch(:command))
    processed = process.call(librarian["$SOURCE", "publish #{name} command"])
    processed.each do |line|
      output.print(line)
    end
  end
end
