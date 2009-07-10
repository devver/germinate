# :BRACKET_CODE: "[", "]"

# :SAMPLE: main
def main
  hello
end

# :SAMPLE: hello, { brackets: [ "{", "}" ] }
def hello
  puts "hello"
end

# :TEXT:
# Should have square brackets
# :INSERT: @main

# :TEXT:
# Should have curly brackets
# :INSERT: @hello

# :TEXT:
# Should have curly brackets
# :INSERT: @hello:2

# :TEXT:
# Should have angle brackets
# :INSERT: @hello:2, { brackets: [ "<", ">" ] }
