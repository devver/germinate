require 'alter_ego'
class Germinate::Formatter
  include AlterEgo

  attr_accessor :comment_prefix

  def initialize(output=$stdio)
    @output = output
  end

  state :initial, :default => true do
    transition :to => :code, :on => :start!
  end

  state :code do
    handle :add_line!, :add_code_line!

    transition :to => :text, :on => :text!
    transition :to => :finished, :on => :finish!
  end
  
  state :text do
    handle :add_line!, :add_text_line!

    transition :to => :code, :on => :code!
    transition :to => :finished, :on => :finish!
  end

  state :finished do

  end

  protected

  def add_code_line!(line)
    case line
    when /\s*(\S+)?\s*:TEXT:/ then 
      self.comment_prefix = $1
      text!
    end
  end

  def add_text_line!(line)
    case line
    when /:CUT:/
      code!
    when text_pattern
      output.puts($1)
    else 
      # NOOP
    end
  end

  private

  attr_reader :output

  def text_pattern
    if comment_prefix
      /^\s*#{comment_prefix}+\s*(.*)/
    else
      /(.*)/
    end
  end
end
