require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe TextTransforms do

    Germinate::TextTransforms.methods(false).each do |transform|
      describe "'#{transform}'" do
        it "should preserve hunk attributes from input to output" do
          @pipeline = lambda {|h| h}
          @input = Hunk.new([], :comment_prefix => "foo", :pipeline => @pipeline)
          @transform = Germinate::TextTransforms.send(transform)
          @output = @transform.call(@input)
          @output.comment_prefix.should == @input.comment_prefix
        end
      end
    end

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

    describe "bracket" do
      
      context "given explicit brackets" do
        before :each do
          @it = TextTransforms.bracket("[", "]")
        end

        it "should bracket lines with the given brackets" do
          @it.call(["line 1", "line 2"]).should == ["[", "line 1", "line 2", "]"]
        end
      end

      context "given no arguments" do
        before :each do
          @hunk = Hunk.new(
            ["line 1", "line 2"],
            :code_open_bracket => "{{{", 
            :code_close_bracket => "}}}")
          @it = TextTransforms.bracket
        end

        it "should use brackets specified on hunk" do
          @it.call(@hunk).should == ["{{{", "line 1", "line 2", "}}}"]
        end
      end

      context "given no no brackets" do
        before :each do
          @hunk = Hunk.new(
            ["line 1", "line 2"])
          @it = TextTransforms.bracket
        end

        it "should leave the hunk unchanged" do
          @it.call(@hunk).should == ["line 1", "line 2"]
        end
      end
    end

    describe "pipeline" do
      before :each do
        @output   = stub("Output")
        @pipeline = stub("Pipeline", :call => @output)
        @hunk     = stub("Hunk")
      end

      context "called on a hunk and a pipeline" do
        before :each do
          @it = TextTransforms.pipeline(@pipeline)
        end

        it "should invoke the pipeline on the hunk" do
          @pipeline.should_receive(:call).with(@hunk).and_return(@output)
          @it.call(@hunk).should == @output
        end
      end
    end
  end
end
