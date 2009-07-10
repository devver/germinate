require 'English'
require 'pathname'
require 'spec/expectations'
require File.expand_path('../../lib/germinate', File.dirname(__FILE__))

EXAMPLE_ARTICLES = (Pathname(__FILE__).dirname + '../example_articles')
EXAMPLE_OUTPUT = (Pathname(__FILE__).dirname + '../example_output')
EXAMPLE_BIN = (Pathname(__FILE__).dirname + '../bin')

ENV['PATH'] += ":" + EXAMPLE_BIN.to_s

def run_germinate(arguments, permit_failure=false)
  exec_path = (Pathname(__FILE__).dirname + '..' + '..' + 'bin/germ').expand_path
  command   = "#{exec_path} #{arguments}"
  @output   = `#{command}`
  @result   = $CHILD_STATUS
  raise "Command `#{command}` failed" unless @result.success? or permit_failure
end
