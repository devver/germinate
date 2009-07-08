require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Reader do
    before :each do
      @librarian = stub("Librarian", :comment_prefix_known? => false).
        as_null_object
      @it        = Reader.new(@librarian)
    end

    it "should start in the :initial state" do
      @it.state.should == :initial
    end

    it "should start out with a section count of 0" do
      @it.section_count.should == 0
    end

    it "should start out with current section SECTION0" do
      @it.current_section.should == "SECTION0"
    end

    context "when section count is incremented" do

      before :each do
        @it.increment_section_count!
      end

      it "should increment section count by one" do
        @it.section_count.should == 1
      end

      it "should update current section" do
        @it.current_section.should == "SECTION1"
      end

    end

    CONTROL_LINES = [
      # Line                  Comment  Args
      [":TEXT:\n",            nil,     []],
      ["# :CUT: \n",          "#",     []],
      ["  ; :TEXT: foo\n",    ";",     ["foo"]],
      ["//:SAMPLE:\n",        "//",    []],
      ["$>:END: ",            "$>",    []],
      [":SAMPLE: bar, { a: 1, b: 2 }", nil, ["bar", {"a"=>1, "b"=>2}]]
    ]

    CONTROL_LINES.each do |(line, comment, args)|
      context "when given the line #{line}" do
        if comment
          it "should set the comment character to '#{comment}'" do
            @librarian.should_receive(:comment_prefix=).with(comment)
            @it << line
          end
        else
          it "should not set a comment prefix" do
            @librarian.should_not_receive(:comment_prefix=)
            @it << line
          end
        end

        it "should store the line as a control line" do
          @librarian.should_receive(:add_control!).with(line)
          @it << line
        end
      end
    end

    context "before the first line of text" do
      it "should treat non-keyword lines as front matter" do
        @librarian.should_receive(:add_front_matter!, "TEST")
        @it << "TEST"
      end
    end

    context "after an initial line of text" do
      before :each do
        @it << "\n"
      end

      it "should be in the :front_matter state" do
        @it.state.should == :front_matter
      end

      it "should record non-keyword lines as more front matter" do
        @librarian.should_receive(:add_front_matter!, "TEST")
        @it << "TEST"
      end
    end

    context "after the :TEXT: keyword" do
      before :each do
        @it << ":TEXT:\n"
      end

      it "should be in the :text state" do
        @it.state.should == :text
      end

      it "should place following text lines into a section" do
        @librarian.should_receive(:add_text!).with("SECTION1", "blah blah blah")
        @it << "blah blah blah"
      end
    end

    context "after two anonymous :TEXT: sections" do
      before :each do
        @it << ":TEXT:\n"
        @it << ":TEXT:\n"
      end

      it "should be in SECTION2" do
        @it.current_section.should == "SECTION2"
      end
    end

    context "after a named :TEXT: keyword" do
      before :each do
        @it << ":TEXT: foo\n"
      end

      it "should be in the :text state" do
        @it.state.should == :text
      end

      it "should place following text lines into the named section" do
        @librarian.should_receive(:add_text!).with("foo", "yadda yadda")
        @it << "yadda yadda"
      end

      it "should name following code lines after the section" do
        @librarian.should_receive(:add_code!).with("foo", "this is code")
        @it << "yadda yadda\n"
        @it << ":SAMPLE:\n"
        @it << "this is code"
      end
    end

    context "after text is ended by a :CUT:" do
      before :each do
        @it << ":TEXT:\n"
        @it << ":CUT:\n"
      end

      it "should be in the :code state" do
        @it.state.should == :code
      end

      it "should add following lines to a code sample" do
        @librarian.should_receive(:add_code!).with("SECTION2", "this is code")
        @it << "this is code"
      end
    end

    context "after a :TEXT: keyword prefixed with '#'" do
      before :each do
        @it << "# :TEXT:\n"
      end

      it "should be in the :text state" do
        @it.state.should == :text
      end

    end

    context "after a :TEXT: keyword prefixed with ';'" do
      before :each do
        @it << " ; :TEXT:\n"
      end

      it "should be in the :text state" do
        @it.state.should == :text
      end

    end

    context "in text section with comment set" do
      before :each do
        @librarian.stub!(:comment_prefix_known?).and_return(true)
        @librarian.stub!(:comment_prefix).and_return("#")
        @it << "# :TEXT:\n"
        @section = @it.current_section
      end
      
      it "should treat a commented line as more of the same section" do
        @librarian.should_receive(:add_text!).
          with(@section, "# commented text\n")
        @it << "# commented text\n"
      end

      it "should treat a commented blank line as more of the same section" do
        @librarian.should_receive(:add_text!).
          with(@section, "# \n")
        @it << "# \n"
      end

      it "should treat an uncommented blank line as more of the same section" do
        @librarian.should_receive(:add_text!).
          with(@section, " \n")
        @it << " \n"
      end

      it "should treat an uncommented line as the start of code" do
        @librarian.should_receive(:add_code!).
          with(@section, "uncommented text\n")
        @it << "uncommented text\n"
      end
    end

  end
end 
