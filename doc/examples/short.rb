# #!/usr/bin/env ruby
# :BRACKET_CODE: <pre>, </pre>
# :PROCESS: ruby, "ruby %f"

# :SAMPLE: hello
def hello(who)
  puts "Hello, #{who}"
end

hello("World")

# :TEXT:
# Check out my amazing program!  Here's the hello method:
# :INSERT: @hello:/def/../end/

# And here's the output:
# :INSERT: @hello|ruby
