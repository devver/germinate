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
        @it.join_lines = false
        @it.format_text!(Hunk.new([" # foo", "bar\n\n"]))
      end

      it "should just normalise newlines" do
        output.should == " # foo\nbar\n"
      end
    end

    context "given some text lines to format and a comment prefix" do
      before :each do
        @it.comment_prefix = "# "
        @it.uncomment      = true
        @it.join_lines     = false
        @it.format_text!(Hunk.new(["#  foo", "bar\n\n"]), "# ")
      end

      it "should erase comments" do
        output.should == " foo\nbar\n"
      end
    end

    context "given leading and trailing blank lines around text" do
      before :each do
        @it.format_text!(Hunk.new(["", "foo", " \n "]), "#")
      end

      it "should erase comments" do
        output.should == "foo\n"
      end
    end

    context "given uncommenting is enabled and a comment prefix is set" do
      it "should supply the comment prefix to the uncomment transform" do
        @hunk          = stub("Hunk").as_null_object
        @hunk.stub!(:strip).and_return(@hunk)
        @prefix        = "//"
        @transform     = stub("Transform", :call => @transformed)
        TextTransforms.stub!(:uncomment).and_return(@transform)

        TextTransforms.should_receive(:uncomment).with(@prefix).
          and_return(lambda{|h| h})

        @it.comment_prefix = @prefix
        @it.uncomment      = true
        @it.format_text!(@hunk)
      end
    end

    CODE_TRANSFORMS = %w[rstrip_lines strip_blanks]
    TEXT_TRANSFORMS  = %w[join_lines strip_blanks uncomment rstrip_lines]
    TEXT_TRANSFORMS.each do |transform_name|
      context "when only #{transform_name} is enabled" do
        before :each do
          (TEXT_TRANSFORMS - [transform_name]).each do |disabled_transform|
            @it.send("#{disabled_transform}=", false)
            TextTransforms.stub!(disabled_transform) do
              fail "Transform #{disabled_transform} should not be enabled"
            end
          end
          @it.send("#{transform_name}=", true)
          
          @transformed   = stub("Transformed Hunk").as_null_object
          @hunk          = stub("Hunk").as_null_object
          @hunk.stub!(:strip).and_return(@hunk)
          @transform     = stub("Transform", :call => @transformed)
          TextTransforms.stub!(transform_name).and_return(@transform)

        end

        it "should perform transform on text hunks" do
          @transform.should_receive(:call).with(@hunk)
          @it.format_text!(@hunk)
        end

        it "should return the result of the transform" do
          @it.format_text!(@hunk).should == @transformed
        end

        unless CODE_TRANSFORMS.include?(transform_name)
          it "should not perform transform on code hunks" do
            @transform.should_not_receive(:call).with(@hunk)
            @it.format_code!(@hunk)
          end
        end
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
