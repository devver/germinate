require 'fattr'
require File.expand_path("shared_style_attributes", File.dirname(__FILE__))

class Germinate::TransformProcess
  fattr(:log) { Germinate.logger }
  
  # We can't just use TextTransforms.singleton_methods because order is important
  def ordered_transforms
    %w[expand_insertions strip_blanks erase_comments
       uncomment         join_lines   rstrip_lines   
       pipeline          bracket      flatten_nested]
  end

  def call(hunk)
    ordered_transforms.inject(hunk) { |input, transform|
      if hunk.send("#{transform}?")
        log.debug "Performing text transform #{transform} on #{hunk}"
        Germinate::TextTransforms.send(transform).call(input) 
      else
        log.debug "Skipping text transform #{transform} on #{hunk} lines"
        input
      end
    }
  end
end
