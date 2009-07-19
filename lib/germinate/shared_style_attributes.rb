require File.expand_path("text_transforms", File.dirname(__FILE__))
require File.expand_path("pipeline", File.dirname(__FILE__))
require File.expand_path("origin", File.dirname(__FILE__))
require 'fattr'

module Germinate::SharedStyleAttributes
  fattr :comment_prefix
  fattr :code_open_bracket  => nil
  fattr :code_close_bracket => nil
  fattr :pipeline           => Germinate::Pipeline.new([])
  fattr :source_path        => nil
  fattr :origin             => Germinate::Origin.new


  TEXT_TRANSFORMS = Germinate::TextTransforms.singleton_methods

  (TEXT_TRANSFORMS - ['pipeline']).each do |transform|
    fattr(transform, false)
  end

  def disable_all_transforms!
    TEXT_TRANSFORMS.each do |transform|
      self.send("#{transform}=", false)
    end
  end

  def shared_style_attributes
    Germinate::SharedStyleAttributes.fattrs.inject({}) { 
      |attributes, key|
      
      attributes[key] = send(key)
      attributes
    }
  end

  def copy_shared_style_attributes_from(other, override=true)
    case other
    when Germinate::SharedStyleAttributes
      copy_attributes!(other.shared_style_attributes)
    when Hash
      copy_attributes!(other, override)
    else
      raise "Don't know how to copy attributes from #{other.inspect}"
    end
  end

  def copy_attributes!(attributes, override=true)
    attributes.each_pair do |key, value|
      if !value.nil? && (override || !send(key))
        self.send(key, value)
      end
    end
  end
end
