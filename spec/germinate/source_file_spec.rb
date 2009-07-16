require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe SourceFile do
    before :each do
      @it = SourceFile.new("SOURCE_PATH")
      @file = stub("File", :flock => 0)
      @lines = ["Line 1\n", "Line 2\n"]
      File.stub!(:new).and_return(@file)
      FileUtils.stub!(:cp)
    end

    it "should have a source path" do
      @it.path.to_s.should == "SOURCE_PATH"
    end

    it "should append .germ.back for the backup path" do
      @it.backup_path.to_s.should == "SOURCE_PATH.germ.bak"
    end

    context "when writing" do
      before :each do
        @open_file = stub("Open File", :write => nil)
        @path = stub("SOURCE_PATH", :read => "...")
        @path.stub!(:open).and_yield(@open_file)
        @backup_path = stub("BACKUP_PATH", :read => "...")
        @it.backup_path = @backup_path
        @it.path = @path
      end

      it "should lock and unlock the source path" do
        File.should_receive(:new).with(@it.path).and_return(@file)
        @file.should_receive(:flock).with(File::LOCK_EX).ordered.and_return(0)
        @file.should_receive(:flock).with(File::LOCK_UN).ordered
        @it.write!(@lines)
      end

      it "should raise error if locking fails" do
        @file.should_receive(:flock).with(File::LOCK_EX).ordered.and_return(1)
        @file.should_receive(:flock).with(File::LOCK_UN).ordered

        lambda do
          @it.write!(@lines)
        end.should raise_error(RuntimeError)
      end

      it "should make a backup copy after locking the file" do
        @file.should_receive(:flock).with(File::LOCK_EX).ordered.and_return(0)
        FileUtils.should_receive(:cp).with(@it.path, @backup_path).ordered
        @it.write!(@lines)
      end

      it "should make no backup if locking fails" do
        @file.should_receive(:flock).with(File::LOCK_EX).ordered.and_return(1)
        FileUtils.should_not_receive(:cp)
        @it.write!(@lines) rescue nil
      end

      it "should unlock the file if backup fails" do
        FileUtils.should_receive(:cp).and_raise("Some Error")
        @file.should_receive(:flock).with(File::LOCK_UN)
        @it.write!(@lines) rescue nil
      end

      it "should raise error if source file and backup are not equal" do
        @path.should_receive(:read).and_return("...")
        @backup_path.should_receive(:read).and_return("....")
        lambda do @it.write!(@lines) end.should raise_error(RuntimeError)
      end
      
      it "should not open the source file if comparison fails" do
        @path.should_receive(:read).and_return("...")
        @backup_path.should_receive(:read).and_return("....")
        @path.should_not_receive(:open)
        lambda do @it.write!(@lines) end.should raise_error(RuntimeError)
      end

      it "should open the source file for overwriting after backing up" do
        FileUtils.should_receive(:cp).ordered
        @path.should_receive(:open).with('w+').ordered
        @it.write!(@lines)
      end

      it "should write lines to the source file" do
        @open_file.should_receive(:write).with("Line 1\n").ordered
        @open_file.should_receive(:write).with("Line 2\n").ordered
        @it.write!(@lines)
      end

      it "should restore backup if write fails" do
        @open_file.should_receive(:write).and_raise("Some Failure")
        FileUtils.should_receive(:cp).with(@backup_path, @path)
        lambda do @it.write!(@lines) end.should raise_error(RuntimeError)
      end

    end
  end
end
