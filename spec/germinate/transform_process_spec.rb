require 'stringio'

require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe TransformProcess do
    before :each do 
      @hunk1  = stub("Hunk1").as_null_object
      @it = TransformProcess.new
    end

    def output
      @output.rewind
      @output.string
    end

    TRANSFORMS = TextTransforms.singleton_methods
    TRANSFORMS.each do |transform_name|
      context "when only #{transform_name} is enabled" do
        before :each do
          @hunk          = stub("Hunk").as_null_object
          @transformed   = stub("Transformed Hunk")
          @transform     = stub("Transform", :call => @transformed)
          TextTransforms.stub!(transform_name).and_return(@transform)

          (TRANSFORMS - [transform_name]).each do |disabled_transform|
            @hunk.stub!("#{disabled_transform}?").and_return(false)
            TextTransforms.stub!(disabled_transform) do
              fail "Transform #{disabled_transform} should not be enabled"
            end
          end
          @hunk.stub!("#{transform_name}?").and_return(true)
        end

        it "should perform transform on input hunks" do
          @transform.should_receive(:call).with(@hunk).and_return(@transformed)
          @it.call(@hunk)
        end

        it "should return the result of the transform" do
          @it.call(@hunk).should == @transformed
        end

      end
    end
    
  end

end
