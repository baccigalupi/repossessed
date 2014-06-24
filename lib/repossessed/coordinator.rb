module Repossessed
  class Coordinator
    attr_reader :params, :config

    def initialize(params, config=nil)
      @params = params
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
      raise ArgumentError.new(config.errors) unless config.empty?


      if valid?
        upserter.save
        after_save if upserter.success?
      end
      #
      # serialize
    end

    def after_save
      config.after_saves.each do |block|
        block.call(this)
      end
    end

    def parser
      return @parser if @parser

      @parser = parser_class.new(params)
      @parser.allow(config.allowed_keys)
      @parser
    end

    delegate :attrs, to: :parser

    def validator
      return @validator if @validator

      @validator = validator_class.new(attrs)
      validations.each do |args|
        @validator.ensure(*args)
      end
      @validator
    end

    delegate :valid?, to: :validator

    def upserter
      return @upserter if @upserter

      @upserter = upserter_class.new(attrs)
    end

    private

    def convert_to_class(thing)
      return thing if thing.is_a?(Class)
      ActiveSupport::Inflector.constantize(thing)
    end
  end
end
