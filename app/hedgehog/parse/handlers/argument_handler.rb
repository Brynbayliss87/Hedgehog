module Hedgehog
  module Parse
    class ArgumentHandler < BaseHandler
      def handle_token
        case current_token.type
        when :space, :end, :newline, :right_parenthesis, :semicolon
          state.pop_handler!
        when :single_quote, :double_quote
          parts << spawn(StringHandler)
        when :dollar
          if state.peek(2).last == :left_parenthesis
            parts << spawn(CommandSubstitutionHandler)
          else
            parts << state.consume_current_token!
          end
        else
          consumed_tokens = consume_tokens_until do
            [
              :space,
              :end,
              :single_quote,
              :double_quote,
              :newline,
              :right_parenthesis,
              :semicolon,
              :dollar
            ].include?(current_token.type)
          end
          log("consumed #{consumed_tokens.count} tokens")
          consumed_tokens.each { |token| parts << token }
        end
      end

      def build_leaves
        if parts.count == 1 && parts.first.is_a?(Token)
          Leaf.new(:argument, parts.first)
        else
          args = Leaf.new(:argument, nil)
          parts.each do |part|
            if part.is_a?(Token)
              args.children << Leaf.new(:argument_part, part)
            else
              args.children << part.build_leaves
            end
          end
          args
        end
      end

      private

      def parts
        @parts ||= []
      end
    end
  end
end
