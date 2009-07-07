require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Formatter do
    before :each do
      @output = StringIO.new
      @it = Formatter.new(@output)
    end

    it "should start in the :initial state" do
      @it.state.should == :initial
    end


    def output_string
      @output.rewind
      @output.string
    end

    context "which has been started" do
      before :each do
        @it.start!
      end

      it "should be in the :code state" do
        @it.state.should == :code
      end

      it "should ignore initial lines" do
        @it.add_line!("TEST")
        output_string.should == ""
      end

    end

    context "after the :TEXT: keyword" do
      before :each do
        @it.start!
        @it.add_line!(":TEXT:\n")
      end

      it "should be in the :paragraph state" do
        @it.state.should == :paragraph
      end

      it "should start outputting text" do
        @it.add_line!("check 1 2 3\n")
        @it.add_line!("\n")
        output_string.should == "check 1 2 3\n"
      end
    end

    context "after the :TEXT: keyword followed by :CUT:" do
      before :each do
        @it.start!
        @it.add_line!(":TEXT:\n")
        @it.add_line!(":CUT:\n")
      end

      it "should be in the :code state" do
        @it.state.should == :code
      end

      it "should stop outputting text" do
        @it.add_line!("check 1 2 3\n")
        output_string.should == ""
      end
    end

    context "after a :TEXT: keyword prefixed with '#'" do
      before :each do
        @it.start!
        @it.add_line!("# :TEXT:\n")
      end

      it "should be in the :paragraph state" do
        @it.state.should == :paragraph
      end

      it "should have a comment prefix of '#'" do
        @it.comment_prefix.should == '#'
      end

      it "should strip '#' prefixes from text" do
        @it.add_line!("# Line 1\n")
        @it.add_line!(" ## Line 2\n")
        @it.add_line!("\n")
        output_string.should == "Line 1 Line 2\n"
      end

      it "should ignore uncommented lines" do
        @it.add_line!("; Not a comment #")
        output_string.should == ""
      end

      it "should ignore blank lines" do
        @it.add_line!("   \t\n")
        output_string.should == ""
      end

      it "should ignore commented blank lines" do
        @it.add_line!("#   \t\n")
        output_string.should == ""
      end
    end

    context "after a :TEXT: keyword prefixed with ';'" do
      before :each do
        @it.start!
        @it.add_line!(" ; :TEXT:\n")
      end
      
      it "should have a comment prefix of ';'" do
        @it.comment_prefix.should == ';'
      end

      it "should strip ';' prefixes from text" do
        @it.add_line!("; Line 1\n")
        @it.add_line!(" ;; Line 2\n")
        @it.add_line!(";\n")
        output_string.should == "Line 1 Line 2\n"
      end

      it "should ignore lines with '#' prefixes" do
        @it.add_line!("# Line 1\n")
        output_string.should == ""
      end
    end
    
    context "in a text section " do
      before :each do
        @it.start!
        @it.add_line!("# :TEXT:\n")
      end

      it "should join adjacent lines" do
        @it.add_line!("# foo\n")
        @it.add_line!("# bar\n")
        @it.add_line!("\n")
        output_string.should == "foo bar\n"
      end
    end

    context "in a linebreak section" do
      before :each do
        @it.start!
        @it.add_line!("# :TEXT:\n")
        @it.add_line!("# P1\n")
        @it.add_line!("\n")
      end

      it "should finish the section with a double newline" do
        @it.add_line!("# P2\n")
        @it.add_line!("\n")
        output_string.should == "P1\n\nP2\n"
      end
    end
  end
end
