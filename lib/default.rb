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

def items_for_tags
  @items_for_tags ||= Hash.new { |h, k| h[k] = [] }.tap do |hash|
    items.select { |item| item[:tags] && !item[:tags].empty? }.each do |item|
      item[:tags].each do |tag|
        hash[tag] << item
      end
    end
  end
end

class Route
  attr_accessor :components
  attr_accessor :name

  def initialize(name, *pieces)
    self.components ||= pieces
    self.name       ||= name
  end

  def route
    self.components.flatten.join('/').tap do |route|
    end
  end

  def raw_route
    self.components.map { |c| c == name ? "#{c}.raw" : c }.flatten.join('/').tap do |route|
    end
  end
end

module RouteHelpers
  def route_for_article(item)
    route_for_post(item)
  end

  def route_for_post(item)
    prefix = 'posts'

    t = Time.parse(item[:created_at])
    entry_year  = t.strftime("%Y")
    entry_month = t.strftime("%m")
    entry_day   = t.strftime("%d")

    date = [entry_year, entry_month, entry_day]

    name = "#{item.stub}"

    default_index = self.config[:default_index]
    raise ArgumentError.new("no default index supplied") unless default_index
    suffix = default_index

    Route.new(name, '', prefix, date.flatten, name, suffix)
  end
end

module RulesHelpers
  include RouteHelpers

  def compile_for_item(item)
    log("compiling #{item.identifier}")
    filter(:meta)
    extensions_for_item(item).each do |extension|
      log("  ... filtering for #{extension}")
      filter_for_extension!(extension).call
    end
  end

  def extensions_for_item(item)
    (item[:extension] || 'html.haml').split('.')
  end

  def filter_for_extension!(extension)
    case extension
    when 'textile'  then lambda { filter :redcloth }
    when 'haml'     then lambda { filter :haml, { :format => :html5 } }
    when 'markdown' then lambda { filter :rdiscount }
    else
      log("  ... ignoring unknown extension #{extension}")
      lambda {}
    end
  end

  def layout_for(item, kind = nil)
    kind ||= item.kind
    layout_stack = case kind
    when :posts then ['content/post', 'main']
    when :pages then ['content/page', 'main']
    else             ['home']
    end

    log("laying out #{layout_stack.inspect} (#{kind}) => #{item.identifier}")
    layout_stack.each do |l|
      layout(l)
    end
  end

  def route_for(kind, item)
    self.send(:"route_for_#{kind.to_s}", item).tap do |route|
    end
  end
end

include RulesHelpers
