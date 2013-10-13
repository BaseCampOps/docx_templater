require 'spec_helper'
require 'support/shared_xml_doc'

describe Docx::SimpleNodeReplacer do
  include_context "XML Doc"
  let(:header){ "Leslie Knope" }
  let(:placeholder){ "Tammy II" }
  let(:replacer){ Docx::SimpleNodeReplacer.new }

  it "replaces a single node-range" do
    replacer.replace(single_node_range, header)
    first.value.should == "It even works in headers Leslie Knope and another ||place"
  end

  it "replaces multiple node ranges" do
    replacer.replace(double_node_ranges, placeholder)
    replacer.replace(single_node_range, header)
    first.value.should == "It even works in headers Leslie Knope and another Tammy II"
    second.value.should == " followed by text"
    second.parent.attribute('xml:space').value.should == 'preserve'
  end
end
