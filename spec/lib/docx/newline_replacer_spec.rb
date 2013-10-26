require 'spec_helper'

describe Docx::NewlineReplacer do
  let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:t>Leslie\nKnope</w:t></w:hdr>" }
  let(:xml_doc){ REXML::Document.new(xml_str) }
  let(:replacer){ Docx::NewlineReplacer.new(xml_doc) }

  it "it replaces \\n with <w:br/>" do
    replacer.replace
    xml_doc.to_s.should include("<w:t>Leslie<w:br w:type='text-wrapping'/>Knope</w:t>")
  end
end
