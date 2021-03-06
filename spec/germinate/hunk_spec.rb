require File.expand_path(
  File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Hunk, "(attributes)" do
    Germinate::SharedStyleAttributes.fattrs.each do |attribute|
      it "should support the #{attribute} style attribute" do
        @it = Germinate::Hunk.new([], attribute => "test")
        @it.send(attribute).should == "test"
      end

      it "should pass the #{attribute} attribute on to duplicates" do
        @it = Germinate::Hunk.new([], attribute => "test")
        @it.dup.send(attribute).should == "test"
      end

      it "should pass the #{attribute} attribute on to clones" do
        @it = Germinate::Hunk.new([], attribute => "test")
        @it.clone.send(attribute).should == "test"
      end

      it "should pass the #{attribute} attribute on to slices" do
        @it = Germinate::Hunk.new([], attribute => "test")
        @it[0..-1].send(attribute).should == "test"
        @it.slice(0..-1).send(attribute).should == "test"
      end

      it "should copy #{attribute} from given template" do
        @template = Object.new
        @template.extend SharedStyleAttributes
        @template.send(attribute, "test")
        @it = Germinate::Hunk.new([], @template)
        @it.send(attribute).should == "test"
      end
    end

  end

  describe Hunk do
    before :each do
      @it = Hunk.new
    end

    it "should not have a source path" do
      @it.source_path.should be_nil
    end

    specify { @it.should_not be_whole_file }

    context "with an insertion" do
      before :each do
        @nested_hunk = stub("Nested Hunk")
        @insertion = stub("Insertion", :resolve => @nested_hunk)
        @it << "line 1"
        @it << @insertion
        @it << "line 2"
      end

      it "should be able to resolve the insertion" do
        @it.resolve_insertions.should == [
          "line 1",
          @nested_hunk,
          "line 2"
        ]
      end
    end

    describe "with some content" do
      before :each do
        @it.push("foo", "bar", "foo", "baz")
      end

      it "should be able to find indexes of elements matching a regex" do
        @it.index_matching(/ba/).should == 1
        @it.index_matching(/fo/).should == 0
        @it.index_matching(/fo/, 1).should == 2
        @it.index_matching(/fo/, 2).should == 2
        @it.index_matching(/fo/, 3).should be_nil
        @it.index_matching(/za/, 3).should be_nil
      end
    end
  end

end
