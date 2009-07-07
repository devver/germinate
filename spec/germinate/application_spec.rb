require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate

  describe Application do
    before :each do
      @it = Application.new
    end

    context "given a source and a formatter" do
      before :each do
        @source    = StringIO.new("LINE 1\nLINE 2\nLINE 3\n")
        @formatter = stub("Formatter").
          as_null_object
        @it.formatter = @formatter
      end

      it "should call start! before adding lines" do
        @formatter.should_receive(:start!).ordered
        @formatter.should_receive(:add_line!).any_number_of_times.ordered
        
        @it.format(@source)
      end

      it "should pass all source lines to the formatter" do
        @formatter.should_receive(:add_line!).with("LINE 1\n").ordered
        @formatter.should_receive(:add_line!).with("LINE 2\n").ordered
        @formatter.should_receive(:add_line!).with("LINE 3\n").ordered

        @it.format(@source)
      end

      it "should call finish! after source is exhausted" do
        @formatter.should_receive(:add_line!).exactly(3).times.ordered
        @formatter.should_receive(:finish!).once.ordered

        @it.format(@source)
      end

    end

    context "given no formatter" do
      it "should construct one when needed" do
        Formatter.should_receive(:new).
          and_return(stub("Formatter").as_null_object)
        @it.format(StringIO.new)
      end

    end

  end

end
