module BitsBuilder
  module Blog
    module Post
      def article?
        self[:kind] == 'article' &&
          !self[:created_at].nil? &&
          !self[:entity_id].nil?
      end

      def path_components
        self.identifier.split('/')
      end

      def stub
        self[:stub] || stub_for(self[:title])
      end

      def suffix
        [self.stub]
      end

      def canonicalize!
        self.tap do |item|
          pieces = item.path_components[0...-1]
          item.identifier = [pieces.flatten, item.suffix.flatten, ''].join('/')
        end
      end

      def entity_id
        self[:entity_id]
      end
    end

    class ::Nanoc3::Item
      include BitsBuilder::Blog::Post
    end
  end
end
