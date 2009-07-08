require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe CodeHunk do
    before :each do
      @it = CodeHunk.new(["foo", "bar"])
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
  end
end
