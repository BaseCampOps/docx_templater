require 'spec_helper'

describe Docx::NewlineReplacer do
  let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:t>Leslie\nKnope</w:t></w:hdr>" }
  let(:xml_doc){ REXML::Document.new(xml_str) }
  let(:replacer){ Docx::NewlineReplacer.new(xml_doc) }

  it "it replaces \\n with <w:br/>" do
    replacer.replace
    xml_doc.to_s.should include("<w:t>Leslie</w:t><w:br/><w:t>Knope</w:t>")
  end

  context "multiple newlines" do
    let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:t>Leslie\nKnope\nloves\nBen\nWyatt</w:t></w:hdr>" }

    it "replaces all newlines in a single node" do
      replacer.replace
      str = xml_doc.to_s
      str.should include("<w:t>Leslie</w:t><w:br/><w:t>Knope</w:t><w:br/><w:t>loves</w:t><w:br/><w:t>Ben</w:t><w:br/><w:t>Wyatt</w:t>")
    end
  end
end
