require 'spec_helper'
require 'zip/zipfilesystem'
require 'tempfile'
describe WordTemplater do
  let(:file_path){ File.expand_path("../../fixtures/TestFile.docx",__FILE__) }
  
  describe "headers and footers" do
    let(:replacements){
      {:header => "Woohoo!", :date => "2012-01-01", :type => "Footsies" }
    }
    it "finds and replaces placeholders in the header" do
      str = get_header_string(file_path)
      str.should include("||header||")
      str.should_not include("Woohoo!")

      buffer = ::WordTemplater.replace_file_with_content( file_path, replacements )
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

      buffer = ::WordTemplater.replace_file_with_content( file_path, replacements )
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
    let(:replacements){
      {:title => "Working Title Please Ignore", :adjective => "FANTASTIC"}
    }
    it "finds and replaces placeholders in the body of the document" do
      str = get_body_string(file_path)
      str.should include("||title||")
      str.should include("||adjective||")
      str.should_not include("Working Title Please Ignore")
      str.should_not include("FANTASTIC")

      buffer = ::WordTemplater.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should_not include("||title||")
      str.should_not include("||adjective||")
      str.should include("Working Title Please Ignore")
      str.should include("FANTASTIC")
    end
    
    it "finds and replaces placeholders with formatting" do
      str = get_body_string(file_path)
      str.should include('||a</w:t></w:r><w:r><w:t>dj</w:t></w:r><w:r w:rsidRPr="009E187F"><w:rPr><w:u w:val="single"/></w:rPr><w:t>ect</w:t></w:r><w:r><w:t>ive|</w:t></w:r><w:r w:rsidRPr="009E187F"><w:rPr><w:i/></w:rPr><w:t>|')

      buffer = ::WordTemplater.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should_not include('||a</w:t></w:r><w:r><w:t>dj</w:t></w:r><w:r w:rsidRPr="009E187F"><w:rPr><w:u w:val="single"/></w:rPr><w:t>ect</w:t></w:r><w:r><w:t>ive|</w:t></w:r><w:r w:rsidRPr="009E187F"><w:rPr><w:i/></w:rPr><w:t>|')
      str.should include('FANTASTIC</w:t></w:r><w:r><w:t></w:t></w:r><w:r w:rsidRPr="009E187F"><w:rPr><w:u w:val="single"/></w:rPr><w:t></w:t></w:r><w:r><w:t></w:t></w:r><w:r w:rsidRPr="009E187F"><w:rPr><w:i/></w:rPr><w:t>')
    end
  end
end