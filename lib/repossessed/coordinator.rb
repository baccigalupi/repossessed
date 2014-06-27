module Repossessed
  class Coordinator
    attr_reader :params, :config

    def initialize(params, config=nil)
      @params = params.to_hash.symbolize_keys
      @config = config || self.class.config || Config.new
    end

    def save
      config.build
      raise ArgumentError.new(config.errors) unless config.valid?

      if valid?
        repo.save
        after_save if repo.success?
      end

      serialize
    end

    alias :perform :save

    # this looks like a different class entirely,
    # probably there is an upsert coordinator and a delete coordinator, shielded inside
    # this top level coordinator
    def delete
      config.build

      opts = {attrs: params}
      opts[:persistence_class] = config.persistence_class if config.persistence_class
      repo = repo_class.new(opts)

      repo.delete

      serializer = serializer_class.new(
        {}, errors, repo.success?
      )
      serializer.allow(:null)
      serializer.to_response
    end

    [
      :persistence_class, :parser_class, :validator_class,
      :repo_class, :serializer_class
    ].each do |meth|
      class_eval <<-RUBY
        def #{meth}
          convert_to_class( config.#{meth} )
        end
      RUBY
    end

    def after_save
      config.after_saves.each do |block|
        block.call(self)
      end
    end

    def parser
      return @parser if @parser

      @parser = parser_class.new(params)
      @parser.allow(*config.allowed_keys) if config.allowed_keys
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

    def repo
      return @repo if @repo

      opts = {attrs: attrs}
      opts[:persistence_class] = config.persistence_class if config.persistence_class
      @repo = repo_class.new(opts)
      @repo
    end

    delegate :record, :success?, to: :repo

    def serializer
      return @serializer if @serializer

      serializable_attrs = record ? record.attributes : attrs
      @serializer = serializer_class.new(
        serializable_attrs, errors, (valid? && success?)
      )
      serializable_keys = config.serializable_keys || parser.allowed_keys
      @serializer.allow(*serializable_keys)
      @serializer
    end

    def serialize
      serializer.to_response
    end

    class << self
      attr_accessor :config
    end

    private

    def convert_to_class(thing)
      return thing if thing.is_a?(Class)
      ActiveSupport::Inflector.constantize(thing)
    end
  end
end
