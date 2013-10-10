require 'spec_helper'

describe DocxTemplater do
  subject{ DocxTemplater.new }
  let(:file_path){ File.expand_path("../../fixtures/newlines.docx",__FILE__) }
  let(:replacements){ {user: 'Mikey', quotes: "Be excellent to eachother ~Bill & Ted\nTyping is not the bottlneck\r\nDo something awesome."} }

  it "can convert newlines with docx equivalents" do
    buffer = subject.replace_file_with_content(file_path, replacements)
    File.open("tmp/test.docx", "wb") {|f| f.write(buffer.string) }
  end
end

