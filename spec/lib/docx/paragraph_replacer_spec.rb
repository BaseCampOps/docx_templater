require 'spec_helper'

describe Docx::ParagraphReplacer do
  let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:p><w:r><w:t>Leslie|paragraph|Knope</w:t></w:r></w:p></w:hdr>" }
  let(:xml_doc){ REXML::Document.new(xml_str) }
  let(:replacer){ Docx::ParagraphReplacer.new(xml_doc) }

  it "it replaces |paragraph| with </w:t></w:r></w:p><w:p><w:r><w:t>" do
    replacer.replace
    xml_doc.to_s.should include("<w:t>Leslie</w:t></w:r></w:p><w:p><w:r><w:t>Knope</w:t>")
  end

  context "multiple new paragraphs" do
    let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:p><w:r><w:t>Leslie|paragraph|Knope|paragraph|loves|paragraph|Ben|paragraph|Wyatt</w:t></w:r></w:p></w:hdr>" }

    it "replaces all new paragraphs in a single node" do
      replacer.replace
      str = xml_doc.to_s
      str.should include("Leslie</w:t></w:r></w:p><w:p><w:r><w:t>Knope")
      str.should include("Ben</w:t></w:r></w:p><w:p><w:r><w:t>Wyatt")
    end
  end
  
  context "multiple new paragraphs and new lines" do
    let(:xml_str){ "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?><w:hdr xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\"><w:p><w:r><w:t>Leslie|paragraph|Knope loves|paragraph|Ben|paragraph|Wyatt</w:t></w:r></w:p></w:hdr>" }

    it "replaces all newlines in a single node with new paragraphs also" do
      replacer.replace
      str = xml_doc.to_s
      str.should include("Leslie</w:t></w:r></w:p><w:p><w:r><w:t>Knope")
      str.should include("loves</w:t></w:r></w:p><w:p><w:r><w:t>Ben")
      str.should include("Ben</w:t></w:r></w:p><w:p><w:r><w:t>Wyatt")
    end
  end
  
  #deal with formating of new prgph after by copying pPr or rPr elements
end
