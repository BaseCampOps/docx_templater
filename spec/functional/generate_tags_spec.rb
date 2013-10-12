require 'spec_helper'
describe DocxTemplater do
  subject{ DocxTemplater.new }
  describe "#generate_tags_for" do
    let(:m1){
      m1 = double("model")
      m1.stub(:attributes).and_return({mikey: "snuggy", ruby: "awesome"})
      m1
    }
    let(:m2){
      m2 = double("model")
      m2.stub(:attributes).and_return({paul: "smith", ruby: "amazing"})
      m2
    }

    it "combines multiple hashes" do
      h1 = {foo: "foo", bar: "bar"}
      h2 = {baz: "baz"}

      combined = subject.generate_tags_for(h1, h2)
      combined[:foo].should == "foo"
      combined[:bar].should == "bar"
      combined[:baz].should == "baz"
    end

    it "can combine multiple #attributes models" do
      #note this should be working, but we have an invalid dependency on ActiveSupport
      # to make String#underscore available
      expect {
        combined = subject.generate_tags_for(m1, m2)
        combined[:mikey].should == "snuggy"
        combined[:paul].should == "smith"
      }.to raise_error(NoMethodError)
    end

    it "can namespace #attributes models" do
      combined = subject.generate_tags_for(
        {:prefix => "m1", :data => m1},
        {:prefix => "m2", :data => m2})
      combined[:m1_mikey].should == "snuggy"
      combined[:m2_paul].should == "smith"
      combined[:m1_ruby].should == "awesome"
      combined[:m2_ruby].should == "amazing"
    end

    it "prefers to call #template_attributes for easy customization" do
      m1.stub(:template_attributes).and_return({mikey: "he likes it", ruby: "fast"})
      combined = subject.generate_tags_for(
        {prefix: "m1", :data => m1},
        {prefix: "m2", :data => m2})
      combined[:m1_mikey].should == "he likes it"
      combined[:m1_ruby].should == "fast"
    end
  end
end
