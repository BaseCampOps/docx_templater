module Docx
  class NewlineReplacer
    def initialize(doc)
      @doc = doc
    end

    def replace
      walk(doc.root)
    end

    private
    attr_reader :doc

    def walk(node)
      node.children.each do |child|
        if child.node_type == :text
          replace_text_node(node,child)
        else
          walk(child)
        end
      end
    end

    def replace_text_node(parent, node)
      text = node.to_s
      list = text.split("\n")
        .map{|str| str_to_text_node(str)}
        .flat_map{ |txt| [txt,br] }
      list.pop #remove trailing br
      list.reverse.each do |new_node|
        parent.insert_after(node, new_node)
      end
      node.remove
    end

    def br
      br = REXML::Element.new('w:br')
      br.add_attribute('w:type', 'text-wrapping')
      br
    end

    def str_to_text_node(str)
      REXML::Text.new(str)
    end
  end
end
