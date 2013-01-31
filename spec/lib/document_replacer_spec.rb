require 'spec_helper'
describe Docx::DocumentReplacer do
  subject{ Docx::DocumentReplacer.new(xml_str, data_provider)}
  let(:xml_str){ File.read( File.expand_path('spec/fixtures/header2.xml') )}
  let(:data_provider){ double("data_provider", :[] => "Mikey Header") }
  it "walks an xml string and replaces values" do
    xml_str.should include('||header||')

    subject.replaced.should_not include('||header||')
    subject.replaced.should include('Mikey Header')
  end
end
