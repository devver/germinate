require 'tempfile'
require 'fattr'
require 'English'
require 'main'

# A Process represents an external command which can be used to process a Hunk
# of text.
class Germinate::Process
  attr_reader :name
  attr_reader :command
  attr_reader :variables

  fattr(:log) { Germinate.logger }

  def initialize(name, command, variables={})
    @name      = name
    @command   = command
    @variables = variables
  end

  def call(input)
    if pipe?
      call_command_in_pipe(input)
    elsif input.whole_file?
      call_command_on_source_file(input)
    else
      call_command_on_temp_file(input)
    end
  end

  private

  def call_command_in_pipe(input)
    log_popen(command, 'r+') do |process|
      input.each do |line|
        process << line
      end
      process.close_write
      return input.class.new(process.readlines, input)
    end
  end

  def call_command_on_temp_file(input)
    Tempfile.open("germinate_hunk") do |file|
      input.each do |line|
        file << line
      end
      file.close
      log_popen(substitute_filename(command, file.path), 'r') do |process|
        return input.class.new(process.readlines, input)
      end
    end
  end

  def call_command_on_source_file(input)
    log_popen(substitute_filename(command, input.source_path), 'r') do |process|
      return Germinate::CodeHunk.new(process.readlines, input)
    end
  end

  def pipe?
    !command.include?("%f")
  end

  def substitute_filename(command, filename)
    command.gsub("%f", "'#{filename}'")
  end

  def log_popen(command, mode, &block)
    log.debug "Running command `#{command}`"
    with_environment_variables(@variables) do
      IO.popen(command, mode, &block)
    end
    status = $CHILD_STATUS
    unless status.nil? ||status.success? 
      log.warn "Command '#{command}' exited with status #{status}"
    end
  end

  def with_environment_variables(variables)
    old_values = variables.inject({}) do |original, (name, value)| 
      original[name.to_s] = ENV[name.to_s]
      ENV[name.to_s] = value.to_s
      original
    end
    yield
  ensure
    old_values.each_pair do |name, value|
      if value.nil? then ENV.delete(name)
      else ENV[name] = value
      end
    end
  end
end
