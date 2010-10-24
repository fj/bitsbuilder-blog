# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
#

include BitsBuilder::Blog::Stub
include BitsBuilder::Blog::Post
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::Rendering

def articles
  @items.select { |i| i.article? }
end

def log(msg)
  puts "                  ---  #{msg}"
end

module RulesHelpers
  def filter_for_extension!(extension)
    case extension
    when 'textile' then lambda { filter :redcloth }
    when 'haml'    then lambda { filter :haml, { :format => :html5 } }
    else
      raise ArgumentError.new("unmapped extension")
    end
  end
end

include RulesHelpers
