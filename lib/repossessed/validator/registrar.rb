module Repossessed
  class Validator
    class Registrar
      attr_accessor :cache

      def initialize
        @cache ||= {}
      end

      def get(key)
        raise NotRegistered.new("#{key} not registered") unless cache[key]
        cache[key]
      end

      def add(key, value)
        cache[key] = value
      end
    end

    class NotRegistered < ArgumentError; end
  end
end
