# An Editor is responsible for selecting hunks of text from a Librarian and
# assembling them into a list for formatting.
class Germinate::ArticleEditor
  def initialize(librarian)
    @librarian = librarian
  end

  def each_hunk(&block)
    librarian.section_names.each do |section_name|
      yield librarian.section(section_name)
      yield librarian.sample(section_name)
    end
  end

  private

  attr_reader :librarian
end
