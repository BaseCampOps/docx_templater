require 'spec_helper'

describe Docx::PlaceholderObserver do
  describe "#next_node" do
    subject{ Docx::PlaceholderObserver.new(data_provider) }
    let(:data_provider){ r = double("data_provider") }
    it "finds placeholders as it is given text nodes" do
      data_provider.should_receive(:[]).with(:title).and_return("The Thing")
      n1 = REXML::Text.new("dflkja sdf ||title|| slkjasdlkj")
      n1.should_receive(:value=).with('dflkja sdf The Thing slkjasdlkj')

      subject.next_node(n1)
    end

    it "finds placeholders among several nodes" do
      data_provider.should_receive(:[]).with(:title).and_return('The Thing')
      n1 = REXML::Text.new('booyah, (&&IJH))OJ |')
      n1.should_receive(:value=).with('booyah, (&&IJH))OJ The Thing')
      n2 = REXML::Text.new('|tit')
      n2.should_receive(:value=).with('')
      n3 = REXML::Text.new('le|| asdf093n38hfaj')
      n3.should_receive(:value=).with(' asdf093n38hfaj')

      subject.next_node(n1)
      subject.next_node(n2)
      subject.next_node(n3)
    end

    it "handles multiple placeholders in a single node correctly" do
      data_provider.should_receive(:[]).with(:title).and_return('Zombie Apocalypse')
      data_provider.should_receive(:[]).with(:subject).and_return('Movie')
      n1 = REXML::Text.new('||title|| is a ||subject||. Okay?')

      subject.next_node(n1)
      n1.value.should == 'Zombie Apocalypse is a Movie. Okay?'
    end

    it "handles nil replacements" do
      data_provider.should_receive(:[]).with(:title).and_return(nil)
      n1 = REXML::Text.new('||title||')
      subject.next_node(n1)
      n1.value.should == ''
    end
  end
end
