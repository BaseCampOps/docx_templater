require 'spec_helper'

describe Docx::NewlineReplacer do
  let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:p><w:r><w:t>Leslie|paragraph|Knope</w:t></w:r></w:p></w:hdr>" }
  let(:xml_doc){ REXML::Document.new(xml_str) }
  let(:replacer){ Docx::NewlineReplacer.new(xml_doc) }

  it "it replaces \|paragraph| with <w:br/>" do
    replacer.replace
    xml_doc.to_s.should include("<w:t>Leslie<w:br/>Knope</w:t>")
  end

  context "multiple newlines" do
    let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:p><w:r><w:t>Leslie|paragraph|Knope|paragraph|loves|paragraph|Ben|paragraph|Wyatt</w:t></w:r></w:p></w:hdr>" }

    it "replaces all newlines in a single node" do
      replacer.replace
      str = xml_doc.to_s
      str.should include("Leslie<w:br/>Knope")
      str.should include("Ben<w:br/>Wyatt")
    end
  end
end
