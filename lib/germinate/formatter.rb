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

    transition :to => :paragraph, :on => :paragraph!
    transition :to => :finished, :on => :finish!
  end
  
  state :paragraph do
    handle :add_line!, :add_paragraph_line!

    transition :to => :linebreak, :on => :linebreak!
    transition :to => :code, :on => :code!
    transition :to => :finished, :on => :finish!

    on_exit do
      flush_paragraph!
    end
  end

  state :linebreak do
    handle :add_line!, :add_linebreak_line!

    transition :to => :paragraph, :on => :paragraph! do
      emit!("\n")
    end

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
      paragraph!
    end
  end

  def add_paragraph_line!(line)
    case line
    when /:CUT:/
      code!
    when text_pattern
      paragraph_buffer << $1.chomp
    when whitespace_pattern
      linebreak!
    end
  end

  def add_linebreak_line!(line)
    case line
    when /:CUT:/
      code!
    when text_pattern
      paragraph_buffer << $1.chomp
      paragraph!
    else
      # NOOP
    end
  end

  private

  attr_reader :output

  def text_pattern
    if comment_prefix
      /^\s*#{comment_prefix}+\s*(\S+.*)$/
    else
      /^\s*(\S+.*)\s*$/
    end
  end

  def whitespace_pattern
    if comment_prefix
      /^\s*#{comment_prefix}*\s*$/
    else
      /^\s*$/
    end
  end

  def paragraph_buffer
    @paragraph_buffer ||= []
  end

  def flush_paragraph!
    emit!(paragraph_buffer.join(" "))
    paragraph_buffer.clear
  end

  def emit!(text)
    unless text.empty?
      output.puts(text.chomp)
    end
  end
end
