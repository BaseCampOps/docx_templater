require 'spec_helper'
require 'zip/zipfilesystem'
require 'tempfile'
describe WordTemplater do
  let(:replacements){ { foo: "bar", key: "value" } }
  let(:file_path){ File.expand_path("../../fixtures/TestFile.docx",__FILE__) }
  
  describe "headers and footers" do    
    it "finds and replaces placeholders in the header" do
      str = get_header_string(file_path)
      str.should include("||header||")
      str.should_not include("Woohoo!")

      buffer = WordTemplater.replace_file_with_content( file_path, {:header => "Woohoo!"} )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_header_string(tf.path)
      str.should_not include("||header||")
      str.should include("Woohoo!")
    end

    it "finds and replaces placeholders in the footer" do
      str = get_footer_string(file_path)
      str.should include("||date||")
      str.should include("||type||")
      str.should_not include("2012-01-01")
      str.should_not include("Footsies")

      buffer = WordTemplater.replace_file_with_content( file_path, {:date => "2012-01-01", :type => "Footsies"} )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_footer_string(tf.path)
      str.should_not include("||date||")
      str.should_not include("||type||")
      str.should include("2012-01-01")
      str.should include("Footsies")
    end
  end
end