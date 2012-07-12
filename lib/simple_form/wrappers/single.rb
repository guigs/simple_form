module SimpleForm
  module Wrappers
    # `Single` is an optimization for a wrapper that has only one component.
    class Single < Many
      def initialize(name, options={})
        super(name, [name], options)
      end

      def render(input)
        options = input.options
        if options[namespace] != false
          if not @defaults[:tag]
            if [:input, :label_input].include? namespace
              input.input_html_classes.concat @defaults[:class]
              input.input_html_options.merge! @defaults.except(:tag, :class)
              html_options_for_input(input, :label) if namespace == :label_input
            else
              html_options_for_input(input)
            end
          end
          content = input.send(namespace)
          wrap(input, options, content) if content
        end
      end

      private

      def html_options_for_input(input, local_namespace = namespace)
        (input.options["#{local_namespace}_html".intern] ||= {:class => []}).tap do |o|
          o[:class].concat(@defaults[:class])
          o.merge!(@defaults.except(:tag, :class))
        end
      end

      def html_options(options, input = nil)
        [:label, :input].include?(namespace) ? {} : super(options)
      end
    end
  end
end
