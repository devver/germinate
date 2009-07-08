require File.expand_path(
  File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Hunk do
    context "given some leading and trailing whitespace" do
      before :each do
        @it = Hunk.new(
          [
            "  \n ", "\t\t\t", "the good stuff", 
            "  \n", "more good stuff\n", "\n"
          ])
      end

      it "should be able to strip the whitespace" do
        @it.strip.should == ["the good stuff", "  \n", "more good stuff\n"]
      end
    end
  end

end
