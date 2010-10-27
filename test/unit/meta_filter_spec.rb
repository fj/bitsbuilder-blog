require 'spec_helper'
require 'bitsbuilder/blog/meta_filter'

module BitsBuilder
  module Blog
    describe MetaFilter do
      let(:filter_name) { 'arbitrary-filter' }
      let(:delimiter) { {:open => '$$', :close => '/$$'} }
      let(:content) {
        "before-unfiltered-content #{delimiter[:open]}" \
        "(#{filter_name})filtered-content" \
        "#{delimiter[:close]} after-unfiltered-content"
      }

      context "with a valid filter specification" do
        let(:filtered_content) { 'FILTERED-CONTENT' }
        let(:filter) {
          fake_filter_instance = mock('fake filter', :run => filtered_content)
          Class.new.tap do |fake_filter_class|
            fake_filter_class.stub!(:new).and_return(fake_filter_instance)
          end
        }

        before(:each) do
          Nanoc3::Filter.should_receive(:named).with(filter_name).and_return(filter)
        end

        it "should process without errors" do
          -> { subject.run(content) }.should_not raise_error
        end

        it "should produce filtered content" do
          subject.run(content).should include(filtered_content)
        end

        it "should produce filtered content for each instance of the filter" do
          aggregated_content = [content, content, content]
          subject.run(aggregated_content.join).
            scan(filtered_content).size.should == aggregated_content.size
        end

        it "should not remove unfiltered content before the filter is invoked" do
          subject.run(content).should include(content.split.first)
        end

        it "should not remove unfiltered content after the filter is invoked" do
          subject.run(content).should include(content.split.last)
        end
      end

      context "with a bogus filter specification" do
        before(:each) do
          Nanoc3::Filter.should_receive(:named).with(filter_name).and_return(nil)
        end

        it "should raise an exception when run" do
          -> { subject.run(content) }.should raise_error(Nanoc3::Errors::UnknownFilter)
        end
      end
    end
  end
end
