require 'spec_helper'

describe Docx::PlaceholderObserver do
  describe "#next_node" do
    subject{ Docx::PlaceholderObserver.new(data_provider) }
    let(:data_provider){ r = double("data_provider") }
    it "finds placeholders as it is given text nodes" do
      data_provider.should_receive(:[]).with('title').and_return("The Thing")
      n1 = REXML::Text.new("dflkja sdf ||title||  slkjasdlkj")

      subject.next_node(n1)
    end
  end
end
