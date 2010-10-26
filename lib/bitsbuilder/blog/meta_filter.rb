module BitsBuilder
  module Blog
    class MetaFilter < Nanoc3::Filter
      identifier :meta
      type :text

      def run(content, params = {})
        params = {:open => '$$', :close => '/$$'}.merge(params)
        matcher = /
          (                                 (?# all the content)
          #{Regexp.escape(params[:open])}   (?# opening delimiter)
          (?:\(([^()]+)\))?                 (?# filter name; optional; contains anything except parentheses)
          (.*?)                             (?# stingy-match content)
          #{Regexp.escape(params[:close])}  (?# closing delimiter)
          )
          /mx
        content.dup.tap do |buf|
          content.scan(matcher).uniq.each do |all_content, filter_name, matched_content|
            filter_class = Nanoc3::Filter.named(filter_name)
            raise Nanoc3::Errors::UnknownFilter.new(filter_name) if filter_class.nil?

            filtered_content = filter_class.new.run(matched_content)
            buf.gsub!(all_content, filtered_content)
          end
        end
      end
    end
  end
end
