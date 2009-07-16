require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Variable do
    before :each do
      @it = Variable.new("magic_word", "xyzzy", "LINE", "SOURCE_PATH", 123)
    end

    it "should stringify to its value" do
      @it.to_s.should == "xyzzy"
    end
  end
end
