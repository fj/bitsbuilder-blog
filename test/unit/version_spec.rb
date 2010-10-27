require 'spec_helper'

module BitsBuilder
  describe 'Blog::VERSION' do
    subject { Blog::VERSION }
    it { should_not be_nil }
    it { should > "0" }
    it { should > "0.0" }
    it { should >= "0.0.1" }
  end
end
