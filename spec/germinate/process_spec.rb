require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe ShellProcess do
    before :each do
      @input   = Germinate::Hunk.new(
        ["line 1\n", "line 2\n"], 
        :comment_prefix => "//")
      @output  = ["1 enil\n", "2 enil\n"]
      @command = stub("Command", :readlines => @output).as_null_object
      @tempfile = stub("Temp File", :path => "TEMP_PATH").as_null_object
      @status   = stub("Child Status", :success => true)
      IO.stub!(:popen).and_yield(@command)
      Tempfile.stub!(:open).and_yield(@tempfile)
    end

    context "given a command and some variables" do
      before :each do
        @it = Germinate::ShellProcess.new(
          "myproc", "mycommand", { "FOO" => 123, "BAR" => 456 })
        ENV["FOO"] = "xxx"
      end

      it "should set the variables in the environment before execution" do
        IO.should_receive(:popen) do
          ENV["FOO"].should == "123"
          ENV["BAR"].should == "456"
        end
        @it.call(@input)
      end

      it "should reset the environment after execution" do
        @it.call(@input)
        ENV["FOO"].should == "xxx"
        ENV["BAR"].should be_nil
      end
    end

    context "given a command 'mycommand'" do
      before :each do
        @it = Germinate::ShellProcess.new("myproc", "mycommand")
      end

      context "when called on a hunk of text" do
        it "should pipe the input through the command" do
          @command.should_receive(:<<).with("line 1\n").ordered
          @command.should_receive(:<<).with("line 2\n").ordered
          @command.should_receive(:close_write).ordered
          @command.should_receive(:readlines).ordered.
            and_return(["a\n", "b\n"])
          IO.should_receive(:popen).with("mycommand", "r+").and_yield(@command)
          output = @it.call(@input)
          output.should == ["a\n", "b\n"]
        end
        
        it "should preserve hunk attributes" do
          output = @it.call(@input)
          output.comment_prefix.should == "//"
        end

      end
    end

    context "given a command 'mycommand %f' and called on some text" do
      before :each do
        @it = Germinate::ShellProcess.new("myproc", "mycommand %f")
      end

      it "should create a temporary file and pass the name to the command" do
        Tempfile.should_receive(:open).with("germinate_hunk").and_yield(@tempfile)
        @tempfile.should_receive(:<<).with("line 1\n").ordered
        @tempfile.should_receive(:<<).with("line 2\n").ordered
        @tempfile.should_receive(:close).ordered
        IO.should_receive(:popen).
          with("mycommand 'TEMP_PATH'", "r").
          and_yield(@command)
        
        @it.call(@input).should == @output
      end

      it "should preserve hunk attributes" do
        output = @it.call(@input)
        output.comment_prefix.should == "//"
      end

    end

    context "given a command 'mycommand %f' and called on a file hunk" do
      before :each do
        @input = Germinate::FileHunk.new(
          ["line 1\n", "line 2\n"],
          {:source_path => "SOURCE_PATH"})
        @it = Germinate::ShellProcess.new("myproc", "mycommand %f")
      end

      it "should pass the source file path to the command" do
        @path = stub("Source File Path")
        IO.should_receive(:popen).with("mycommand 'SOURCE_PATH'", "r").
          and_yield(@command)
        @it.call(@input).should == @output
      end
    end
  end
end
