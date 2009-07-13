# We can excerpt the output of a command instead of running the command on an
# excerpt.
# :PROCESS: ruby, "ruby %f"
# :SAMPLE:

puts "-" * 3
puts "line 1"
puts "-" * 5

puts "=" * 3
puts "line 2"
puts "=" * 5

# :TEXT:
# :INSERT: $SOURCE|ruby:/===/../=====/
# :INSERT: $SOURCE|ruby:/---/../-----/
