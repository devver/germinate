require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Publisher do
    context "when a new publisher type 'foo' is defined" do
      before :each do
        @it = Germinate::Publisher
        @subclass = Class.new(Publisher) do
          identifier "foo"
        end
      end

      it "should be able to make 'foo' publishers" do
        @name      = "my_pub"
        @librarian = stub("Librarian")
        @options   = {:a => 'b'}
        @publisher = stub("Publisher")
        @subclass.should_receive(:new).with(@name, @librarian, @options).
          and_return(@publisher)
        
        @it.make(@name, "foo", @librarian, @options)
      end

    end

    context "when an anonymous publisher subclass is defined" do
      before :each do
        @it = Germinate::Publisher
        @subclass = Class.new(Publisher) do
          self.identifier = nil
        end
      end

      it "should not make the publisher available as an instantiable type" do
        @librarian = stub("Librarian")
        @options   = {:a => 'b'}
        @publisher = stub("Publisher")

        lambda do 
          @it.make("mypub", nil, @librarian, @options)
        end.should raise_error(IndexError)
      end

    end

    context "given name, librarian, and options" do
      before :each do
        @name = "frank"
        @librarian = stub("Librarian").as_null_object
        @options   = {:foo => "bar"}
        @it = Publisher.new(@name, @librarian, @options)
      end

      it "should know its name" do
        @it.name.should == @name
      end

      it "should know its librarian" do
        @it.librarian.should == @librarian
      end

      it "should know its options" do
        @it.options.should == @options
      end
    end

    context "given a pipeline option" do
      before :each do
        @name = "frank"
        @librarian = stub("Librarian").as_null_object
        @options   = {:pipeline => "foo|bar"}
      end

      it "should have a pipeline" do
        @it = Publisher.new(@name, @librarian, @options)
        @it.pipeline.should_not be_nil
      end

      it "should use the librarian to construct a pipeline" do
        @librarian.should_receive(:make_pipeline).with("foo|bar")
        @it = Publisher.new(@name, @librarian, @options)
      end
    end
  end
end
