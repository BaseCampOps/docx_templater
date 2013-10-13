require 'spec_helper'

describe "DocxTemplater :convert_newlines" do
  subject{ DocxTemplater.new(convert_newlines: true) }
  let(:file_path){ File.expand_path("../../fixtures/newlines.docx",__FILE__) }
  let(:replacements){ {user: 'Mikey', quotes: "Be excellent to eachother ~Bill & Ted\nTyping is not the bottlneck\r\nDo something awesome."} }
  let(:buffer){ subject.replace_file_with_content(file_path, replacements) }
  let(:tempfile) do
    tf = Tempfile.new(["spec","docx"]) 
    tf.write(buffer.string)
    tf.close
    tf
  end
  let(:body){ get_body_string(tempfile.path) }

  context "option on" do
    let(:options){ {convert_newlines: true} }
    it "can convert newlines with docx equivalents" do
      body.should_not include("||quotes||")
      body.should include("Be excellent to eachother ~Bill &amp; Ted<w:br w:type='text-wrapping'/>Typing is not the bottlneck<w:br w:type='text-wrapping'/>Do something awesome.")
    end
  end

  context "option off" do
    let(:options){ {convert_newlines: false} }
    it "leaves newlines untouched" do
      body.should_not include("||quotes||")
      body.should include(replacements[:quotes])
    end
  end
end

