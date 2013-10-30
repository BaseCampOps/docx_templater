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
        replace_text_node_or_continue_walking(node, child)
      end
    end

    def replace_text_node_or_continue_walking(node, child)
      if child.node_type == :text
        replace_text_node(node, child)
      else
        walk(child)
      end
    end

    def replace_text_node(parent, node)
      list_of_new_nodes(node).reverse.each do |new_node|
        parent.insert_after(node, new_node)
      end
      node.remove
    end

    def line_break_node
      br = REXML::Element.new('w:br')
    end

    def list_of_new_nodes(node)
       node.to_s.split("\n")
        .map{|str| str_to_text_node(str)}
        .flat_map{ |txt| [txt, line_break_node] }[0..-2]
    end

    def str_to_text_node(str)
      respect_whitespace = true
      parent = nil
      raw_text = true
      REXML::Text.new(str, respect_whitespace, parent, raw_text)
    end
  end
end
