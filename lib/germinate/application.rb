# The Application ties all the other componts together.  It has public methods
# roughly corresponding commands that the 'germ' command-line tool supports.
class Germinate::Application
  attr_writer :formatter

  def format(source, path, output=$stdout, errors=$stderr)
    librarian = load_librarian(source, path)
    editor    = Germinate::ArticleEditor.new(librarian)
    formatter = Germinate::ArticleFormatter.new(output)

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

  def list(source, path, things_to_list, output=$stdout)
    librarian = load_librarian(source, path)
    if things_to_list.include?(:sections)
      output.puts(librarian.section_names.join("\n"))
    end
    if things_to_list.include?(:samples)
      output.puts(librarian.sample_names.join("\n"))
    end
    if things_to_list.include?(:processes)
      output.puts(librarian.process_names.join("\n"))
    end
  end

  def show(source, path, selection, output=$stdout)
    librarian = load_librarian(source, path)
    selection.fetch(:section, []).each do |section|
      output.puts(*librarian.section(section))
    end
    selection.fetch(:sample, []).each do |sample|
      output.puts(*librarian.sample(sample))
    end
    selection.fetch(:process, []).each do |process|
      output.puts(*librarian.process(process).command)
    end
  end

  def select(source, path, selector, output=$stdout, origin="select command")
    librarian = load_librarian(source, path)
    output.puts(*librarian[selector, origin])
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
