module Repossessed
  class Repo
    attr_accessor :attrs
    attr_writer :find_keys, :persistence_class
    attr_reader :exception

    def initialize(opts={})
      @persistence_class = opts[:persistence_class]
      @attrs = opts[:attrs]
    end

    def save
      save_and_rescue
      record
    end

    def save_and_rescue
      if record
        record.update_attributes(save_attrs)
      else
        create
      end
    rescue Exception => e
      @exception = e
    end

    def delete
      record.delete
    rescue Exception => e
      @excetion = e
    end

    def success?
      !exception
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

    def persistence_class
      return @persistence_class if @persistence_class
      raise NotImplementedError
    end
  end
end
