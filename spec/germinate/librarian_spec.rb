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
    end

    context "given a code sample and some processes" do
      before :each do 
        @output_a  = ["line 1a", "line 2a"]
        @output_b  = ["line 1b", "line 2b"]
        @process_a = stub("Process A", :call => @output_a)
        @process_b = stub("Process B", :call => @output_b)
        Germinate::Process.stub!(:new).
          with("foo", "aaa").
          and_return(@process_a)
        Germinate::Process.stub!(:new).
          with("bar", "bbb").
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
          @process_a.should_receive(:call).with(["line 1", "line 2"]).
            and_return(@output_a)
          @process_b.should_receive(:call).with(@output_a).
            and_return(@output_b)

          @it[@selector].should == ["line 1b", "line 2b"]
        end
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
          "FM 1",
          "FM 2",
          "CONTROL 1",
          "TEXT 1",
          "TEXT 2",
          "CONTROL 2",
          "CODE 1",
          "CONTROL 3",
          "TEXT 3",
          "TEXT 4",
          "CODE 2",
          "CODE 2l2",
          "CODE 2l3",
          "CODE 2l4",
        ]
      end

      it "should be able to retrieve text lines" do
        @it.text_lines.should == [
          "TEXT 1",
          "TEXT 2",
          "TEXT 3",
          "TEXT 4"
        ]
      end

      it "should be able to retrieve code lines" do
        @it.code_lines.should == [
          "CODE 1",
          "CODE 2",
          "CODE 2l2",
          "CODE 2l3",
          "CODE 2l4",
        ]
      end

      it "should be able to retrieve front matter" do
        @it.front_matter_lines.should == [
          "FM 1",
          "FM 2",
        ]
      end

      it "should be able to retrieve text by section" do
        @it.section("SECTION1").should == [
          "TEXT 1",
          "TEXT 2"
        ]
        @it.section("SECTION2").should == [
          "TEXT 3",
          "TEXT 4"
        ]
      end

      it "should be able to retrieve code by sample name" do
        @it.sample("SECTION1").should == [
          "CODE 1"
        ]
        @it.sample("SECTION2").should == [
          "CODE 2",
          "CODE 2l2",
          "CODE 2l3",
          "CODE 2l4",
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
        @it[Selector.new("@SECTION1", nil)].should == ["CODE 1"]
        @it["@SECTION1"].should == ["CODE 1"]
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
        [ "@SECTION1",              ["CODE 1"],                        CodeHunk ],
        [ "@SECTION2:1",            ["CODE 2"],                        CodeHunk ],
        [ "@SECTION2:2..3",         ["CODE 2l2", "CODE 2l3"],          CodeHunk ],
        [ "@SECTION2:2,2",          ["CODE 2l2", "CODE 2l3"],          CodeHunk ],
        [ "@SECTION2:/l2/../l3/",   ["CODE 2l2", "CODE 2l3"],          CodeHunk ],
        [ "@SECTION2:/l2/.../l3/",  ["CODE 2l2"],                      CodeHunk ],
        [ "@SECTION2:/2/,3",        [
            "CODE 2",
            "CODE 2l2", 
            "CODE 2l3"],                                               CodeHunk ],
        [ "@SECTION2:/l2/..-1",     [
            "CODE 2l2", 
            "CODE 2l3", 
            "CODE 2l4"],                                               CodeHunk ],
        [ "$CODE",                  [          
            "CODE 1",
            "CODE 2",
            "CODE 2l2",
            "CODE 2l3",
            "CODE 2l4", ],                                      CodeHunk 
        ],
        [ "$SOURCE",               [          
            "FM 1",
            "FM 2",
            "CONTROL 1",
            "TEXT 1",
            "TEXT 2",
            "CONTROL 2",
            "CODE 1",
            "CONTROL 3",
            "TEXT 3",
            "TEXT 4",
            "CODE 2",
            "CODE 2l2",
            "CODE 2l3",
            "CODE 2l4",
          ],                                                    FileHunk
        ],
        [ "$TEXT",               [          
            "TEXT 1",
            "TEXT 2",
            "TEXT 3",
            "TEXT 4"
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
