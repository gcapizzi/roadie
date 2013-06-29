require 'rspec/core/rake_task'
require 'mutant'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--order rand'
end

desc 'Run Mutant'
task :mutant do
  Mutant::CLI.run(%w'-I lib -r roadie --rspec-full ::Roadie')
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task :default => :spec
