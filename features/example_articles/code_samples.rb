# This example demonstrates the use of code samples.

# :TEXT:
# Hi there!  Here's a Hello, World method:

def hello
  puts "Hello, World!"
end

# :CUT:
# Here's some boring support code we don't want to show the world.

def boring
  1 + 1
end

# Here are two a named samples:
# :SAMPLE: fred

def fred
  # This comment is part of the sample
  puts "Hello, my name is Fred"
  puts "la la la"
end

# :SAMPLE: sally

def sally
  puts "Hello, my name is Sally"
end

# :END:
# Sample "sally" ends above, and does not include the following.

def wizard
  puts "Pay no attention to the man behind the curtain!"
end

# Samples can be inside comment blocks
# :SAMPLE: george
#    (defun george () (format "Hello from George"))
# :CUT:

# Samples can have comment markers stripped
# :SAMPLE: mary, { uncomment: true }
#    (defun mary () (format "Hello from Mary"))
# :CUT:

# :TEXT:
# The immediately following code sample can be implicitly referenced:
# :INSERT:
# :CUT:
def nameless
  puts "I have no name"
end

# :TEXT:
# Or explicitly referenced
# :INSERT: FOLLOWING
# :CUT:
def foo
  puts "foo"
end

# :TEXT:
# Samples can be referenced by name
# :INSERT: fred
# 
# Or by index:
# :INSERT: #2
#
# SOURCE is a special sample which contains the entire source file.
# :INSERT: SOURCE, { indent: 4 }
#
# CODE is a special sample which contains all the non-text portions of this
# file.
# :INSERT: CODE, { indent: " > " }
#
# We can select specific lines:
# :INSERT: sally:2
#
# Or ranges of lines:
# :INSERT: sally:2..3
# 
# Or lines matching a regex:
# :INSERT: sally:/def/
#
# Or ranges of regexen:
# :INSERT: fred:/puts/.../end/
