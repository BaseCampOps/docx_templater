module Docx
  class ParagraphReplacer
    def initialize(doc)
      @doc = doc
    end

    def replace
      @doc.elements.each("//w:p") do |p_element| 
      	split_and_replace_p(p_element)
      end
    end

    private
    attr_reader :doc

	def split_and_replace_p(p_element)
   		new_p= REXML::Element.new('w:p')
   		p_element.parent.insert_before(p_element, new_p)
   		#puts "p had formating" if p_element.first.name == "pPr" if p_element.size>1
   		#add formatting to new p's also later using this
   		p_element.children.each do |child|
   			#child.each_element_with_text {|text| puts text} useful to test for split
   			child.name=="r" ? add_or_replace_r(new_p,child) : new_p.add(child)
   		end
   		p_element.remove
   	end
   	
   	def add_or_replace_r(new_p, r_element)
   		new_r= REXML::Element.new('w:r')
   		new_p.add(new_r)
   		#puts "r had formating" if r_element.first.name == "rPr"  if r_element.size>1
   		#add formatting to new r's also later using this
   		r_element.children.each do |child|
   			child.name=="t" ? add_or_replace_t(new_r,child) : new_r.add(child)
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
		   	#new_r.add(str_to_text_node(t_split[0]))
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
		   	end
	   	end
   	end

    def str_to_text_node(str)
      respect_whitespace = true
      parent = nil
      raw_text = true
      REXML::Text.new(str, respect_whitespace, parent, raw_text)
    end
  end
end
