require 'rake'
require 'rspec/core'
require 'rspec/core/rake_task'
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

task :test => ['test:all']
namespace :test do
  desc 'run unit tests'
  RSpec::Core::RakeTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*[_-]spec.rb'

    helper = File.expand_path('test/unit/spec_helper.rb')
    opts = BitsBuilder::Configuration.configuration_for(:rspec)

    t.rspec_opts = ['--require', helper] + opts
  end

  desc 'run all tests'
  task :all => [:units] do
  end
end

task :default => ['test:all']
