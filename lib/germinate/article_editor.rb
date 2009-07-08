# An Editor is responsible for selecting hunks of text from a Librarian and
# assembling them into a list for formatting.
class Germinate::ArticleEditor
  def initialize(librarian)
    @librarian = librarian
  end

  def each_hunk(&block)
    librarian.section_names.each do |section_name|
      yield Germinate::TextHunk.new(
        librarian.section(section_name), 
        librarian.comment_prefix)
      yield Germinate::CodeHunk.new(
        librarian.sample(section_name),
        librarian.comment_prefix)
    end
  end

  private

  attr_reader :librarian
end
