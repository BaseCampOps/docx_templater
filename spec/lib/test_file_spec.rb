require 'spec_helper'
require 'zip/zipfilesystem'
describe "fixtures/TestFile.docx" do
  let(:file_path){ File.expand_path("../../fixtures/TestFile.docx",__FILE__) }
  let(:unzipped){ Zip::ZipFile.new(file_path) }
  it "should contain a header placeholder" do
    entry = unzipped.entries.find do |e| e.name == "word/header2.xml" end
    entry.get_input_stream.read.should include("||header||")
  end

  it "should contain a footer placeholder" do
    pending
  end

  it "should contain a title placeholder" do
    pending
  end

  it "should contain placeholders in a table" do
    pending
  end

  it "should contain multiple copies of the adjective placeholder" do
    pending
  end
end