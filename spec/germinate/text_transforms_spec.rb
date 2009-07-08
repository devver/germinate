require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe TextTransforms do
    describe "join_lines" do
      before :each do
        @it = TextTransforms.join_lines
      end

      context "given some line-broken paragraphs" do 
        before :each do 
          @input = [
            "p1l1\n",
            "p1l2\n",
            "\n",
            "p2l1",
            "p2l2"
          ]
        end

        it "should collapse the paragraphs into single lines" do
          @it.call(@input).should == [
            "p1l1 p1l2",
            "\n",
            "p2l1 p2l2"
          ]
        end
      end
    end

    describe "uncomment" do
      context "with no comment prefix" do
        before :each do
          @it = TextTransforms.uncomment(nil)
        end

        it "should do nothing" do
          @it.call(["# foo", " bar"]).should == ["# foo", " bar"]
        end
      end

      context "with a comment prefix of '# '" do
        before :each do
          @it = TextTransforms.uncomment('# ')
        end

        it "should strip matching comment prefixes" do
          @it.call(["# foo", " bar"]).should == ["foo", " bar"]
        end
      end

    end

    describe "strip_blanks" do
      context "given some leading and trailing blank lines" do
        before :each do
          @hunk = Hunk.new(
            [
              "  \n ", "\t\t\t", "the good stuff", 
              "  \n", "more good stuff\n", "\n"
            ])
          @it = TextTransforms.strip_blanks
        end

        it "should strip the blak lines" do
          @it.call(@hunk).should == ["the good stuff", "  \n", "more good stuff\n"]
        end
      end

    end

    describe "rstrip_lines" do
      before :each do
        @it = TextTransforms.rstrip_lines
      end

      it "should strip whitespace from the ends of lines" do
        @it.call(["foo\n", "\n", "", "\tbar\t \n "]).should == ["foo", "", "", "\tbar"]
      end
    end
  end
end
