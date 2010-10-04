require 'rake'

module BitsBuilder
  module Configuration
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
