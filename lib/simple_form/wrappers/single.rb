module SimpleForm
  module Wrappers
    # `Single` is an optimization for a wrapper that has only one component.
    class Single < Many
      attr_reader :wrapper_html_options
      
      def initialize(name, options={})
        @wrapper_html_options = options.except(:wrap_with)
        options = options[:wrap_with] || {}
        super(name, [name], options)
      end

      def render(input)
        options = input.options
        if options[namespace] != false
          if [:input, :label_input].include? namespace
            input.input_html_classes.concat Array.wrap(wrapper_html_options[:class])
            input.input_html_options.merge! wrapper_html_options.except(:class)
            html_options_for_input(input, :label) if namespace == :label_input
          else
            html_options_for_input(input)
          end
          content = input.send(namespace)
          wrap(input, options, content) if content
        end
      end

      private

      def html_options_for_input(input, local_namespace = namespace)
        (input.options["#{local_namespace}_html".intern] ||= {}).tap do |o|
          if o[:class] or wrapper_html_options[:class]
            o[:class] = Array.wrap(o[:class])
            o[:class].concat Array.wrap(wrapper_html_options[:class])
          end
          o.merge! wrapper_html_options
        end
      end

      def html_options(options, input = nil)
        [:label, :input].include?(namespace) ? {} : super(options)
      end
    end
  end
end
