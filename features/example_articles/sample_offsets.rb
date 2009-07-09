# :SAMPLE: A
a_line_1 = 1
a_line_2 = 2
a_line_3 = 3
a_line_4 = 4

# :TEXT:
# We can specify a starting offset:
# :INSERT: @A:2
# 
# And an ending offset
# :INSERT: @A:2..3
#
# Ending offset can be exclusive
# :INSERT: @A:1...3
#
# We can specify offset and count instead
# :INSERT: @A:2,3
