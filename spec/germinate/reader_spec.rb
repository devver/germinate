require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Reader do
    before :each do
      @librarian = stub("Librarian", :comment_prefix_known? => false).
        as_null_object
      @it        = Reader.new(@librarian, "SOURCE_PATH")
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

    it "should set the librarian's source path" do
      @librarian.should_receive(:source_path=).with(Pathname("SOURCE_PATH"))
      @it = Reader.new(@librarian, "SOURCE_PATH")
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
      [":SAMPLE: bar, { a: 1, b: 2 }", nil, ["bar", {"a"=>1, "b"=>2}]],
      [':BRACKET_CODE:',      nil,     []],
      [':INSERT: @sel',       nil,     ["@sel"]],
      [':PROCESS: foo, bar',  nil,     ["foo", "bar"]],
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

    context "given a BRACKET_CODE control line" do
      before :each do 
        @line = ':BRACKET_CODE: "<<<", ">>>"'
      end

      it "should store the brackets" do
        @librarian.should_receive(:code_open_bracket=).with("<<<")
        @librarian.should_receive(:code_close_bracket=).with(">>>")
        @it << @line
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

      context "given an escaped directive" do
        it "should add the directive line as text" do
          @librarian.should_receive(:add_text!).with("SECTION1", ":TEXT: abc")
          @it << "\\:TEXT: abc"
        end
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

    context "given a :SAMPLE: keyword with a name" do
      before :each do
        @it << ":SAMPLE: foobar"
      end

      it "should file following code lines under the given name" do
        @librarian.should_receive(:add_code!).with("foobar", "line 1")
        @librarian.should_receive(:add_code!).with("foobar", "line 2")

        @it << "line 1"
        @it << "line 2"
      end

      context "given an escaped directive" do
        it "should add the directive line as code" do
          @librarian.should_receive(:add_code!).with("foobar", " # :TEXT: abc")
          @it << " # \\:TEXT: abc"
        end
      end
    end

    context "given a :SAMPLE: keyword with custom brackets" do
      before :each do
        @line = ':SAMPLE: foobar, { brackets: ["<<", ">>"] }'
      end

      it "should assign custom bracket attributes to the sample" do
        @librarian.should_receive(:set_code_attributes!).
          with("foobar", 
          { 
            :code_open_bracket  => "<<", 
            :code_close_bracket => ">>" 
          })

        @it << @line
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

    context "given an insertion with an explicit selector" do
      before :each do
        @it << ":TEXT: mysection"
        @line = ":INSERT: foo"
      end
      
      it "should add an insertion to the current section" do
        @librarian.should_receive(:add_insertion!).
          with("mysection", anything, anything)
        @it << @line
      end

      it "should pass a selector object to the librarian" do
        @librarian.should_receive(:add_insertion!) do |section, selector, options|
          selector.should be_a_kind_of(Selector)
          selector.string.should == "foo"
          selector.default_key.should == "mysection"
        end
        @it << @line
      end
    end

    context "given an insertion with custom attributes" do
      before :each do
        @it << ":TEXT: mysection"
        @line = ":INSERT: foo, { brackets: ['<<', '>>'] } "
      end
      
      it "should pass the attributes on to the library" do
        @librarian.should_receive(:add_insertion!).
          with(anything, anything, {
            :code_open_bracket => "<<", 
            :code_close_bracket => ">>" 
          })
        @it << @line
      end

    end

    context "given a process directive" do
      before :each do
        @line = ' # :PROCESS: sortail, "sort | tail"'
      end

      it "should add the process to the library" do
        @librarian.should_receive(:add_process!).with("sortail", "sort | tail")
        @it << @line
      end
    end

    context  "given a publisher directive" do
      before :each do
        @line = ' # :PUBLISHER: source, shell, { command: "cat %f" }'
      end

      it "should add the publisher to the librarian" do
        @librarian.should_receive(:add_publisher!).
          with("source", "shell", { :command => "cat %f" })
        @it << @line
      end
    end

    context "given a set directive" do
      before :each do
        @line = ' # :SET: name, value'
      end

      it "should set a variable on the librarian" do
        @librarian.should_receive(:set_variable!).
          with(@line, 1, "name", "value")
        @it << @line
      end
    end

  end
end 
