require File.expand_path(
    File.join(File.dirname(__FILE__), %w[.. .. lib germinate]))

module Germinate
  describe Selector do
    EXAMPLE_SELECTORS = [
      # selector       type      key        start end length pipeline
      [ "@A",          :code,    "A",       1,    -1, nil,   nil     ],
      [ "",            :code,    "DEFAULT", 1,    -1, nil,   nil     ],
      [ nil,           :code,    "DEFAULT", 1,    -1, nil,   nil     ],
      [ ":2..4",       :code,    "DEFAULT", 2,     4,   3,   nil     ],
      [ "@B:2,5",      :code,    "B",       2,     6,   5,   nil     ],
      [ "@B:/z/,6",    :code,    "B",       /z/, nil,   6,   nil     ],
      [ "@_:/z/../x/", :code,    "_",       /z/, /x/, nil,   nil     ],
      [ "@B:2,4|fnord",:code,    "B",       2,     5,   4,   "fnord" ],
      [ "$FOO",        :special, "FOO",     1,    -1, nil,   nil     ],
    ]

    EXAMPLE_SELECTORS.each do |selector_attributes| 
      selector_string = selector_attributes[0]
      type            = selector_attributes[1]
      key             = selector_attributes[2]
      start           = selector_attributes[3]
      end_offset      = selector_attributes[4]
      length          = selector_attributes[5]
      pipeline        = selector_attributes[6]

      context "given selector '#{selector_attributes[0]}'" do
        before :each do
          @it = Germinate::Selector.new(selector_string, "DEFAULT")
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
      end
    end
  end
end
