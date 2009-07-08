require File.expand_path(
  File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Hunk do
    Germinate::SharedStyleAttributes.fattrs.each do |attribute|
      it "should support the #{attribute} style attribute" do
        @it = Germinate::Hunk.new([], attribute => "test")
        @it.send(attribute).should == "test"
      end
    end
  end

end
