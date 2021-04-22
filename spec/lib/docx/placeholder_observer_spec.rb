require 'spec_helper'

describe Docx::PlaceholderObserver do
  describe "#next_node and #end_of_document" do
    subject{ Docx::PlaceholderObserver.new(data_provider) }
    let(:data_provider) do 
      r = double("data_provider")
      r.stub(:has_key? => true)
      r
    end

    shared_examples 'test delimiter' do
      it "finds placeholders as it is given text nodes" do
        data_provider.should_receive(:[]).with(:title).and_return("The Thing")
        n1 = REXML::Text.new("dflkja sdf #{delimiter}title#{delimiter} slkjasdlkj")
        n1.should_receive(:value=).with('dflkja sdf The Thing slkjasdlkj')

        subject.next_node(n1)
        subject.end_of_document
      end


      it "handles multiple placeholders in a single node correctly" do
        data_provider.should_receive(:[]).with(:title).and_return('Zombie Apocalypse')
        data_provider.should_receive(:[]).with(:subject).and_return('Movie')
        n1 = REXML::Text.new("#{delimiter}title#{delimiter} is a #{delimiter}subject#{delimiter}. Okay?")

        subject.next_node(n1)
        subject.end_of_document
        n1.value.should == 'Zombie Apocalypse is a Movie. Okay?'
      end

      it "handles nil replacements" do
        data_provider.should_receive(:[]).with(:title).and_return(nil)
        n1 = REXML::Text.new("#{delimiter}title#{delimiter}")
        subject.next_node(n1)
        subject.end_of_document
        n1.value.should == ''
      end
    end

    context 'default delimiter' do
      let(:delimiter) { '||' }
      subject{ Docx::PlaceholderObserver.new(data_provider) }

      include_examples 'test delimiter'

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
        subject.end_of_document
      end
    end

    context 'custom delimiter' do
      let(:delimiter) { '#' }
      subject{ Docx::PlaceholderObserver.new(data_provider, delimiter: delimiter) }

      include_examples 'test delimiter'
    end

    context 'when delimiter is blank' do
      let(:delimiter) { ' ' }
      it 'raises an error' do
        expect{ Docx::PlaceholderObserver.new(data_provider, delimiter: delimiter) }.to raise_error ArgumentError
      end
    end

    context 'when delimiter is nil' do
      let(:delimiter) { nil }
      it 'raises an error' do
        expect{ Docx::PlaceholderObserver.new(data_provider, delimiter: delimiter) }.to raise_error ArgumentError
      end
    end

    context 'when delimiter contains different chars' do
      let(:delimiter) { '|#' }

      it 'raises an error' do
        expect{ Docx::PlaceholderObserver.new(data_provider, delimiter: delimiter) }.to raise_error ArgumentError
      end
    end
  end
end
