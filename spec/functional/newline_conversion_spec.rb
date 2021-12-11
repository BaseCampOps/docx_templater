require 'spec_helper'

describe "DocxTemplater :convert_newlines" do
  subject{ DocxTemplater.new(options) }
  let(:file_path){ File.expand_path("../../fixtures/newlines.docx",__FILE__) }
  let(:replacements){ {user: 'Mikey', quotes: "Be excellent to eachother ~Bill and Ted\nTyping is not the bottlneck\r\nDo something awesome."} }
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
      body.should include("<w:t>Be excellent to eachother ~Bill and Ted</w:t><w:br/><w:t>Typing is not the bottlneck</w:t><w:br/><w:t>Do something awesome.</w:t>")
    end

    it "does not double escape special characters" do
      replacements[:quotes] = "Be excellent to eachother ~Bill & Ted's"
      body.should include("<w:t>Be excellent to eachother ~Bill &amp; Ted&apos;s</w:t>")
    end
  end

  context "option off" do
    let(:options){ {convert_newlines: false} }
    it "leaves newlines untouched" do
      body.should_not include("||quotes||")
      body.should include("Be excellent to eachother ~Bill and Ted\nTyping is not the bottlneck\nDo something awesome.")
    end
  end

  context "default" do
    let(:options){ {} }
    it "converts newlines" do
      body.should include("Bill and Ted</w:t><w:br/><w:t>Typing")
    end
  end
end

