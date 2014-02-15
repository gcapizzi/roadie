require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--order rand'
end

desc 'Run Mutant'
task :mutant do
  require 'mutant'
  Mutant::CLI.run(%w'--include lib --require roadie --rspec ::Roadie*')
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end

task default: :spec
