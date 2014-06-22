module Repossessed
  def self.validations_registrar
    @validations_registrar ||= Validator::Registrar.new
  end

  def self.register_validation(key, proc)
    validations_registrar.add(key, proc)
  end

  def self.validator_for(key)
    validations_registrar.get(key)
  end
end
