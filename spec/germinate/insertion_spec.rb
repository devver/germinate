require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Insertion, "given a library and a selector" do
    before :each do
      @hunk     = stub("Hunk").as_null_object
      @library  = stub("Library", :[] => @hunk)
      @selector = stub("Selector")
      @it = Germinate::Insertion.new(@selector, @library, {})
    end

    it "should use the library to resolve itself" do
      @library.should_receive(:[]).with(@selector).and_return(@hunk)
      @it.resolve.should == @hunk
    end
  end
end
