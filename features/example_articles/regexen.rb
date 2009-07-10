# :SAMPLE: A

def foo
  # ...
end

def bar
  # ...
end

class Frob
  # ...
end

# :TEXT:
# We can select code by regexp
# :INSERT: @A:/foo/../end/
#
# Or with a regex and a length
# :INSERT: @A:/bar/,7
#
# Ending offset can be exclusive
# :INSERT: @A:/foo/.../Frob/

