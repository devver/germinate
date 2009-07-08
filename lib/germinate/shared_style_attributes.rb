require 'fattr'

module Germinate::SharedStyleAttributes
  fattr :comment_prefix
  fattr :code_open_bracket  => nil
  fattr :code_close_bracket => nil

  def shared_style_attributes
    Germinate::SharedStyleAttributes.fattrs.inject({}) { 
      |attributes, key|
      
      attributes[key] = send(key)
      attributes
    }
  end
end
