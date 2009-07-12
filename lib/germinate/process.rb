require 'tempfile'
require 'fattr'
require 'English'
require 'main'

# A Process represents an external command which can be used to process a Hunk
# of text.
class Germinate::Process
  attr_reader :name
  attr_reader :command

  fattr(:log) { Germinate.logger }

  def initialize(name, command)
    @name    = name
    @command = command
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
    log.debug "Running command '#{command}'"
    IO.popen(command, mode, &block)
    status = $CHILD_STATUS
    unless status.success?
      log.warn "Command '#{command}' exited with status #{status}"
    end
  end
end
