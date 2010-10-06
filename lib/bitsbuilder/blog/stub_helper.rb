module BitsBuilder
  module Blog
    module Stub
      def stub_for(title)
        title.downcase.split.join('-').gsub(/[^A-z0-9\-]/, '')
      end
    end
  end
end
