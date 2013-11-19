module Docx
  class ParagraphReplacer
    def initialize(doc)
      @doc = doc
      @nodes_with_paragraph_markers = Array.new
      search_for_wp
    end
    
    def search_for_wp
    	@doc.elements.each("//w:p") do |pElement|
    		search_for_text(pElement)
    	end
    end
    
    def search_for_text(pElement)
    	pElement.elements.each("w:r/w:t") do |tElement|
    		tElement.children.each do |text|
    			if text.to_s.include? '|paragraph|'
					@nodes_with_paragraph_markers << p_parent(text)
					return
				end
			end
		end
    end
    
    def p_parent(text_element)
    	parent = text_element.parent
    	parent.name=='p' ? (return parent) : p_parent(parent)
    end

    def replace
      @nodes_with_paragraph_markers.each do |p_element| 
      	split_and_replace_p(p_element)
      end
    end

    private
    attr_reader :doc

	def split_and_replace_p(p_element)
   		new_p= REXML::Element.new('w:p')
   		p_element.parent.insert_before(p_element, new_p)
   		p_element.children.each do |child|
   			#child.each_element_with_text {|text| puts text} useful to test for split
   			child.name=="r" ? add_or_replace_r(new_p,child) : add_dont_replace(new_p, child)
   		end
   		p_element.remove
   	end
   	
   	def add_or_replace_r(new_p, r_element)
   		new_r= REXML::Element.new('w:r')
   		new_p.add(new_r)
   		r_element.children.each do |child|
   			child.name=="t" ? add_or_replace_t(new_r,child) : add_dont_replace(new_r, child)
   		end
   		r_element.remove
   	end
   	
   	def add_or_replace_t(new_r, t_element)
   		if t_element.text.nil?
   			new_t = REXML::Element.new('w:t')
   			new_t.add_attributes(t_element.attributes)
	   		new_r.add(new_t)
	   		t_element.remove
	   	else
	   		t_element_text=""
	   		t_element.children.each do |text|
	   			t_element_text+=text.to_s
	   		end	
	   		t_split = t_element_text.split('|paragraph|', 2)
		   	if t_split.size>1
			   	new_t = REXML::Element.new('w:t')
			   	new_t.add_attributes(t_element.attributes)
			   	new_t.add(str_to_text_node(t_split.shift.to_s))
			   	new_r.add(new_t)
			   	t_element.text=str_to_text_node(t_split.join.to_s)
			   	split_and_replace_p(t_element.parent.parent)
		   	else
			   	new_t = REXML::Element.new('w:t')
			   	new_t.add_attributes(t_element.attributes)
			    new_t.add(str_to_text_node(t_element_text))
			    new_r.add(new_t)
			    t_element.remove
		   	end
	   	end
   	end
   	
   	def add_dont_replace(parent, element)
   		cloned = element.deep_clone
   		parent.add(cloned)
   	end

    def str_to_text_node(str)
      respect_whitespace = true
      parent = nil
      raw_text = true
      REXML::Text.new(str, respect_whitespace, parent, raw_text)
    end
  end
end
