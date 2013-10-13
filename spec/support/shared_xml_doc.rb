shared_context "XML Doc" do
  let(:xml){ REXML::Document.new(File.read('spec/fixtures/sample.xml')) }
  let(:root){ xml.root }
  let(:first){ REXML::XPath.match(root, '//w:t', root.namespaces).first.children.first }
  let(:second){ REXML::XPath.match(root, '//w:t', root.namespaces).last.children.first }
  let(:single_node_range){ [{node: first, range: 25..34}] }
  let(:double_node_ranges){ [{node: first, range: 48..55},{node: second, range: 0..7}] }
end
