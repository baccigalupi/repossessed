module Repossessed
  class Serializer < Parser
    attr_reader :errors, :state

    def initialize(params, errors, state)
      super(params)
      @errors = errors
      @state = state
    end

    def as_json
      attrs.merge(errors: errors)
    end

    def to_json *args
      as_json.to_json
    end

    def to_response
      {
        json: as_json,
        status: status
      }
    end

    def status
      state ? 200 : 400
    end
  end
end
