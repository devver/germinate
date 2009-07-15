require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Pipeline, "given a set of processes" do
    before :each do 
      @intput   = stub("Input")
      @output1  = stub("Output 1")
      @output2  = stub("Output 2")
      @output3  = stub("Output 3")
      @process1 = stub("Process 1", :call => @output1)
      @process2 = stub("Process 2", :call => @output2)
      @process3 = stub("Process 3", :call => @output3)
      @it = Germinate::Pipeline.new([@process1, @process2, @process3])
    end

    it "should compose the processes into a pipeline" do
      @process1.should_receive(:call).with(@input).and_return(@output1)
      @process2.should_receive(:call).with(@output1).and_return(@output2)
      @process3.should_receive(:call).with(@output2).and_return(@output3)
      @it.call(@input).should == @output3
    end
  end

  describe Pipeline, "given no processes" do
    before :each do
      @it = Pipeline.new([])
     end
    
    it "should pass input through unchanged" do
      @it.call(["foo", "bar"]).should == ["foo", "bar"]
    end
  end
end
