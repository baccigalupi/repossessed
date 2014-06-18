module Repossessed
  class Parser
    attr_reader :params

    def initialize(params)
      @params = params.to_hash.symbolize_keys
    end

    def attrs
      params.slice(*allowed_keys).merge(additional_attributes)
    end

    def additional_attributes
      additions.inject({}) do |hash, key|
        hash[key] = send(key)
        hash
      end
    end

    def additions
      []
    end

    def allowed_keys
      raise NotImplementedError
    end
  end
end
