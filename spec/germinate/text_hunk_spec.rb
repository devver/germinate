require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe TextHunk do
    before :each do
      @it = TextHunk.new(["line 1", "line 2"])
    end

    it "should enable insertion expansion" do
      @it.should be_expand_insertions
    end

    it "should enable line joining" do
      @it.should be_join_lines
    end

    it "should enable blank stripping" do
      @it.should be_strip_blanks
    end

    it "should disable comment erasure" do
      @it.should_not be_erase_comments
    end

    it "should enable uncommenting" do
      @it.should be_uncomment
    end

    it "should enable stripping right-side whitespace" do
      @it.should be_rstrip_lines
    end

    it "should disable bracketing" do
      @it.should_not be_bracket
    end
      
    it "should enable pipeline processing" do
      @it.should be_pipeline
    end

    it "should enable insertion resolution" do
      @it.should be_expand_insertions
    end

    it "should enable flattening nested hunks" do
      @it.should be_flatten_nested
    end


    context "when visited by a formatter" do
      before :each do
        @comment_prefix = ">>"
        contents = [
          "foo",
          "bar"
        ]
        @it = TextHunk.new(contents, 
          :comment_prefix => @comment_prefix)
        @formatter = stub("Formatter")
      end

      it "should call #format_text! on self" do
        @formatter.should_receive(:format_text!).with(@it, anything)
        @it.format_with(@formatter)
      end

      it "should provide the comment prefix to the formatter" do
        @formatter.should_receive(:format_text!).with(anything, @comment_prefix)
        @it.format_with(@formatter)
      end

    end

    describe "with a nested hunk" do
      before :each do
        @comment_prefix = ">>"
        @formatter = stub("Formatter")
        @nested_hunk = stub("Nested Hunk", :empty? => false)
        contents = [
          "foo",
          "bar",
          @nested_hunk,
          "baz"
        ]
        @it = TextHunk.new(contents, 
          :comment_prefix => @comment_prefix)
      end

      it "should pass formatter on to nested hunks" do
        @formatter.should_receive(:format_text!).with(["foo", "bar"], ">>").ordered
        @nested_hunk.should_receive(:format_with).with(@formatter).ordered
        @formatter.should_receive(:format_text!).with(["baz"], ">>").ordered
        @it.format_with(@formatter)
      end
    end
  end
end
