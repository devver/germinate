require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))


module Germinate
  describe Librarian do
    before :each do
      @it = Librarian.new
    end

    context "by default" do
      it "should not have a comment prefix" do
        @it.comment_prefix.should == nil
        @it.comment_prefix_known?.should be_false
      end

      it "should not have code brackets" do
        @it.code_open_bracket.should == :none
        @it.code_close_bracket.should == :none
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

      it "should return an empty list for missing sections" do
        @it.section("SECTION3").should == []
      end

      it "should be able to retrieve code by sample name" do
        @it.sample("SECTION1").should == [
          "CODE 1"
        ]
        @it.sample("SECTION2").should == [
          "CODE 2",
        ]
      end

      it "should return an empty list for missing sections" do
        @it.sample("SECTION3").should == []
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
    end
  end
end
