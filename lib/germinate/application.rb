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

    %w[comment_prefix code_open_bracket code_close_bracket].each do 
      |style_attribute|
      formatter.send("#{style_attribute}=", librarian.send(style_attribute))
    end
    formatter.start!
    editor.each_hunk do |hunk|
      formatter.format!(hunk)
    end
    formatter.finish!
  end

  private
end
