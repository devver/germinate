# The Application ties all the other componts together.  It has public methods
# roughly corresponding commands that the 'germ' command-line tool supports.
class Germinate::Application
  attr_writer :formatter

  def format(source, output=$stdout, errors=$stderr)
    librarian = load_librarian(source)
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

  def list(source, things_to_list, output=$stdout)
    librarian = load_librarian(source)
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

  def show(source, selection, output=$stdout)
    librarian = load_librarian(source)
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

  def select(source, selector, output=$stdout)
    librarian = load_librarian(source)
    output.puts(*librarian[selector])
  end
  private

  def load_librarian(source)
    librarian = Germinate::Librarian.new
    reader    = Germinate::Reader.new(librarian)
    source.each_line do |line|
      reader << line
    end
    librarian
  end
end
