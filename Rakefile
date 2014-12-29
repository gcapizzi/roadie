require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--order rand'
end

desc 'Run Mutant'
task :mutant do
  require 'mutant'
  Mutant::CLI.run %w(--include lib --require roadie --use rspec Roadie*)
end

task default: :spec
