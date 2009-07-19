Germinate::Origin = Struct.new(:source_path, :line_number, :selector) do
  def to_s
    "#{source_path}:#{line_number}:#{selector}"
  end
end
