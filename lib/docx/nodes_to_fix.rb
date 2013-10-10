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
        parent = node.parent
        range = obj[:range]
        new_val = node.value
        new_val[range] = value.to_s || ''
        new_nodes(new_val).each do |new_node|
          parent.insert_after(node,new_node)
        end
        node.remove
        if new_val =~ /^\s+/ && parent
          parent.add_attribute('xml:space', 'preserve')
        end
        self.value = nil
      end
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
      node_list.reverse
    end
  end
end
