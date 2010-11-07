module Builder
  class ContentFile
    attr_accessor :metadata
    attr_accessor :content
    attr_accessor :path

    def initialize(p)
      self.metadata = {}
      self.path     = p
      self.content  = ""
    end

    def to_metadata_block
      ''.tap do |s|
        s << "---\n"
        self.metadata.each { |k, v| s << "#{k.gsub(' ', '_')}: #{v}\n" }
        s << "---\n"
      end
    end

    def to_content_block
      self.content
    end

    def to_s
      self.to_metadata_block + self.to_content_block
    end
  end
end

module PostBuilder
  def post
    @post ||= {}
  end

  def suppress
    serr = $stdout.dup
    sout = $stderr.dup

    begin
      require 'tempfile'
      f = Tempfile.new('suppressed-output')
      $stdout.reopen(f)
      $stderr.reopen(f)
      yield
    ensure
      $stdout.reopen(sout)
      $stderr.reopen(serr)
    end
  end
end

World(PostBuilder)

Transform %r{^(file|post) "([^"]+)"$} do |kind, path|
  prefix = case kind
  when "post" then ['content', 'posts']
  when "file" then [nil]
  end

  [prefix, path].flatten.compact.join(File::Separator)
end

Given %r{^I have a (\w+ "[^"]+") with metadata:$} do |path, fields|
  @files ||= {}
  fields.hashes.each do |hash|
    raise ArgumentError.new("didn't understand metadata") unless hash['value'] && hash['field']
    Given %{I have a file "#{path}" with metadata "#{hash['field']}" set to "#{hash['value']}"}
  end
end

Given %r{^I have a (\w+ "[^"]+") with metadata "([\w ]+)" set to "(.+)"$} do |path, field, value|
  @files ||= {}
  (@files[path] ||= Builder::ContentFile.new(path)).tap do |f|
    f.metadata[field] = value
  end
end

Given %r{^I have a (\w+ "[^"]+") with(?: content)?:$} do |path, content|
  dir = File.dirname(path)
  FileUtils.mkpath(dir) unless File.exists?(dir) && File.directory?(dir)
  f = File.open(path, 'w')
  f.write(content)
  f.close

  @files ||= {}
  (@files[path] ||= Builder::ContentFile.new(path)).tap { |f| f.content = content }
end

Given %r{^I set the ([\w ]+?) metadata on "([^"]+)" to (.+)$} do |metadata, path, value|
  @files.find { |f| f.path == path }[metadata.gsub(' ', '_').to_sym] = value
end

When %r{^I compile my site$} do
  When %{I save all files}
  @site = Nanoc3::Site.new('.')
  @result = ->{ suppress { @site.compile } }
end

When %r{^I save all files$} do
  @files.each do |path, file|
    File.open(path, 'w').tap do |f|
      f.write(file.to_s)
      f.close
    end
  end
end

Then %r{^the result should be successful$} do
  ->{ @result.call }.should_not raise_error
end

Then %r{^I should see the files I added$} do
  @files.each do |path, file|
    require 'time'
    prefix =  ['output', 'posts']
    prefix += file.metadata['created at'].split(' ').first.split('-')
    stub   =  [file.metadata['stub']]
    suffix =  ['index.html']

    Then %{I should see a file "#{(prefix + stub + suffix).flatten.join(File::Separator)}"}
  end
end

Then %r{^I should see a file "([^"]+)"$} do |path|
  File.exists?(path).should be_true
end
