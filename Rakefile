require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
require 'cucumber'
require 'cucumber/rake/task'
require 'nanoc3/tasks'

module BitsBuilder
  module Configuration
    def self.root
      File.expand_path('..', __FILE__)
    end

    # Expects a configuration file for foo to be in `config/.foo`.
    def self.configuration_file_for(config)
      path = File.expand_path(File.join('..', 'config', ".#{config.to_s.downcase}"), __FILE__)
      raise ArgumentError.new("#{config} does not point to a file in `config/*`") unless File.exists?(path)
      File.open(path)
    end

    def self.configuration_for(config)
      configuration_file_for(config).lines.to_a.map(&:strip)
    end
  end
end

desc 'Build site'
task :build => [:clear] do
  system 'nanoc compile'
end

desc 'Serve site on localhost:8765'
task :serve do
  system 'nanoc autocompile --port 8765'
end

desc 'Delete contents of output directory'
task :clear do
  FileUtils.rm_rf(Dir.glob('output/*'))
end

task :test => ['test:all']
namespace :test do
  desc 'Run unit tests'
  RSpec::Core::RakeTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*[_-]spec.rb'

    helper = File.expand_path('test/unit/spec_helper.rb')
    opts = BitsBuilder::Configuration.configuration_for(:rspec)

    t.rspec_opts = ['--require', helper] + opts
  end

  desc 'Run Cucumber features'
  Cucumber::Rake::Task.new(:integrations) do |t|
    features_dir = 'test/integration'
    t.cucumber_opts = [
      "#{features_dir}",
      "--format pretty"
    ].join(' ')
  end

  desc 'Run all tests'
  task :all => [:units, :integrations] do
  end
end

task :default => ['test:all']
