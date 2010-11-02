require 'spec_helper'
require 'tmpdir'

def with_site_structure(files = {}, &block)
  previous_dir = Dir.pwd
  tmpdir = Dir.mktmpdir

  begin
    Dir.chdir(tmpdir)
    files.each do |file, content|
      File.open(file, 'w') do |f|
        f.write(content)
      end
    end

    yield
  ensure
    Dir.chdir(previous_dir)
    FileUtils.rm_rf(tmpdir, :secure => true)
  end
end

def with_rules(rules, &block)
  with_site_structure('Rules.rb' => rules, &block)
end

describe "Rules file" do
  let(:compile_action) { ->{ Nanoc3::Site.new(Nanoc3::Site::DEFAULT_CONFIG).compile } }

  context "with trivially failing rules" do
    let(:message) { 'kablammo!' }
    let(:rules) do
      %{raise NotImplementedError.new("#{message}")}
    end

    it "should not compile" do
      with_rules(rules) do
        compile_action.should raise_error(NotImplementedError, message)
      end
    end
  end

  context "with trivially passing rules and blank content" do
    let(:rules) do
      ""
    end

    it "should compile" do
      with_rules(rules) do
        compile_action.should_not raise_error
      end
    end
  end
end
