require 'tempfile'

Given /^the article "([^\"]*)"$/ do |article_file|
  @filename = (EXAMPLE_ARTICLES + article_file)
end

When /^I run the format command on the article$/ do
  run_germinate("format #{@filename}")
end

When /^I run the command "([^\"]*)" on the article$/ do |command|
  run_germinate(command.sub(/^germ /,"") + " #{@filename}")
end

Then /^the output should look like "([^\"]*)"$/ do |output_file|
  example_path   = (EXAMPLE_OUTPUT + output_file)
  example_output = example_path.read
  @output.should == example_output
end

Given /^an article with the contents:$/ do |contents|
  Tempfile.open("germinate_example_article") do |file|
    file.write(contents)
    @filename = Pathname(file.path)
  end
end

Then /^the output should be as follows:$/ do |example_output|
  @output.strip.should == example_output.strip
end
