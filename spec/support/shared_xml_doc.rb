shared_context "XML Doc" do
  let(:xml){ REXML::Document.new(File.read('spec/fixtures/sample.xml')) }
  let(:root){ xml.root }
  let(:first){ REXML::XPath.match(root, '//w:t', root.namespaces).first.children.first }
  let(:second){ REXML::XPath.match(root, '//w:t', root.namespaces).last.children.first }
end
