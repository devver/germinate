# A basic example of a Germinate article.
#
# This text is "front matter" and will not be included in the final article.
# The article doesn't begin until the first text directive.
#
# Let's set up code bracketing so that code excerpts will be surrounded by HTML
# <pre>...</pre> tags.
#
# :BRACKET_CODE: <pre>, </pre>
#
# :TEXT:
# This is the first line of the article text.  For the formatted article,
# Germinate will remove the comment prefixes ("# ") and join paragraphs into
# single lines.
#
# We're coming up on our first code section.  If some code immediately follows a
# text section it will automatically be inserted into the formatted article
# text.
def my_func
  # ...
end
# :END:
# 
# The END directive above ends that particular code sample.  This text will not
# be included in the final article.
#
# We don't want to have to write our source code in the order it appears in
# the article.  Let's define a named code sample.
#
# :SAMPLE: hello
def hello
  puts "Hello, #{ARGV[0]}"
end
hello

# :TEXT:
# We're back in the article text now.  Let's insert our named sample now.
# :INSERT: @hello
#
# Now lets define some processes and experiment with running the sample through
# them.
#
# :PROCESS: fred, "ruby %f Fred"
# :PROCESS: jane, "ruby %f Jane"
# :PROCESS: quote, "ruby -n -e 'puts \"> #{$_}\"'"
#
# Note that the "quote" process has no %f placeholder for the filename.
# If it doesn't find a %f, Germinate will pipe the source sample into the
# command on its STDIN.
#
# Here's the result of \:INSERT: @hello|fred
# :INSERT: @hello|fred
#
# Here's the result of :INSERT: @hello|jane
# :INSERT: @hello|jane
#
# We can even chain processes together. Here's the result of 
# \:INSERT: @hello|jane|quote
# :INSERT: @hello|jane|quote
#
# It's not necessary to quote whole code samples.  We can select specific lines
# to excerpt using more advanced selectors.
#
# Select a single line
# \:INSERT: @foo:2
# :INSERT: @foo:2
#
# Select an inclusive range
# \:INSERT: @foo:2..4
# :INSERT: @foo:2..4
#
# Select an exclusive range
# \:INSERT: @foo:1...3
# :INSERT: @foo:1...3
#
# Select by starting line and length
# \:INSERT: @foo:4,4
# :INSERT: @foo:4,4
#
# Select by starting and ending regular expressions
# \:INSERT: @foo:/do_stuff/../end/
# :INSERT: @foo:/do_stuff/../end/
#
# Select by regex and length
# \:INSERT: @foo:/attr_reader/,3
# :INSERT: @foo:/attr_reader/,3
#
# :SAMPLE: foo
class Foo
  attr_reader :bar
  attr_reader :baz
  attr_reader :buz

  def do_stuff
    # ...
  end
end
# :END:

# :TEXT:
# Finally, we can include all of the code samples in a single chunk with
# \:INSERT: $CODE
# :INSERT: $CODE
#
# There are some other special section names, such as $SOURCE and $TEXT.  See
# the Germinate documentation for more.
#
# :CUT:
#
# You can format this article for publishing by running:
#
#   germ format <filename>
#
# If you want to experiment with the selector syntax, try:
#
#   germ select -s <selector>
#
# Enjoy!
