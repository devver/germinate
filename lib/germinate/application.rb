require 'English'

# The Application ties all the other componts together.  It has public methods
# roughly corresponding commands that the 'germ' command-line tool supports.
class Germinate::Application
  attr_writer :formatter

  def initialize(output, errors)
    @output       = output
    @error_output = errors
    @log          = Germinate.logger
    @plugins      = []
  end

  # Search Rubygems for Germinate plugins and load them
  def load_plugins!
    $LOAD_PATH.each do |dir|
      plugin_init = Pathname(dir) + 'germinate_plugin_v0_init.rb'
      if plugin_init.readable?
        load_plugin!(plugin_init.to_s)
      end
    end
    Gem.find_files('germinate_plugin_v0_init').each do |file|
      load_plugin!(file)
    end
  end

  def format(source, path)
    librarian = load_librarian(source, path)
    publisher = Germinate::SimplePublisher.new("simple", librarian)
    publisher.publish!(@output)
  end

  def list(source, path, collection)
    librarian = load_librarian(source, path)
    case collection
    when "sections"
      @output.puts(librarian.section_names.join("\n"))
    when "samples"
      @output.puts(librarian.sample_names.join("\n"))
    when "processes"
      @output.puts(librarian.process_names.join("\n"))
    when "publishers"
      @output.puts(*librarian.publisher_names)
    when "all_publishers"
      Germinate::Publisher.registered_publishers.keys do |p|
        @output.puts(p)
      end
    when "variables"
      librarian.variables.each_pair do |name, value|
        @output.puts("%-20s %s" % [name, value.to_s])
      end
    when "plugins"
      @plugins.each do |plugin|
        puts(plugin)
      end
    else
      raise "I don't know how to list '#{collection}'"
    end
  end

  def show(source, path, item_type, item)
    librarian = load_librarian(source, path)
    case item_type
    when "section"
      @output.puts(librarian.section(item))
    when "sample"
      @output.puts(librarian.sample(item))
    when "process"
      @output.puts(librarian.process(item).command)
    when "publisher"
      @output.puts(librarian.publisher(item))
    else
      raise "I don't know how to show '#{item_type}'"
    end
  end

  def select(source, path, selector, options, origin="command line")
    librarian = load_librarian(source, path)
    @output.puts(*librarian[selector, origin, options])
  end

  def publish(source, path, publisher, options={})
    librarian = load_librarian(source, path)
    librarian.publisher(publisher).publish!(@output, options)
    librarian.store_changes!
  end

  def set(source, path, name, value)
    librarian = load_librarian(source, path)
    librarian.variables[name] = value
    librarian.store_changes!
  end

  private

  def load_librarian(source, path)
    librarian = Germinate::Librarian.new
    reader    = Germinate::Reader.new(librarian, path)
    source.each_line do |line|
      reader << line
    end
    librarian
  end

  def load_plugin!(file)
    unless @plugins.include?(file)
      @log.debug "Loading plugin: #{file}"
      Kernel.load(file)
      @plugins << File.dirname(file)
    end
  end
end
