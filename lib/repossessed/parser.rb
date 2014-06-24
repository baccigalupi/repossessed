module Repossessed
  class Parser
    attr_reader :params, :manual_additions, :_allowed_keys

    def initialize(params)
      @params = params.to_hash.symbolize_keys
      @manual_additions = {}
      @_allowed_keys = []
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
      @_allowed_keys += args
    end

    def allowed_keys
      return _allowed_keys unless _allowed_keys.empty?
      raise NotImplementedError
    end
  end
end
