require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:rspec) do |t|
    t.rspec_opts = '--order rand'
  end

  task :mutant do
    require 'mutant'
    Mutant::CLI.run %w(--include lib --require roadie --use rspec Roadie*)
  end

  task all: [:rspec, :mutant]
end

task spec: 'spec:rspec'
task default: 'spec:all'
