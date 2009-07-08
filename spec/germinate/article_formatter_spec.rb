require 'stringio'

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe ArticleFormatter do
    before :each do 
      @output = StringIO.new
      @hunk1  = stub("Hunk1")
      @hunk2  = stub("Hunk2")
      @it = ArticleFormatter.new(@output)
    end

    def output
      @output.rewind
      @output.string
    end

    context "given some hunks to format" do
      before :each do
        @hunks = [@hunk1, @hunk2]
      end

      it "should visit each hunk in turn" do
        @hunk1.should_receive(:format_with).with(@it).ordered
        @hunk2.should_receive(:format_with).with(@it).ordered
        @hunks.each do |hunk|
          @it.format!(hunk)
        end
      end
    end

    
    context "given some text lines to format but no comment prefix" do
      before :each do
        @it.format_text!(Hunk.new([" # foo", "bar\n\n"]))
      end

      it "should just normalise newlines" do
        output.should == " # foo\nbar\n"
      end
    end

    context "given some text lines to format and a comment prefix" do
      before :each do
        @it.format_text!(Hunk.new([" # foo", "bar\n\n"]), "#")
      end

      it "should erase comments" do
        output.should == "   foo\nbar\n"
      end
    end

    context "given leading and trailing blank lines" do
      before :each do
        @it.format_text!(Hunk.new(["", "foo", " \n "]), "#")
      end

      it "should erase comments" do
        output.should == "foo\n"
      end
    end

    context "given some code lines to format" do
      before :each do
        @it.format_code!(Hunk.new([" \n ", " # foo", "bar\n\n", ""]))
      end

      it "should normalise newlines and strip blanks" do
        output.should == " # foo\nbar\n"
      end
    end

  end
end
