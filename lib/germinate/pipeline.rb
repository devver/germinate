class Germinate::Pipeline
  attr_reader :processes

  def initialize(processes)
    @processes = processes
  end

  def call(input)
    @processes.inject(input) { |output, process|
      process.call(output)
    }
  end
end
