require 'rubygems'
require 'arrayfields'

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))


module Germinate
  describe Librarian do
    before :each do
      @it = Librarian.new
      @it.source_path = "SOURCE_PATH"
    end

    it "should know its source path if given" do
      @it.source_path.should == "SOURCE_PATH"
    end

    context "by default" do
      it "should not have a comment prefix" do
        @it.comment_prefix.should == nil
        @it.comment_prefix_known?.should be_false
      end

      it "should not have code brackets" do
        @it.code_open_bracket.should be_nil
        @it.code_close_bracket.should be_nil
      end
    end

    Germinate::SharedStyleAttributes.fattrs.each do |attribute|
      it "should pass the #{attribute} attribute on to text hunks" do
        @it.send(attribute, "#{attribute}_test")
        @it.add_text!("first", "hello")
        @it.section("first").send(attribute).should == "#{attribute}_test"
      end

      it "should pass the #{attribute} attribute on to code hunks" do
        @it.send(attribute, "#{attribute}_test")
        @it.add_code!("first", "hello")
        @it.sample("first").send(attribute).should == "#{attribute}_test"
      end
    end

    context "given a comment prefix" do
      before :each do
        @it.comment_prefix = "||"
      end
      
      it "should remember the comment prefix" do
        @it.comment_prefix.should == "||"
      end

      it "should know it has a comment prefix" do
        @it.comment_prefix_known?.should be_true
      end
    end

    context "given code brackets" do
      before :each do
        @it.code_open_bracket = "{"
        @it.code_close_bracket = "}"
      end
      
      it "should remember the open bracket" do
        @it.code_open_bracket.should == "{"
      end

      it "should remember the close bracket" do
        @it.code_close_bracket.should == "}"
      end

    end

    context "given custom code attributes" do
      before :each do
        @it.set_code_attributes!(
          "sample1",
          :code_open_bracket => "<<",
          :code_close_bracket => ">>")
      end

      it "should create the sample (if needed) and assign the attributes" do
        @it.sample("sample1").code_open_bracket.should == "<<"
        @it.sample("sample1").code_close_bracket.should == ">>"
      end
    end

    context "given an insertion in my_section with selector @my_selector" do
      before :each do
        @it.add_insertion!("my_section", "@my_selector", { :comment_prefix => "@" })
      end

      it "should add an Insertion to the named section" do
        @it.section("my_section").last.should be_a_kind_of(Insertion)
      end

      it "should give the insertion the selector @my_selector" do
        @it.section("my_section").last.selector.to_s.should == "@my_selector"
      end

      it "should give the insertion a reference to the library" do
        @it.section("my_section").last.library.should == @it
      end

      it "should apply any passed attributes to the insertion" do
        @it.section("my_section").last.comment_prefix.should == "@"
      end
    end

    context "given a process to file" do 
      before :each do
        @it.add_process!("myproc", "cowsay")
      end

      it "should make the process available as a Process object" do
        @it.process("myproc").should be_a_kind_of(Germinate::Process)
      end

      it "should store the process name" do
        @it.process("myproc").name.should == "myproc"
      end

      it "should store the process command" do
        @it.process("myproc").command.should == "cowsay"
      end

      it "should include the process when listing known processes" do
        @it.process_names.should include("myproc")
      end

      it "should give the process a reference to the librarians variables" do
        @it.process("myproc").variables.should equal(@it.variables)
      end
    end

    context "given a code sample and some processes" do
      before :each do 
        @output_a  = ["line 1a", "line 2a"]
        @output_b  = ["line 1b", "line 2b"]
        @process_a = stub("Process A", 
          :call => @output_a,
          :name => "foo",
          :command => "aaa")
        @process_b = stub("Process B", 
          :call => @output_b,
          :name => "bar",
          :command => "bbb")
        Germinate::Process.stub!(:new).
          with("foo", "aaa", {}).
          and_return(@process_a)
        Germinate::Process.stub!(:new).
          with("bar", "bbb", {}).
          and_return(@process_b)

        @it.add_code!("A", "line 1")
        @it.add_code!("A", "line 2")
        @it.add_process!("foo", "aaa")
        @it.add_process!("bar", "bbb")
      end

      context "when the processes are included in a selection" do
        before :each do
          @selector = "@A|foo|bar"
        end

        it "should call the processes on the selected text" do
          @process_a.should_receive(:call).with(["line 1\n", "line 2\n"]).
            and_return(@output_a)
          @process_b.should_receive(:call).with(@output_a).
            and_return(@output_b)

          @it[@selector].should == ["line 1b", "line 2b"]
        end
      end

      context "when asked to make a pipeline of the two processes" do
        before :each do
          @pipeline = @it.make_pipeline("bar|foo")
        end

        it "should return a Pipeline object" do
          @pipeline.should be_a_kind_of(Germinate::Pipeline)
        end

        it "should return a two-process pipeline" do
          @pipeline.should have(2).processes
        end

        it "should include the named processes in the pipeline" do
          @pipeline.processes[0].name.should == "bar"
          @pipeline.processes[0].command.should == "bbb"
          @pipeline.processes[1].name.should == "foo"
          @pipeline.processes[1].command.should == "aaa"
        end
      end

      context "when asked to make an empty pipeline" do
        before :each do
          @pipeline = @it.make_pipeline("")
        end

        it "should return an empty pipeline" do
          @pipeline.should have(0).processes
        end
      end
    end

    context "given a new publisher" do
      before :each do
        @publisher_name    = "MyPub"
        @publisher_type    = "shell"
        @publisher_options = {'foo' => 'bar'}
        @publisher         = stub("Publisher")
        Germinate::Publisher.stub!(:make).and_return(@publisher)      
      end

      it "should construct a new publisher object" do
        Germinate::Publisher.should_receive(:make).
          with(@publisher_name, @publisher_type, @it, @publisher_options).
          and_return(@publisher)
        @it.add_publisher!(@publisher_name, @publisher_type, @publisher_options)
      end

      it "should make the new publisher available by name" do
        @it.add_publisher!(@publisher_name, @publisher_type, @publisher_options)
        @it.publisher(@publisher_name).should equal(@publisher)
      end

      it "should raise an error when an unknown publisher is requested" do
        @it.add_publisher!(@publisher_name, @publisher_type, @publisher_options)
        lambda do 
          @it.publisher("foo")
        end.should raise_error(IndexError)
      end
    end

    context "given a variable directive" do
      before :each do
        @line = " :SET: FOO, 123"
        @it.set_variable!(@line, 111, "FOO", "123")
      end

      it "should add a variable with the given name and value" do
        @it.variables["FOO"].should == "123"
      end

      it "should set the variables line to the given value" do
        @it.variables["FOO"].line.should equal(@line)
      end

      it "should set the variables line_number to the given value" do
        @it.variables["FOO"].origin.line_number.should == 111
      end

      it "should set the variables source path to its own source path" do
        @it.variables["FOO"].origin.source_path.to_s.should == "SOURCE_PATH"
      end
    end

    context "given a variable setting when the variable already has a value" do
      before :each do
        @it.set_variable!(" :SET: FOO, 123", 1, "FOO", "123")
        @it.set_variable!(" :SET: FOO, 456", 1, "FOO", "456")
      end

      it "should replace the old variable value with the new one" do
        @it.variables["FOO"].should == "456"
      end
    end

    context "setting a new variable" do
      before :each do
        @it.add_text!("a", " # some text")
        @it.comment_prefix = " # "
        @it.variables["FOO"] = 123
      end

      it "should add a new line" do
        @it.lines.last.should == " # :SET: 'FOO', '123'\n"
      end

      it "should set the variable to reference the new line" do
        @it.variables["FOO"].line.should equal(@it.lines.last)
      end

      it "should set the line number for the new line" do
        @it.variables["FOO"].origin.line_number.should == 2
      end

      it "should set the variable's source file to its own" do
        @it.variables["FOO"].origin.source_path.should == "SOURCE_PATH"
      end

      it "should set the variable's value as a string" do 
        @it.variables["FOO"].should == "123"
      end
    
      it "should set the updatad flag" do
        @it.should be_updated
      end
    end

    context "setting an existing variable" do
      before :each do
        @it.comment_prefix = " # "
        @it.variables["FOO"] = 123
        @it.add_text!("a", " # some text")
        @it.updated = false
        @it.variables["FOO"] = 456
      end

      it "should not add a new line" do
        @it.should have(2).lines
      end

      it "should point to an already existing line" do
        @it.variables["FOO"].line.should equal(@it.lines.first)
      end

      it "should keep variable line number" do
        @it.variables["FOO"].origin.line_number.should == 1
      end

      it "should keep variable source path" do
        @it.variables["FOO"].origin.source_path.should == "SOURCE_PATH"
      end

      it "should update the variable's value" do 
        @it.variables["FOO"].should == "456"
      end
    
      it "should set the updatad flag" do
        @it.should be_updated
      end

      it "should update the source line with a new directive" do
        @it.lines.first.should == " # :SET: 'FOO', '456'\n"
      end
    end

    context "storing changes" do
      before :each do
        @it.add_text!("A", "Line 1")
        @it.add_text!("B", "Line 2")
        @source_file = stub("Source File")
        @it.source_file = @source_file
      end

      it "should send all lines to the source file object to be written" do
        @source_file.should_receive(:write!).with(["Line 1\n", "Line 2\n"])
        @it.store_changes!
      end
    end

    context "given an assortment of lines" do
      before :each do
        @it.add_front_matter!("FM 1")
        @it.add_front_matter!("FM 2")
        @it.add_control!("CONTROL 1")
        @it.add_text!("SECTION1", "TEXT 1")
        @it.add_text!("SECTION1", "TEXT 2")
        @it.add_control!("CONTROL 2")
        @it.add_code!("SECTION1", "CODE 1")
        @it.add_control!("CONTROL 3")
        @it.add_text!("SECTION2", "TEXT 3")
        @it.add_text!("SECTION2", "TEXT 4")
        @it.add_code!("SECTION2", "CODE 2")
        @it.add_code!("SECTION2", "CODE 2l2")
        @it.add_code!("SECTION2", "CODE 2l3")
        @it.add_code!("SECTION2", "CODE 2l4")
      end

      it "should be able to retrieve all the lines in order" do
        @it.lines.should == [
          "FM 1\n",
          "FM 2\n",
          "CONTROL 1\n",
          "TEXT 1\n",
          "TEXT 2\n",
          "CONTROL 2\n",
          "CODE 1\n",
          "CONTROL 3\n",
          "TEXT 3\n",
          "TEXT 4\n",
          "CODE 2\n",
          "CODE 2l2\n",
          "CODE 2l3\n",
          "CODE 2l4\n",
        ]
      end

      it "should be able to retrieve text lines" do
        @it.text_lines.should == [
          "TEXT 1\n",
          "TEXT 2\n",
          "TEXT 3\n",
          "TEXT 4\n"
        ]
      end

      it "should be able to retrieve code lines" do
        @it.code_lines.should == [
          "CODE 1\n",
          "CODE 2\n",
          "CODE 2l2\n",
          "CODE 2l3\n",
          "CODE 2l4\n",
        ]
      end

      it "should be able to retrieve front matter" do
        @it.front_matter_lines.should == [
          "FM 1\n",
          "FM 2\n",
        ]
      end

      it "should be able to retrieve text by section" do
        @it.section("SECTION1").should == [
          "TEXT 1\n",
          "TEXT 2\n"
        ]
        @it.section("SECTION2").should == [
          "TEXT 3\n",
          "TEXT 4\n"
        ]
      end

      it "should be able to retrieve code by sample name" do
        @it.sample("SECTION1").should == [
          "CODE 1\n"
        ]
        @it.sample("SECTION2").should == [
          "CODE 2\n",
          "CODE 2l2\n",
          "CODE 2l3\n",
          "CODE 2l4\n",
        ]
      end

      it "should be able to return a list of section names" do
        @it.section_names.should == [
          "SECTION1",
          "SECTION2"
        ]
      end

      it "should be able to return a list of sample names" do
        @it.sample_names.should == [
          "SECTION1",
          "SECTION2"
        ]
      end

      it "should be able to tell if a section exists" do
        @it.should have_section("SECTION1")
        @it.should_not have_section("SECTION5")
      end

      it "should be able to tell if a sample exists" do
        @it.should have_sample("SECTION1")
        @it.should_not have_sample("SECTION5")
      end

      it "should be able to retrieve lines using a selector" do
        @it[Selector.new("@SECTION1", nil)].should == ["CODE 1\n"]
        @it["@SECTION1"].should == ["CODE 1\n"]
      end

      context "given the $SOURCE selector with no subscripts" do
        before :each do
          @hunk = @it["$SOURCE"]
        end

        it "should return a FileHunk" do
          @hunk.should be_a_kind_of(FileHunk)
        end

        it "should return a FileHunk with the source file path set" do
          @hunk.source_path.should == "SOURCE_PATH"
        end

      end

      SELECTOR_EXAMPLES = [
        # Selector                  Expected Excerpt                   Expected Type
        [ "@SECTION1",              ["CODE 1\n"],                      CodeHunk ],
        [ "@SECTION2:1",            ["CODE 2\n"],                      CodeHunk ],
        [ "@SECTION2:2..3",         ["CODE 2l2\n", "CODE 2l3\n"],      CodeHunk ],
        [ "@SECTION2:2,2",          ["CODE 2l2\n", "CODE 2l3\n"],      CodeHunk ],
        [ "@SECTION2:/l2/../l3/",   ["CODE 2l2\n", "CODE 2l3\n"],      CodeHunk ],
        [ "@SECTION2:/l2/.../l3/",  ["CODE 2l2\n"],                    CodeHunk ],
        [ "@SECTION2:/2/,3",        [
            "CODE 2\n",
            "CODE 2l2\n", 
            "CODE 2l3\n"],                                             CodeHunk ],
        [ "@SECTION2:/l2/..-1",     [
            "CODE 2l2\n", 
            "CODE 2l3\n", 
            "CODE 2l4\n"],                                             CodeHunk ],
        [ "$CODE",                  [          
            "CODE 1\n",
            "CODE 2\n",
            "CODE 2l2\n",
            "CODE 2l3\n",
            "CODE 2l4\n", ],                                    CodeHunk 
        ],
        [ "$SOURCE",               [          
            "FM 1\n",
            "FM 2\n",
            "CONTROL 1\n",
            "TEXT 1\n",
            "TEXT 2\n",
            "CONTROL 2\n",
            "CODE 1\n",
            "CONTROL 3\n",
            "TEXT 3\n",
            "TEXT 4\n",
            "CODE 2\n",
            "CODE 2l2\n",
            "CODE 2l3\n",
            "CODE 2l4\n",
          ],                                                    FileHunk
        ],
        [ "$TEXT",               [          
            "TEXT 1\n",
            "TEXT 2\n",
            "TEXT 3\n",
            "TEXT 4\n"
          ],                                                    CodeHunk
        ],

      ]

      SELECTOR_EXAMPLES.each do |example|
        example.fields = [:selector, :hunk, :type]
        it "should be able to locate #{example[:selector]}" do
          @it[example[:selector]].should == example[:hunk]
        end

        it "should return #{example[:selector]} as #{example[:type]}" do
          @it[example[:selector]].should be_a_kind_of(example[:type])
        end
      end
    end
  end
end
