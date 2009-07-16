require 'English'

# The Application ties all the other componts together.  It has public methods
# roughly corresponding commands that the 'germ' command-line tool supports.
class Germinate::Application
  attr_writer :formatter

  def initialize(output, errors)
    @output       = output
    @error_output = errors
  end

  # Search Rubygems for Germinate plugins and load them
  def load_plugins!
    Gem.find_files('germinate_plugin_v0_init').each do |file|
      Kernel.load(file)
    end
    $LOAD_PATH.each do |dir|
      plugin_init = Pathname(dir) + 'germinate_plugin_v0_init.rb'
      if plugin_init.readable?
        Kernel.load(plugin_init)
      end
    end
  end

  def format(source, path)
    librarian = load_librarian(source, path)
    editor    = Germinate::ArticleEditor.new(librarian)
    formatter = Germinate::ArticleFormatter.new(@output)

    Germinate::SharedStyleAttributes.fattrs.each do 
      |style_attribute|
      formatter.send(style_attribute, librarian.send(style_attribute))
    end
    formatter.start!
    editor.each_hunk do |hunk|
      formatter.format!(hunk)
    end
    formatter.finish!
  end

  def list(source, path, things_to_list)
    librarian = load_librarian(source, path)
    if things_to_list.include?(:sections)
      @output.puts(librarian.section_names.join("\n"))
    end
    if things_to_list.include?(:samples)
      @output.puts(librarian.sample_names.join("\n"))
    end
    if things_to_list.include?(:processes)
      @output.puts(librarian.process_names.join("\n"))
    end
    if things_to_list.include?(:publishers)
      @output.puts(*librarian.publisher_names)
    end
    if things_to_list.include?(:variables)
      librarian.variables.each_pair do |name, value|
        @output.puts("%-20s %s" % [name, value.to_s])
      end
    end
  end

  def show(source, path, selection)
    librarian = load_librarian(source, path)
    selection.fetch(:section, []).each do |section|
      @output.puts(*librarian.section(section))
    end
    selection.fetch(:sample, []).each do |sample|
      @output.puts(*librarian.sample(sample))
    end
    selection.fetch(:process, []).each do |process|
      @output.puts(*librarian.process(process).command)
    end
    selection.fetch(:publisher, []).each do |publisher|
      @output.puts(*librarian.publisher(publisher))
    end
  end

  def select(source, path, selector, origin="select command")
    librarian = load_librarian(source, path)
    @output.puts(*librarian[selector, origin])
  end

  def publish(source, path, publisher, options={})
    librarian = load_librarian(source, path)
    librarian.publisher(publisher).publish!(@output, options)
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
end
