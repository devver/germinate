require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe TextHunk do
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
