require 'spec_helper'
require 'zip/zipfilesystem'
require 'tempfile'
describe WordTemplater do
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
  
  describe "body" do
    it "finds and replaces placeholders in the body of the document" do
      str = get_body_string(file_path)
      str.should include("||title||")
      str.should include("||adjective||")
      str.should_not include("Working Title Please Ignore")
      str.should_not include("FANTASTIC")

      buffer = WordTemplater.replace_file_with_content( file_path, {:title => "Working Title Please Ignore", :adjective => "FANTASTIC"} )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should_not include("||title||")
      str.should_not include("||adjective||")
      str.should include("Working Title Please Ignore")
      str.should include("FANTASTIC")
    end
  end
end