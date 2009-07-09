class Germinate::Selector
  attr_reader :string
  attr_reader :selector_type
  attr_reader :key
  attr_reader :start_offset
  attr_reader :end_offset
  attr_reader :length
  attr_reader :pipeline

  PATTERN = /([@$])?(\w+)?(:([^\s\|]+))?(\|(\w+))?/
  EXCERPT_PATTERN = %r{((\d+)|(/[^/]*/))(((\.\.\.?)|(,))((\d+)|(/[^/]*/)))?}

  def initialize(string, default_section)
    match_data = case string
                 when "", nil then {}
                 else PATTERN.match(string)
                 end

    @selector_type = 
      case match_data[1]
      when "$" then :special
      when "@", nil then :code
      else raise "Unknown selector type '#{match_data[1]}'"
      end
    @key = match_data[2] || default_section
    if match_data[3]
      parse_excerpt(match_data[3])
    else
      @start_offset = 1
      @end_offset   = -1
      @length       = nil
    end
    @pipeline = match_data[6]
  end

  private

  def parse_excerpt(excerpt)
    match_data = EXCERPT_PATTERN.match(excerpt)
    integer_start_offset = match_data[2]
    regexp_start_offset  = match_data[3]
    delimiter            = match_data[5]
    integer_end_offset   = match_data[9]
    regexp_end_offset    = match_data[10]

    if integer_start_offset
      @start_offset = integer_start_offset.to_i
    elsif regexp_start_offset
      @start_offset = Regexp.new(regexp_start_offset[1..-2])
    else
      raise "Could not parse start offset '#{match_data[1]}'"
    end

    op = case delimiter
         when '..' then :inclusive
         when '...' then :exclusive
         when ',' then :length
         else :none
         end

    if integer_end_offset
      @end_offset = integer_end_offset.to_i
    elsif regexp_end_offset
      @end_offset = Regexp.new(regexp_end_offset[1..-2])
    else
      @end_offset = -1
    end

    case op
    when :inclusive
      if integer_offsets?
        @length = @end_offset - (@start_offset-1)
      end
    when :length
      @length = @end_offset
      if integer_offsets?
        @end_offset = (@start_offset + @length) - 1
      else
        @end_offset = nil
      end
    end
      
  end

  def integer_offsets?
    Integer === @start_offset && Integer === @end_offset
  end
end
