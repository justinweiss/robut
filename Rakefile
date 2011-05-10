require 'rake/testtask'
require 'rake/rdoctask'
require 'bundler'
Bundler::GemHelper.install_tasks

task :default => :test
task :build => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

Rake::RDocTask.new do |rd|
  rd.main = "README.rdoc"
  rd.rdoc_files.include("README.rdoc", "lib/**/*.rb")
  rd.rdoc_dir = 'doc'
end

