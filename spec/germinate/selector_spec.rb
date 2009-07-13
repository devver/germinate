require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Selector do

    context "given a subscript" do
      before :each do
        @it = Germinate::Selector.new("@A:1", "DEFAULT")
      end

      specify { @it.should be_slice }
      specify { @it.should_not be_whole }
    end

    context "given no subscript" do
      before :each do
        @it = Germinate::Selector.new("@A", "DEFAULT")
      end

      specify { @it.should_not be_slice }
      specify { @it.should be_whole }
    end

    context "given a post-pipeline subscript" do
      before :each do
        @it = Germinate::Selector.new("@A|foo:1", "DEFAULT")
      end

      specify { @it.should_not be_slice }
      specify { @it.should be_whole }
    end

    EXAMPLE_SELECTORS = [
      # selector       type      key        delim  start end length pipeline excerpt_output?
      [ "@A",          :code,    "A",       '..',  1,    -1, nil,   []       ,false],
      [ "@A:1",        :code,    "A",       nil,   1,    1,  nil,   []       ,false],
      [ "",            :code,    "DEFAULT", '..',  1,    -1, nil,   []       ,false],
      [ nil,           :code,    "DEFAULT", '..',  1,    -1, nil,   []       ,false],
      [ ":2..4",       :code,    "DEFAULT", '..',  2,    4,  nil,   []       ,false],
      [ ":2...4",      :code,    "DEFAULT", '...', 2,    4,  nil,   []       ,false],
      [ "@B:2,5",      :code,    "B",       ',',   2,    nil,5,     []       ,false],
      [ "@B:/z/,6",    :code,    "B",       ',',   /z/,  nil,6,     []       ,false],
      [ "@_:/z/../x/", :code,    "_",       '..',  /z/,  /x/,nil,   []       ,false],
      [ "@B:2,4|fnord",:code,    "B",       ',',   2,    nil,4,     ["fnord"],false],
      [ "$FOO",        :special, "FOO",     '..',  1,    -1, nil,   []       ,false],
      [ "@A|foo|bar",  :code,    "A",       '..',  1,    -1, nil,   ["foo", "bar"],false],
      [ "@B|fnord:2,4",:code,    "B",       ',',   2,    nil,4,     ["fnord"],true],
    ]

    EXAMPLE_SELECTORS.each do |selector_attributes| 
      selector_string = selector_attributes[0]
      type            = selector_attributes[1]
      key             = selector_attributes[2]
      delimiter       = selector_attributes[3]
      start           = selector_attributes[4]
      end_offset      = selector_attributes[5]
      length          = selector_attributes[6]
      pipeline        = selector_attributes[7]
      excerpt_output  = selector_attributes[8]

      context "given selector '#{selector_attributes[0]}'" do
        before :each do
          @it = Germinate::Selector.new(selector_string, "DEFAULT")
        end

        it "should have string #{selector_string}" do
          @it.string.should == selector_string
        end

        it "should have type #{type.inspect}" do
          @it.selector_type.should == type 
        end
        it "should have key #{key.inspect}" do
          @it.key.should == key 
        end
        it "should start at #{start.inspect}" do
          @it.start_offset.should == start 
        end
        it "should end at #{end_offset.inspect}" do 
          @it.end_offset.should == end_offset
        end
        it "should have length #{length.inspect}" do
          @it.length.should == length 
        end
        it "should have pipeline #{pipeline.inspect}" do
          @it.pipeline.should == pipeline 
        end
        it "should have delimiter #{delimiter.inspect}" do
          @it.delimiter.should == delimiter
        end
        
        if excerpt_output
          specify { @it.should be_excerpt_output }
        else
          specify { @it.should_not be_excerpt_output }
        end
      end
    end
  end
end
