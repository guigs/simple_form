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
        options = ( input.options["#{local_namespace}_html".intern] ||= {} )
        if options[:class] || wrapper_html_options[:class]
          options[:class] = Array.wrap(options[:class])
          options[:class].concat Array.wrap(wrapper_html_options[:class])
        end
        options.merge! wrapper_html_options
      end

      def html_options(options)
        [:label, :input].include?(namespace) ? {} : super
      end
    end
  end
end
