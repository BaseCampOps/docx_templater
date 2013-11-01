module Docx
  class NewlineReplacer
    def initialize(doc)
      @doc = doc
    end

    def replace
      @doc.elements.each("//w:p/w:r/w:t") {|textElement| textElement.children.each do |text| 
    	    	replace_text_node(textElement, text)
    	end  }
    end

    private
    attr_reader :doc

    def replace_text_node(textElement, text)
      list_of_new_nodes(text).reverse.each do |new_node|
        textElement.insert_after(text, new_node)
      end
      text.remove
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
