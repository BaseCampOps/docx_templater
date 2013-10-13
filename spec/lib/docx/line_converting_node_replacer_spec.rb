require 'spec_helper'
require 'support/shared_xml_doc'

describe Docx::LineConvertingNodeReplacer do
  include_context "XML Doc"
  let(:header){ "Leslie\nKnope" }
  let(:placeholder){ "Tammy\r\nII" }
  let(:replacer){ Docx::LineConvertingNodeReplacer.new }

  it "replaces a single node-range" do
    first_parent = first.parent
    replacer.replace(single_node_range, header)
    first_parent.to_s.should == "<w:t>It even works in headers Leslie<w:br w:type='text-wrapping'/>Knope and another ||place</w:t>"
  end

  it "replaces multiple node ranges" do
    first_parent = first.parent
    second_parent = second.parent
    replacer.replace(double_node_ranges, placeholder)
    replacer.replace(single_node_range, header)
    first_parent.to_s.should == "<w:t>It even works in headers Leslie<w:br w:type='text-wrapping'/>Knope and another Tammy<w:br w:type='text-wrapping'/>II</w:t>"
    second_parent.to_s.should == "<w:t xml:space='preserving'> followed by text</w:t>"
  end
end
