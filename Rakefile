# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'germinate'

task :default => 'spec:run'

PROJ.name = 'germinate'
PROJ.authors = 'Avdi Grimm'
PROJ.email = 'avdi@avdi.org'
PROJ.url = 'http://github.com/devver/germinate/'
PROJ.version = Germinate::VERSION
PROJ.rubyforge.name = 'germinate'

PROJ.spec.opts << '--color'

PROJ.ruby_opts = []

depend_on "ick",   "~> 0.3.0"
depend_on "fattr", "~> 1.0.3"
depend_on "arrayfields", "~> 4.7.3"
depend_on "orderedhash", "~> 0.0.6"
depend_on "alter-ego", "~> 1.0.0"
depend_on "main",      "~> 2.8.3"

# EOF
