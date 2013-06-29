require 'rspec/core/rake_task'
require 'mutant'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--order rand'
end

task :mutant do
  Mutant::CLI.run(%w'-I lib -r roadie --rspec-full ::Roadie')
end

task :default => :spec
