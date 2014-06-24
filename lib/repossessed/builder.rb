module Repossessed
  class Builder < Struct.new(:params)
    attr_writer :parser_class

    def parser_class
      convert_to_class( @parser_class ||= Parser )
    end

    def parser
      @parser ||= parser_class.new(params)
    end

    delegate :attrs, to: :parser

    def allowed_keys keys
      parser.allow(keys)
    end

    attr_writer :validator_class

    def validator_class
      convert_to_class( @validator_class ||= Validator )
    end

    def validator
      @validator ||= validator_class.new(attrs)
    end

    delegate :errors, :ensure, to: :validator

    attr_writer :upserter_class
    attr_reader :after_save_block

    def upserter_class
      converter_to_class( @upserter_class ||= Upserter )
    end

    def upserter
      @upserter ||= upserter_class.new({
        attrs: attrs,
        persistence_class: persistence_class
      })
    end

    delegate :record, to: :upserter

    def after_save(&block)
      @after_save_block = block
    end

    def perform_after_save
      if upserter.success? && after_save_block
        after_save_block.call(self)
      end
    end

    def save
      if validator.valid?
        upserter.save
        perform_after_save
      end
    end

    def valid?
      validator.valid? && upserter.success?
    end

    attr_writer :serializer_class

    def serializer_class
      convert_to_class( @serializer_class ||= Serializer )
    end

    def serializer
      @serializer ||= serializer_class.new(record.attrs, errors, valid?)
    end

    delegate :to_json, :as_json, :to_response, to: :serializer

    # ---------
    def self.build(persistence_class, &block)
      klass = new builder_class(persistence_class)
      block.call(klass)
    end

    private

    def convert_to_class(thing)
      return thing if thing.is_a?(Class)
      ActiveSupport::Inflector.constantize(thing)
    end
  end
end

# ProgramCustomizationBuilder = Repossessed::Builder.make('MyArPersistenceClass') do |config|
  # Configuring the parser
  # ----------------------
  # config.parser_class = 'MyParser'
  # - or -
  # config.allowed_keys = [:id, :progarm_id, :type, :value] # required


  # Configuring the upserter
  # ------------------------
  # config.find_keys = [:program_id, :type] # default is [:id]

  # config.after_save {|c| c.do_whatever }

  # Validations - all optional
  # ------------------------
  # config.validation_class = 'MyValidationClass'
  # config.ensure :name, {|value| !value.nil?}
  # config.ensure :params, {|value, attrs| !attrs.empty?}

  # Serialization - also optional
  # ------------------------
  # config.serializer_class = 'MySerializerClass'
  # - or -
  # config.serializable_keys = [:id, :program_id, :type, :value]
# end

# Usage in the controller
# -----------------------
# manager = ProgramCustomizationBuilder.new(params)
# manager.save
# render manager.to_response
# - equivalent to -
# render json: manager.to_json, status: manager.status
