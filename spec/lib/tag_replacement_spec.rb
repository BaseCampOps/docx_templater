require 'spec_helper'
require 'zip/zipfilesystem'
require 'tempfile'
describe DocxTemplater do
  let(:file_path){ File.expand_path("../../fixtures/TestFile.docx",__FILE__) }
  
  describe "headers and footers" do
    let(:replacements){
      {:header => "Woohoo!", :date => "2012-01-01", :type => "Footsies" }
    }
    it "finds and replaces placeholders in the header" do
      str = get_header_string(file_path)
      str.should include("||header||")
      str.should_not include("Woohoo!")

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
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

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
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
      {
        :title => "Working Title Please Ignore",
        :adjective => "FANTASTIC",
        :total_loan_amount_currency_words => "Three Hundred",
        :super_adjective => "BOOYAH",
        :non_string => 200.0,
        :side => "lefty",
        :by_side => "righty",
      }
    }
    it "finds and replaces placeholders in the body of the document" do
      str = get_body_string(file_path)
      str.should include("||title||")
      str.should include("||adjective||")
      str.should_not include("Working Title Please Ignore")
      str.should_not include("FANTASTIC")

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should_not include("||title||")
      str.should_not include("||adjective||")
      str.should_not include("||total_loan_amount_currency_words||")
      str.should include("Working Title Please Ignore")
      str.should include("FANTASTIC")
      str.should include("Three Hundred")
    end
    
    it "finds and replaces placeholders with formatting" do
      str = get_body_string(file_path)
      fragments = ['h ||','supe','r_adject','ive','| f']
      fragments.each do |fragment|
        str.should include(fragment)
      end

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      fragments.each do |fragment|
        str.should_not include(fragment)
      end
      str.should include('BOOYAH')
    end

    it "finds and replaces with content that is not a string" do
      str = get_body_string(file_path)
      str.should include("||non_string||")
      str.should_not include("200.0")

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should_not include("||non_string||")
      str.should include("200.0")
    end

    it "If no data provider key matches, it should leave the placeholder" do
      str = get_body_string(file_path)
      str.should include("||stay_on_the_page")

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should include("||stay_on_the_page")
    end

    it "It should handle side by side placeholders" do
      str = get_body_string(file_path)
      str.should include("side")
      str.should include("by_side")

      buffer = ::DocxTemplater.new.replace_file_with_content( file_path, replacements )
      tf = Tempfile.new(["spec","docx"])
      tf.write buffer.string
      tf.close

      str = get_body_string(tf.path)
      str.should_not include("side")
      str.should_not include("by_side")
      str.should include("lefty")
      str.should include("righty")
    end

  end
end
