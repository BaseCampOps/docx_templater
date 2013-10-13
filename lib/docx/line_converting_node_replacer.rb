module Docx
  class LineConvertingNodeReplacer
    def replace(node_ranges, value)
      node_ranges.each do |node_range|
        fix_node(node_range[:node], node_range[:range], value)
        value = ''
      end
    end

    private
    def fix_node(node, range, value)
      parent = node.parent
      new_value = node.value
      new_value[range] = value
      new_nodes(new_value).reverse.each do |new_node|
        parent.insert_after(node, new_node)
      end
      node.remove
    end

    def new_nodes(str)
      node_list = str.split(/\r*\n/).map do |str|
        REXML::Text.new(str)
      end
      node_list = node_list.inject([]) do |list, node|
        list << node
        br = REXML::Element.new('w:br')
        br.add_attribute('w:type', "text-wrapping")
        list << br
      end
      node_list.pop
      node_list
    end
  end
end
