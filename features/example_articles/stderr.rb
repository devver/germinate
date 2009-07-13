# We can capture both STDOUT and STDERR by using shell modifiers
# :PROCESS: ruby, "ruby %f 2>&1"
# :SAMPLE: output
$stdout.puts "Hello, STDOUT"
$stderr.puts "Hello, STDERR"
$stdout.puts "Hello again, STDOUT"

# :TEXT:
# :INSERT: $SOURCE|ruby
