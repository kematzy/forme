module Forme
  # Default wrapper doesn't wrap input in any tag
  class Wrapper
    # Return an array containing the tag
    def call(tag, input)
      Array(tag)
    end

    Forme.register_transformer(:wrapper, :default, new)
  end

  # Wraps inputs using the given tag type.
  class Wrapper::Tag < Wrapper
    # Set the tag type to use.
    def initialize(type)
      @type = type
    end

    # Wrap the input in the tag of the given type.
    def call(tag, input)
      input.tag(@type, input.opts[:wrapper_attr], super)
    end

    [:li, :p, :div, :span, :td].each do |x|
      Forme.register_transformer(:wrapper, x, new(x))
    end
  end
  
  # Wraps inputs with <div class="form-group">
  class Wrapper::Bootstrap3 < Wrapper
    # Wrap the input in the tag of the given type.
    def call(tag, input)
      # attr = opts[:attr] ? opts[:attr].dup : { }
      attr = input.opts[:wrapper_attr] ? input.opts[:wrapper_attr].dup : { }
      klass = attr[:class] ? "form-group #{attr[:class].to_s}" : ''
      attr[:class] = "form-group #{klass.gsub(/\s*form-group\s*/,'')}".strip
      # form.tag(:div, attr, &block)
      
      # attr = input.opts[:attr] ? input.opts[:attr].dup : { }
      # klass = attr[:class] ? "form-group #{attr[:class].to_s}" : ''
      # attr[:class] = "form-group #{klass.gsub(/\s*form-group\s*/,'')}".strip
      
      input.tag(:div, attr, super)
    end
    
    Forme.register_transformer(:wrapper, :bs3, new)
  end
  
  
  
  class Wrapper::TableRow < Wrapper
    # Wrap the input in tr and td tags.
    def call(tag, input)
      a = super.flatten
      labels, other = a.partition{|e| e.is_a?(Tag) && e.type.to_s == 'label'}
      if labels.length == 1
        ltd = labels
        rtd = other
      elsif a.length == 1
        ltd = [a.first]
        rtd = a[1..-1]
      else
        ltd = a
      end
      input.tag(:tr, input.opts[:wrapper_attr], [input.tag(:td, {}, ltd), input.tag(:td, {}, rtd)])
    end

    Forme.register_transformer(:wrapper, :trtd, new)
  end

  {:tr=>:td, :table=>:trtd, :ol=>:li, :fieldset_ol=>:li}.each do |k, v|
    register_transformer(:wrapper, k, TRANSFORMERS[:wrapper][v])
  end
end
