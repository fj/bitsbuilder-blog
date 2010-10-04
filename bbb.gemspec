lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'bbb/version'

Gem::Specification.new do |s|
  s.name        = "bbb"
  s.version     = BitsBuilder::Blog::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Feminella"]
  s.email       = ["johnf@bitsbuilder.com"]
  s.homepage    = "http://github.com/fj/bitsbuilder-blog"
  s.summary     = "Write once, read anywhere."
  s.description = "BitsBuilder's blog."

  s.required_rubygems_version = ">= 1.3.6"

  # Runtime dependencies.
  {
    'nanoc' => ['>= 3.1']
  }.each { |dep, reqs| s.add_runtime_dependency(dep, reqs) }
  
  # Development dependencies.
  {
  }.each { |dep, reqs| s.add_development_dependency(dep, reqs) }

  s.files        = Dir.glob("{bin,lib}/**/*") + Dir.glob('*.md')
  s.executables  = []
  s.require_path = 'lib'
end
