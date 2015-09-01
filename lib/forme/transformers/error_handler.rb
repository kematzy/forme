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
      when :select
        input.opts[:wrapper] = :bs3
        # Moved this to Wrapper::Bootstrap3 instead. Kept temporarily
        # if input.opts[:wrapper_attr]
        #   Forme.attr_classes(input.opts[:wrapper_attr], 'has-error')
        # else
        #   input.opts[:wrapper_attr] = { :class => ['has-error'] }
        # end
        [ tag, input.tag(:span, attr, input.opts[:error]) ]
      when :checkbox, :radio
        # input.opts[:wrapper] = :div
        # if input.opts[:wrapper_attr]
        #   Forme.attr_classes(input.opts[:wrapper_attr], 'has-error')
        # else
        #   input.opts[:wrapper_attr] = { :class => ['has-error'] }
        # end
        [ tag, input.tag(:span, attr, input.opts[:error]) ]
        
        # TODO: BUG: checkboxset / radioset (or single checkbox/radio) are missing support for 
        #       wrapping output in a <div class="has-error">...</div> tag.
        # 
        # Expected output format should be:
        # 
        #   <div class="has-error">
        #     <div class="checkbox/radio">
        #       <label>
        #         <input ...>
        #       </label>
        #     </div>
        #     <div class="checkbox/radio">
        #       <label>
        #         <input ...>
        #       </label>
        #     </div>
        #     <span class="help-block with-errors">Message...</span>
        #   </div>
        
      else
        [tag, input.tag(:span, attr, input.opts[:error])]
      end
    end
  end
end
