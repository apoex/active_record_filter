require 'rake/testtask'
require 'bundler/gem_tasks'

Rake::TestTask.new do |task|
  task.libs << 'test'
  task.libs << 'lib'
  task.test_files = FileList['test/**/test_*.rb']
end

desc 'Run tests'
task default: :test
