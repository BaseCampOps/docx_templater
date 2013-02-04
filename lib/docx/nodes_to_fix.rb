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

    def remember(node, index)
      new_node = current_node.nil? || current_node != node
      if new_node
        @current_node = node
        @node_list << {:node => node, :range => index..index}
      else
        @node_list.last[:range] = (node_list.last[:range].min)..index
      end
    end

    def fix
      @node_list.each do |obj|
        node = obj[:node]
        range = obj[:range]
        new_val = node.value
        new_val[range] = value.to_s || ''
        node.value = new_val
        if new_val =~ /^\s+/ && node.parent
          node.parent.add_attribute('xml:space', 'preserve')
        end
        self.value = nil
      end
    end
  end
end
