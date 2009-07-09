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

  def copy_shared_style_attrubutes_from(other)
    other.shared_style_attributes.each_pair do |key, value|
      self.send(key, value) unless other.send(key).nil?
    end
  end
end
