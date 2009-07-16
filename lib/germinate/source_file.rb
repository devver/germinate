require 'pathname'
require 'fattr'
require 'fileutils'

# SourcePath represents an article source file on disk.
class Germinate::SourceFile
  fattr :path
  fattr(:backup_path) { Pathname(path.basename.to_s + ".germ.bak") }
  fattr(:log) { Germinate.logger }

  def initialize(path)
    @path = Pathname(path)
  end

  def write!(lines)
    log.debug "Writing #{lines.size} lines to #{path}"
    file = File.new(path)
    flock_result = file.flock(File::LOCK_EX)
    if flock_result != 0
      raise "Unable to lock file #{path}"
    end
    FileUtils.cp(path, backup_path)
    unless path.read == backup_path.read
      raise "Error backup up #{path} to #{backup_path}"
    end
    begin
      path.open('w+') do |output|
        lines.each do |line|
          output.write(line)
        end
      end
    rescue Exception => error
      FileUtils.cp(backup_path, path)
      raise
    end
    log.info "Changes saved to #{path}."
    log.info "Previous state saved as #{backup_path}."
  ensure
    file.flock(File::LOCK_UN)
  end
end
