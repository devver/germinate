require 'fattr'

module Germinate::SharedStyleAttributes
  fattr :comment_prefix
  fattr :code_open_bracket  => :none
  fattr :code_close_bracket => :none
end
