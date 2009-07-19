require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe FileHunk do
    before :each do
      @it = FileHunk.new(["foo", "bar"], {:source_path => "SOURCE_PATH"})
    end

    it "should know its source path" do 
      @it.source_path.to_s.should == "SOURCE_PATH"
    end

    specify { @it.should be_whole_file }

    context "when visited by a formatter" do
      before :each do
        @formatter = stub("Formatter")
      end

      it "should call #formate_code! for self" do
        @formatter.should_receive(:format_code!).with(@it, anything)
        @it.format_with(@formatter)
      end
    end

  end
end
