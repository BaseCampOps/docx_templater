module Docx
  class NodesToFix
    attr_accessor :node_list, :current_node, :value
    def initialize
      forget
    end

    def forget
      @current_node = nil
      @node_list = []
      @value = ''
    end

    def remember(node,idx)
      new_node = current_node.nil? || current_node != node
      if new_node
        @current_node = node
        @node_list << {:node => node, :range => idx..idx}
      else
        @node_list.last[:range] = (node_list.last[:range].min)..idx
      end
    end

    def fix
      node_list.each do |obj|
        node = obj[:node]
        range = obj[:range]
        new_val = node.value
        new_val[range] = value
        node.value = new_val
        self.value = ''
      end
    end
  end
end
