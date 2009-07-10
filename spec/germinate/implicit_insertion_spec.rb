require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe ImplicitInsertion do
    before :each do
      @hunk     = stub("Hunk").as_null_object
      @library  = stub("Library")
      @selector = stub("Selector")
      @it = Germinate::ImplicitInsertion.new(@selector, @library)
    end

    context "when the librarian can find the selection" do
      before :each do
        @library.stub!(:[]).and_return(@hunk)
      end

      it "should resolve to the hunk the librarian returns" do
        @it.resolve.should equal(@hunk)
      end
    end

    context "when the librarian cannot find the selection" do
      before :each do
        @library.stub!(:[]).and_raise(IndexError.new)
      end

      it "should resolve to a null hunk" do
        @it.resolve.should be_a_kind_of(NullHunk)
      end
    end
  end
end
