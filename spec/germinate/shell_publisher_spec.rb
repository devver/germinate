require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe ShellPublisher do
    before :each do
      @name = "frank"
      @pipeline_output = ["* line 1\n", "* line 2\n"]
      @pipeline  = stub("Pipeline", :call => @pipeline_output)
      @librarian = stub("Librarian", :make_pipeline => @pipeline)
      @command   = "cat %f"
      @options   = {:command => @command}
      @it = ShellPublisher.new(@name, @librarian, @options)
    end

    it "should have identifier 'shell'" do
      ShellPublisher.identifier.should == "shell"
    end

    context "on publish" do
      before :each do
        @result  = ["line 1\n", "line 2\n"]
        @output  = StringIO.new
        @process = stub("Process", :call => @result).as_null_object
        @source  = stub("Source").as_null_object
        @librarian.stub!(:[]).and_return(@source)
        Process.stub!(:new).with(@name, @command).and_return(@process)
      end
      
      it "should create a new process" do
        Process.should_receive(:new).with(@name, @command)
        @it.publish!(@output)
      end

      it "should execute the created process" do
        @process.should_receive(:call).with(anything).and_return(@result)
        @it.publish!(@output)
      end

      it "should pass the pipeline output to the created process" do
        @process.should_receive(:call).with(@pipeline_output).and_return(@result)
        @it.publish!(@output)
      end

      it "should ask the librarian for the source file" do
        @librarian.should_receive(:[]).with("$SOURCE", anything)
        @it.publish!(@output)
      end

      it "should write process output to given output stream" do
        @it.publish!(@output)
        @output.rewind
        @output.read.should == "line 1\nline 2\n"
      end

    end
  end
end
