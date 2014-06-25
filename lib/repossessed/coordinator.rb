module Repossessed
  class Coordinator
    attr_reader :params, :config

    def initialize(params, config=nil)
      @params = params.to_hash.symbolize_keys
      @config = config || Config.new
    end

    [
      :persistence_class, :parser_class, :validator_class,
      :upserter_class, :serializer_class
    ].each do |meth|
      class_eval <<-RUBY
        def #{meth}
          convert_to_class( config.#{meth} )
        end
      RUBY
    end

    def perform
      config.build
      raise ArgumentError.new(config.errors) unless config.valid?

      if valid?
        upserter.save
        after_save if upserter.success?
      end

      serialize
    end

    def after_save
      config.after_saves.each do |block|
        block.call(this)
      end
    end

    def parser
      return @parser if @parser

      @parser = parser_class.new(params)
      @parser.allow(*config.allowed_keys)
      @parser
    end

    delegate :attrs, to: :parser

    def validator
      return @validator if @validator

      @validator = validator_class.new(params)
      config.validations.each do |validation|
        if validation[:block]
          @validator.ensure(*validation[:args], &validation[:block])
        else
          @validator.ensure(*validation[:args])
        end
      end
      @validator
    end

    delegate :valid?, :errors, to: :validator

    def upserter
      return @upserter if @upserter

      opts = {attrs: attrs}
      opts[:persistence_class] = config.persistence_class if config.persistence_class
      @upserter = upserter_class.new(opts)
      @upserter
    end

    delegate :record, :success?, to: :upserter

    def serializer
      return @serializer if @serializer

      serializable_attrs = record ? record.attributes : attrs
      @serializer = serializer_class.new(
        serializable_attrs, errors, (valid? && success?)
      )
      @serializer.allow(*config.serializable_keys)
      @serializer
    end

    def serialize
      serializer.to_response
    end

    private

    def convert_to_class(thing)
      return thing if thing.is_a?(Class)
      ActiveSupport::Inflector.constantize(thing)
    end
  end
end
