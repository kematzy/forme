module Forme
  # Default error handler used by the library, using an "error" class
  # for the input field and a span tag with an "error_message" class
  # for the error message.
  #
  # Registered as :default.
  class ErrorHandler
    Forme.register_transformer(:error_handler, :default, new)

    # Return tag with error message span tag after it.
    def call(tag, input)
      attr = input.opts[:error_attr]
      attr = attr ? attr.dup : {}
      Forme.attr_classes(attr, 'error_message')
      [tag, input.tag(:span, attr, input.opts[:error])]
    end
  end
  
  
  # BS3 Boostrap formatted error handler which adds a span tag 
  # with "help-block with-errors" classes for the error message.
  # 
  # Uses [github.com/1000hz/bootstrap-validator] formatting.
  # 
  # Note! The default "error" class on the input is being removed.
  #
  # Registered as :bs3.
  class ErrorHandler::Bootstrap3 < ErrorHandler
    Forme.register_transformer(:error_handler, :bs3, new)

    # Return tag with error message span tag after it.
    def call(tag, input)
      # delete .error on tag for full BS3 support
      if tag.is_a?(Tag)
        tag.attr[:class] = tag.attr[:class].to_s.gsub(/\s*error\s*/,'')
        tag.attr.delete(:class) if tag.attr[:class].empty?
      end
      attr = input.opts[:error_attr]
      attr = attr ? attr.dup : {}
      Forme.attr_classes(attr, 'help-block with-errors')

      case input.type
      when :submit
        [tag]
      when :checkbox, :radio
        # TODO: Bug: missing support for :wrapper=>:bs3 here (should wrap input in div.checkbox/radio tags)
        input.tag(:div, {class: 'has-error'}, [tag, input.tag(:span, attr, input.opts[:error])])
      else
        [tag, input.tag(:span, attr, input.opts[:error])]
      end
    end
  end
end
