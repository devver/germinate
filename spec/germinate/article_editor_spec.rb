require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe ArticleEditor do
    before :each do
      @librarian = Librarian.new
      @it = ArticleEditor.new(@librarian)
    end

    context "with an empty library" do
      it "should yield no hunks" do
        collect_hunks.should be_empty
      end
    end

    context "with a text section and matching code section" do
      before :each do
        @librarian.add_text!("SECTION1", "this is the text")
        @librarian.add_text!("SECTION1", "text line 2")
        @librarian.add_code!("SECTION1", "this is the code")
        @librarian.add_code!("SECTION1", "code line 2")
      end

      it "should yield text and code in order" do
        collect_hunks.should == [
          ["this is the text", "text line 2"],
          ["this is the code", "code line 2"]
        ]
      end

      it "should yield text section as TextHunk" do
        collect_hunks[0].should be_a_kind_of(TextHunk)
      end

      it "should yield code section as CodeHunk" do
        collect_hunks[1].should be_a_kind_of(CodeHunk)
      end

      it "should set no comment prefix on hunks" do
        collect_hunks[0].comment_prefix.should be_nil
        collect_hunks[1].comment_prefix.should be_nil
      end
    end

    context "with a text section and mis-matched code section" do
      before :each do
        @librarian.add_text!("SECTION1", "this is the text")
        @librarian.add_text!("SECTION1", "text line 2")
        @librarian.add_code!("SECTION2", "this is the code")
        @librarian.add_code!("SECTION2", "code line 2")
      end

      it "should yield just the text" do
        collect_hunks.should == [
          ["this is the text", "text line 2"],
          []
        ]
      end
    end

    context "with a known comment prefix" do
      before :each do
        @librarian.comment_prefix = ";;"
        @librarian.add_text!("SECTION1", "this is the text")
        @librarian.add_code!("SECTION1", "this is the code")
      end

    end

    def collect_hunks
      hunks = []
      @it.each_hunk do |hunk|
        hunks << hunk
      end
      hunks
    end
  end
end
