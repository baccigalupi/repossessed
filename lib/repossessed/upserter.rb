module Repossessed
  class Upserter
    attr_accessor :persistence_class, :attrs
    attr_writer :find_keys

    def initialize(opts={})
      @persistence_class = opts[:persistence_class]
      @attrs = opts[:attrs]
    end

    def save
      if record
        record.update_attributes(save_attrs)
      else
        create
      end

      record
    end

    def create
      @record = persistence_class.create(save_attrs)
    end

    def save_attrs
      attrs.slice(*save_keys)
    end

    def record
      @record ||= persistence_class.where(find_attrs).take
    end

    def find_attrs
      attrs.slice(*find_keys)
    end

    def find_keys
      @find_attrs ||= [:id]
    end

    def save_keys
      attrs.keys - find_keys
    end
  end
end
