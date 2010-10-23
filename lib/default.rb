# All files in the 'lib' directory will be loaded
# before nanoc starts compiling.
#

include BitsBuilder::Blog::Stub
include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::Rendering

def articles
  @items.select { |i| i[:kind] == 'article' }
end
