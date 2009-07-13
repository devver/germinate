# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{germinate}
  s.version = "1.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Avdi Grimm"]
  s.date = %q{2009-07-13}
  s.default_executable = %q{germ}
  s.description = %q{Germinate is a tool for writing about code.  With Germinate, the source code IS the article.  For example, given the following source code:  # #!/usr/bin/env ruby # :BRACKET_CODE: <pre>, </pre> # :PROCESS: ruby, "ruby %f"  # :SAMPLE: hello def hello(who) puts "Hello, #{who}" end  hello("World")  # :TEXT: # Check out my amazing program!  Here's the hello method: # :INSERT: @hello:/def/../end/  # And here's the output: # :INSERT: @hello|ruby  When we run the <tt>germ format</tt> command the following output is generated:  Check out my amazing program!  Here's the hello method: <pre> def hello(who) puts "Hello, #{who}" end </pre> And here's the output: <pre> Hello, World </pre>  To get a better idea of how this works, please take a look at link:examples/basic.rb, or run:  germ generate > basic.rb  To generate an example article to play with.  Germinate is particularly useful for writing articles, such as blog posts, which contain code excerpts.  Instead of forcing you to keep a source code file and an article document in sync throughout the editing process, the Germinate motto is "The source code IS the article".  Specially marked comment sections in your code file become the article text.  Wherever you need to reference the source code in the article, use insertion directives to tell Germinate what parts of the code to excerpt.  An advanced selector syntax enables you to be very specific about which lines of code you want to insert.  If you also want to show the output of your code, Germinate has you covered. Special "process" directives enable you to define arbitrary commands which can be run on your code.  The output of the command then becomes the excerpt text. You can define an arbitrary number of processes and have different excerpts showing the same code as processed by different commands.  You can even string processes together into pipelines.  Development of Germinate is graciously sponsored by Devver, purveyor of fine cloud-based services to busy Ruby developers.  If you like this tool please check them out at http://devver.net.}
  s.email = %q{avdi@avdi.org}
  s.executables = ["germ"]
  s.extra_rdoc_files = ["History.txt", "README.rdoc", "bin/germ"]
  s.files = [".gitignore", "History.txt", "README.rdoc", "Rakefile", "TODO", "bin/germ", "cucumber.yml", "examples/basic.rb", "examples/short.rb", "features/author-formats-article.feature", "features/author-lists-info.feature", "features/author-publishes-article-source.feature", "features/author-publishes-article.feature", "features/author-republishes-article.feature", "features/author-selects-hunks.feature", "features/author-updates-article-source.feature", "features/author-views-stuff.feature", "features/bin/quoter", "features/bin/sorter", "features/example_articles/bracketing.rb", "features/example_articles/escaping.txt", "features/example_articles/excerpt_output.rb", "features/example_articles/hello.rb", "features/example_articles/pipelines.txt", "features/example_articles/regexen.rb", "features/example_articles/sample_offsets.rb", "features/example_articles/specials.rb", "features/example_articles/stderr.rb", "features/example_articles/wrapping.rb", "features/example_output/bracketing.out", "features/example_output/code_samples.txt", "features/example_output/escaping.out", "features/example_output/excerpt_output.out", "features/example_output/hello.txt", "features/example_output/pipelines.out", "features/example_output/regexen.txt", "features/example_output/sample_offsets.txt", "features/example_output/specials.txt", "features/example_output/stderr.out", "features/example_output/wrapping.txt", "features/step_definitions/germinate.rb", "features/support/env.rb", "germinate.gemspec", "lib/germinate.rb", "lib/germinate/application.rb", "lib/germinate/article_editor.rb", "lib/germinate/article_formatter.rb", "lib/germinate/formatter.rb", "lib/germinate/hunk.rb", "lib/germinate/implicit_insertion.rb", "lib/germinate/insertion.rb", "lib/germinate/librarian.rb", "lib/germinate/pipeline.rb", "lib/germinate/process.rb", "lib/germinate/reader.rb", "lib/germinate/selector.rb", "lib/germinate/shared_style_attributes.rb", "lib/germinate/text_transforms.rb", "spec/germinate/application_spec.rb", "spec/germinate/article_editor_spec.rb", "spec/germinate/article_formatter_spec.rb", "spec/germinate/code_hunk_spec.rb", "spec/germinate/file_hunk_spec.rb", "spec/germinate/formatter_spec.rb", "spec/germinate/hunk_spec.rb", "spec/germinate/implicit_insertion_spec.rb", "spec/germinate/insertion_spec.rb", "spec/germinate/librarian_spec.rb", "spec/germinate/pipeline_spec.rb", "spec/germinate/process_spec.rb", "spec/germinate/reader_spec.rb", "spec/germinate/selector_spec.rb", "spec/germinate/text_hunk_spec.rb", "spec/germinate/text_transforms_spec.rb", "spec/germinate_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "tasks/ann.rake", "tasks/bones.rake", "tasks/cucumber.rake", "tasks/gem.rake", "tasks/git.rake", "tasks/notes.rake", "tasks/post_load.rake", "tasks/rdoc.rake", "tasks/rubyforge.rake", "tasks/setup.rb", "tasks/spec.rake", "tasks/svn.rake", "tasks/test.rake", "tasks/zentest.rake", "test/test_germinate.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/devver/germinate/}
  s.rdoc_options = ["--main", "README.rdoc"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{germinate}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Germinate is a tool for writing about code}
  s.test_files = ["test/test_germinate.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ick>, ["~> 0.3.0"])
      s.add_runtime_dependency(%q<fattr>, ["~> 1.0.3"])
      s.add_runtime_dependency(%q<arrayfields>, ["~> 4.7.3"])
      s.add_runtime_dependency(%q<orderedhash>, ["~> 0.0.6"])
      s.add_runtime_dependency(%q<alter-ego>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<main>, ["~> 2.8.3"])
      s.add_development_dependency(%q<bones>, [">= 2.5.1"])
    else
      s.add_dependency(%q<ick>, ["~> 0.3.0"])
      s.add_dependency(%q<fattr>, ["~> 1.0.3"])
      s.add_dependency(%q<arrayfields>, ["~> 4.7.3"])
      s.add_dependency(%q<orderedhash>, ["~> 0.0.6"])
      s.add_dependency(%q<alter-ego>, ["~> 1.0.0"])
      s.add_dependency(%q<main>, ["~> 2.8.3"])
      s.add_dependency(%q<bones>, [">= 2.5.1"])
    end
  else
    s.add_dependency(%q<ick>, ["~> 0.3.0"])
    s.add_dependency(%q<fattr>, ["~> 1.0.3"])
    s.add_dependency(%q<arrayfields>, ["~> 4.7.3"])
    s.add_dependency(%q<orderedhash>, ["~> 0.0.6"])
    s.add_dependency(%q<alter-ego>, ["~> 1.0.0"])
    s.add_dependency(%q<main>, ["~> 2.8.3"])
    s.add_dependency(%q<bones>, [">= 2.5.1"])
  end
end
