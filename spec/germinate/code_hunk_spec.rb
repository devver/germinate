require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe CodeHunk do
    before :each do
      @it = CodeHunk.new(["foo", "bar"])
    end

    it "should disable line joining" do
      @it.should_not be_join_lines
    end

    it "should enable blank stripping" do
      @it.should be_strip_blanks
    end

    it "should disable comment erasure" do
      @it.should_not be_erase_comments
    end

    it "should disable uncommenting" do
      @it.should_not be_uncomment
    end

    it "should disable stripping right-side whitespace" do
      @it.should_not be_rstrip_lines
    end

    it "should enable bracketing" do
      @it.should be_bracket
    end
      
    it "should enable pipeline processing" do
      @it.should be_pipeline
    end

    context "when visited by a formatter" do
      before :each do
        @formatter = stub("Formatter")
      end

      it "should call #formate_code! for self" do
        @formatter.should_receive(:format_code!).with(@it, anything)
        @it.format_with(@formatter)
      end
    end

    describe "with a nested hunk" do
      before :each do
        @formatter = stub("Formatter")
        @comment_prefix = ">>"
        @nested_hunk = stub("Nested Hunk", :empty? => false)
        contents = [
          "foo",
          "bar",
          @nested_hunk,
          "baz"
        ]
        @it = CodeHunk.new(contents, 
          :comment_prefix => @comment_prefix)
      end

      it "should pass formatter on to nested hunks" do
        @formatter.should_receive(:format_code!).with(["foo", "bar"], ">>").ordered
        @nested_hunk.should_receive(:format_with).with(@formatter).ordered
        @formatter.should_receive(:format_code!).with(["baz"], ">>").ordered
        @it.format_with(@formatter)
      end
    end

  end
end
