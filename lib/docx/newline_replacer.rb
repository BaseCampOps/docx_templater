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
        if (node.node_type == :element && node.expanded_name == 'w:t') && child.to_s.include?("\n")
          replace_text_node(node, child)
        end
      else
        walk(child)
      end
    end

    def replace_text_node(parent, node)
      grand_parent = parent.parent
      list_of_new_nodes(node).reverse.each do |new_node|
        grand_parent.insert_after(parent, new_node)
      end
      parent.remove
    end

    def line_break_node
      REXML::Element.new('w:br')
    end

    def list_of_new_nodes(node)
       node.to_s.split("\n")
        .map{|str| str_to_text_node(str)}
        .flat_map{ |txt_node| [txt_node, line_break_node] }[0..-2]
    end

    def str_to_text_node(str)
      respect_whitespace = true
      parent = nil
      raw_text = true
      t = REXML::Element.new('w:t')
      text = REXML::Text.new(str, respect_whitespace, parent, raw_text)
      t.add_text text
    end
  end
end
