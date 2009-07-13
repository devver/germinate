class Germinate::Selector
  attr_reader :string
  attr_reader :selector_type
  attr_reader :key
  attr_reader :start_offset
  attr_reader :end_offset
  attr_reader :length
  attr_reader :delimiter
  attr_reader :pipeline
  attr_reader :default_key

  PATTERN = /^([@$])?(\w+)?(:([^\s\|]+))?(\|([\w|]+))?$/
  EXCERPT_OUTPUT_PATTERN = /^([@$])?(\w+)?(\|([\w|]+))?(:([^\s\|]+))?$/
  EXCERPT_PATTERN = %r{((-?\d+)|(/[^/]*/))(((\.\.\.?)|(,))((-?\d+)|(/[^/]*/)))?}

  def initialize(string, default_key)
    @string      = string
    @default_key = default_key
    match_data = case string
                 when "", nil then {}
                 else 
                   if data = PATTERN.match(string) 
                     @excerpt_output = false
                   elsif data = EXCERPT_OUTPUT_PATTERN.match(string)
                     @excerpt_output = true
                   else
                     raise "Could not parse selector '#{string}'"
                   end
                   data
                 end

    subscript_index = @excerpt_output ? 6 : 3
    pipeline_index  = @excerpt_output ? 4 : 6

    @selector_type = 
      case match_data[1]
      when "$" then :special
      when "@", nil then :code
      else raise "Unknown selector type '#{match_data[1]}'"
      end
    @key = match_data[2] || default_key
    if match_data[subscript_index]
      @slice = true
      parse_excerpt(match_data[subscript_index])
    else
      @slice        = false
      @delimiter    = '..'
      @start_offset = 1
      @end_offset   = -1
      @length       = nil
    end
    @pipeline = String(match_data[pipeline_index]).split("|")
  end

  def start_offset_for_slice
    offset_for_slice(start_offset)
  end

  def end_offset_for_slice
    offset_for_slice(end_offset)
  end

  # Should excerpting be done on the output of the process?
  def excerpt_output?
    @excerpt_output
  end

  # Is it just a subset of the source hunk? (opposite of @whole?)
  def slice?
    @slice
  end

  # Is it the entire hunk? (opposite of #slice?)
  def whole?
    !@slice
  end

  private

  def parse_excerpt(excerpt)
    match_data = EXCERPT_PATTERN.match(excerpt)
    integer_start_offset = match_data[2]
    regexp_start_offset  = match_data[3]
    @delimiter           = match_data[5]
    integer_end_offset   = match_data[9]
    regexp_end_offset    = match_data[10]

    if integer_start_offset
      @start_offset = integer_start_offset.to_i
    elsif regexp_start_offset
      @start_offset = Regexp.new(regexp_start_offset[1..-2])
    else
      raise "Could not parse start offset '#{match_data[1]}'"
    end

    case @delimiter
    when '..', '...'
      if integer_end_offset
        @end_offset = integer_end_offset.to_i
      elsif regexp_end_offset
        @end_offset = Regexp.new(regexp_end_offset[1..-2])
      end
    when nil
      @end_offset = @start_offset
    when ','
      @length = integer_end_offset.to_i
    else raise "Should not get here"
    end

  end

  def integer_offsets?
    Integer === @start_offset && Integer === @end_offset
  end

  def offset_for_slice(offset)
    return offset if offset.nil? || offset.kind_of?(Regexp)
    if offset < 1
      offset
    else
      offset - 1
    end
  end
end
