module EnvironmentBuilder
  attr_accessor :environment

  def environment
    @env ||= EnvironmentBuilder::Environment.new
  end

  class Environment
    DefaultContent = ['Rules', 'config.yaml', 'layouts', 'lib']
    require 'tmpdir'

    def initialize
      @site_dir = Dir.pwd
      @tmp_dir  = Dir.mktmpdir
      @to_create = {}
      @to_copy   = []
    end

    def add(*paths)
      paths.each do |p|
        if p.kind_of?(Hash)
          @to_create.merge(p)
        elsif File.exists?(p)
          @to_copy << File.expand_path(p)
          @to_copy.uniq!
        else
          raise ArgumentError.new("invalid path #{p}")
        end
      end
    end

    def write
      @to_copy.each do |path|
        FileUtils.cp_r(path, @tmp_dir)
      end

      @to_create.each do |item, content|
        File.open(item, 'w').tap { |f| f.write(content) }.close
      end
    end

    def setup_environment
      Dir.chdir(@tmp_dir)
    end

    def teardown_environment
      Dir.chdir(@site_dir)
      FileUtils.rm_rf(@tmp_dir, :secure => true)
    end
  end
end

World(EnvironmentBuilder)

Around('@separate-environment') do |scenario, block|
  @e ||= EnvironmentBuilder::Environment.new
  @e.add(*EnvironmentBuilder::Environment::DefaultContent)

  begin
    @e.setup_environment
    @e.write
    block.call
  ensure
    @e.teardown_environment
  end
end
