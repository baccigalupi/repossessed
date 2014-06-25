module Repossessed
  class Validator
    class Rule
      attr_reader :attr, :attrs, :message, :block

      def initialize(attr, attrs, message=nil, &block)
        @attr = attr
        @attrs = attrs
        @message = message || "#{attr} is not valid"
        @block = block
      end

      def report
        block.call(attrs[attr], attrs) ? {} : errors
      end

      def errors
        {attr => message}
      end
    end
  end
end
