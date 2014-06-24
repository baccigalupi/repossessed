module Repossessed
  class Config
    attr_accessor :persistence_class, :parser_class, :validator_class,
      :upserter_class, :serializer_class,

      :allowed_keys, :find_keys, :serializable_keys


    attr_reader :validations, :after_saves, :built

    def initialize(persistence_class=nil, &block)
      @persistence_class =  persistence_class

      # default classes
      @parser_class =         Parser
      @validator_class =      Validator
      @upserter_class =       Upserter
      # @serializer_class =   Serializer

      # default configuration values
      @validations = []
      @after_saves = []

      @block = block
    end

    # configuration of validations, same API as validator
    def ensure(*args)
      validations << args
    end

    # configuring hooks in the coordinator
    def after_save(&block)
      after_saves << block
    end

    def build
      @built = false
      block.call(self)
      self.serializable_keys ||= allowed_keys
      @built = true
    end

    def validate
      errors
    end

    def valid?
      errors.empty?
    end

    def errors
      if !built
        {config: 'not yet built'}
      else
        {}
          .merge(persistence_class_errors)
          .merge(allowed_keys_errors)
      end
    end

    # upserter class is custom or it must be configured
    def persistence_class_errors
      return {} if persistence_class || upserter_class != Upserter
      {
        persistence_class: 'persistence_class must be set'
      }
    end

    # parser class is custom, or the keys much be in configuration
    def allowed_keys_errors
      return {} if parser_class != Parser || ( allowed_keys && allowed_keys.is_a?(Array) )
      {
        allowed_keys: 'allowed keys must be set to an array of values'
      }
    end
  end
end
