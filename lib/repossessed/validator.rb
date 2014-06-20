module Repossessed
  class Validator
    attr_reader :attrs, :errors, :rules

    def initialize(attrs)
      @attrs = attrs
      @rules = []
      @errors = {}
    end

    def ensure(attr, message=nil, &block)
      add(
        Repossessed::Validator::Rule.new(attr, attrs, message, &block)
      )
    end

    def add(rule)
      rules << rule
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
