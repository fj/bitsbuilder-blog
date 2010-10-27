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

class Route
  attr_accessor :components
  attr_accessor :name

  def initialize(name, *pieces)
    self.components ||= pieces
    self.name       ||= name
  end

  def route
    self.components.flatten.join('/').tap do |route|
      log("routing `#{route}`")
    end
  end

  def raw_route
    self.components.map { |c| c == name ? "#{c}.raw" : c }.flatten.join('/').tap do |route|
      log("routing raw `#{route}`")
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

    suffix = "index.#{item[:extension].split('.').first}"

    Route.new(name, '', prefix, date.flatten, name, suffix)
  end
end

module RulesHelpers
  include RouteHelpers

  def compile_for_item(item)
    log("compiling #{item.identifier}")
    filter(:meta)
    item[:extension].split('.')[1..-1].each do |filter|
      log("  ... filtering for #{filter}")
      filter_for_extension!(filter).call
    end
  end

  def filter_for_extension!(extension)
    case extension
    when 'textile'  then lambda { filter :redcloth }
    when 'haml'     then lambda { filter :haml, { :format => :html5 } }
    when 'markdown' then lambda { filter :rdiscount }
    else
      raise ArgumentError.new("unmapped extension `#{extension}`")
    end
  end

  def layout_for(item, kind = nil)
    kind ||= item.identifier.split('/').reject { |i| i.blank? }.first.to_sym
    target = case kind
    when :posts then 'main'
    when :pages then 'home'
    else             'home'
    end

    log("laying out #{target} (#{kind}) => #{item.identifier}")
    layout target
  end

  def route_for(kind, item)
    self.send(:"route_for_#{kind.to_s}", item).tap do |route|
      log("routing for   #{item} (#{kind.to_s})")
      log("  route components are: #{route.components}")
    end
  end
end

include RulesHelpers
