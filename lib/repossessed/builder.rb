module Repossessed
  module Builder
    def self.config(persistence_class, &block)
      config = Config.new(persistence_class, &block)
      klass = Class.new(Coordinator)
      klass.config = config
      klass
    end
  end
end
