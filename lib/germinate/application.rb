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
    formatter.comment_prefix = librarian.comment_prefix
    formatter.start!
    editor.each_hunk do |hunk|
      formatter.format!(hunk)
    end
    formatter.finish!
  end

  private
end
