module Pincers::CSS

  class XPathVisitor < ::Nokogiri::CSS::XPathVisitor

    # jQuery extended functions and classes

    def visit_function_contains(_node) # override nokofiri impl to search in value attribute too
      "(contains(., #{_node.value[1]}) or contains(@value, #{_node.value[1]}))"
    end

    def visit_function_has(_node)
      _node.value[1].accept(self)
    end

    def visit_function_eq(_node) # override nokogiri impl to make it zero-based
      "(position()-1)=#{_node.value[1]}"
    end

    def visit_function_gt(_node) # override nokogiri impl to make it zero-based
      # "((#{_node.value[1]} >= 0 and position() > #{_node.value[1]}) or (#{_node.value[1]} < 0 and position() < #{_node.value[1]}))"
      "(position()-1)>#{_node.value[1]}"
    end

    def visit_function_lt(_node)
      "(position()-1)<#{_node.value[1]}"
    end

    def visit_pseudo_class_input(_node)
      "((name()='input' and not(@type='hidden')) or name()='textarea' or name()='select' or name()='button')"
    end

    def visit_pseudo_class_button(_node)
      "(name()='button' or (name()='input' and @type='button'))"
    end

    def visit_pseudo_class_checkbox(_node)
      "@type='checkbox'"
    end

    def visit_pseudo_class_file(_node)
      "@type='file'"
    end

    def visit_pseudo_class_image(_node)
      "@type='image'"
    end

    def visit_pseudo_class_password(_node)
      "@type='password'"
    end

    def visit_pseudo_class_radio(_node)
      "@type='radio'"
    end

    def visit_pseudo_class_reset(_node)
      "@type='reset'"
    end

    def visit_pseudo_class_text(_node)
      "@type='text'"
    end

    def visit_pseudo_class_selected(_node)
      "@selected"
    end

    def visit_pseudo_class_checked(_node)
      "@checked"
    end

    def visit_pseudo_class_odd(_node)
      "position() mod 2 = 1"
    end

    def visit_pseudo_class_even(_node)
      "position() mod 2 = 0"
    end

  end
end