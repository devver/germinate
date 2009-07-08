# The Application ties all the other componts together.  It has public methods
# roughly corresponding commands that the 'germ' command-line tool supports.
class Germinate::Application
  attr_writer :formatter

  def format(source, output=$stdout, errors=$stderr)
    librarian = Germinate::Librarian.new
    reader    = Germinate::Reader.new(librarian)
    source.each_line do |line|
      reader << line
    end
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

  private
end
