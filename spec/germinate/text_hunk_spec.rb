require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe TextHunk do
    before :each do
      @comment_prefix = ">>"
      @it = TextHunk.new(["foo", "bar"], :comment_prefix => @comment_prefix)
    end

    context "when visited by a formatter" do
      before :each do
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
  end
end
