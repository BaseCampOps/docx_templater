module Docx
  class SimpleNodeReplacer
    def replace(node_ranges, value)
      node_ranges.each do |node_range|
        node = node_range[:node]
        range = node_range[:range]
        parent = node.parent
        new_val = node.value
        new_val[range] = value.to_s
        value = nil
        node.value = new_val
        parent.add_attribute('xml:space', 'preserve') if parent && new_val.include?(" ")
      end
    end    
  end
end
