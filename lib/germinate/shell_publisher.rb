class Germinate::ShellPublisher < Germinate::Publisher
  identifier 'shell'

  def initialize(name, librarian, options)
    @command = options.delete(:command) do
      raise ArgumentError, 
            "A 'command' option must be supplied for publisher type 'shell'"
    end
    super
  end

  def publish!(output, extra_options={})
    process = Germinate::ShellProcess.new(name, @command, librarian.variables)
    processed = process.call(input)
    processed.each do |line|
      output.print(line)
    end
  end
end
