module Repossessed
  class Validator
    attr_reader :attrs, :errors, :rules

    def initialize(attrs)
      @attrs = attrs
      @rules = []
      @errors = {}
    end

    def ensure(attr, message_or_key=nil, message=nil, &block)
      if message_or_key.is_a?(Symbol)
        block = Repossessed.validator_for(message_or_key)
      else
        message ||= message_or_key
      end

      add(
        make_rule(attr, block, message)
      )
    end

    def make_rule(attr, proc, message=nil)
      Repossessed::Validator::Rule.new(attr, attrs, message, &proc)
    end

    def add(rule)
      rules << rule
    end

    def registrar
      @registrar ||= Repossessed.validations_registrar
    end

    def validate
      errors.clear
      rules.inject(errors) do |hash, rule|
        hash.merge!(rule.report)
        hash
      end
      errors
    end

    def valid?
      validate
      errors.empty?
    end
  end
end
