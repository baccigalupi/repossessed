module Repossessed
  class Parser
    attr_reader :params, :manual_additions

    def initialize(params)
      @params = params.to_hash.symbolize_keys
      @manual_additions = {}
    end

    def attrs
      params.slice(*allowed_keys)
        .merge(additional_attributes)
        .merge(manual_additions)
    end

    def additional_attributes
      additions.inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    def add hash
      @manual_additions.merge!(hash)
    end

    def additions
      []
    end

    def allow *args
      @allowed_keys ||= []
      @allowed_keys += args
    end

    def allowed_keys
      return @allowed_keys if @allowed_keys
      raise NotImplementedError
    end
  end
end
