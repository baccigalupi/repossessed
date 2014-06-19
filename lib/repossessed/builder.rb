module Repossessed
  class Builder
    # coordinator takes a parser, upserter, (null?) validator, and (null?) serializer
    # each is an instance, and it makes them do the right thing
    # use null objects to get participation with validators and serializers which are optional
  end
end

# ProgramCustomizationManager = Repossessed::Builder.make do |config|
  # Configuring the parser
  # ----------------------
  # config.parser_class = 'MyParser'
  # - or -
  # config.allowed_keys = [:id, :progarm_id, :type, :value]


  # Configuring the upserter
  # ------------------------
  # config.persistence_class = 'MyArClass'
  # - or -
  # config.find_keys = [:program_id, :type]
  # config.save_keys

  # Validations
  # ------------------------
  # Defaul Null validator, allows validation class with form
  # validator = Validator.new(model)
  # validator.valid?
  # validator.errors

  # Serialization
  # ------------------------
  # takes the record and something to indicate the succes of the save
  # builds out attributes in a way simial to
# end
