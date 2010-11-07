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

Given %r{^I author a Textile post with the following content:$} do |content|
  post[:content] = content
end

Given %r{^I author a post$} do
  post
end

Given %r{^I set the post ([\w ]+?) to "([^"]+)"$} do |field, value|
  post.send(:[]=, field.gsub(' ', '_').to_sym, value)
end

Given %r{^I set the post ([\w ]+?) to:$} do |field, content|
  post.send(:[]=, field.gsub(' ', '_').to_sym, content)
end

Given %r{^I save the post(?: as "([^"]+)")?$} do |filename|
  post[:filename] ||= filename
  build(post)
end

When %r{^I compile my site$} do
  @site = Nanoc3::Site.new('.')
  @result = ->{ @site.compile }
end

Then %r{^the result should be successful$} do
  ->{ @result.call }.should_not raise_error
end
