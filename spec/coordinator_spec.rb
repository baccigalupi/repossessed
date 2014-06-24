require 'spec_helper'

describe Repossessed::Coordinator do
  let(:coordinator) {
    Repossessed::Coordinator.new(params, config)
  }

  let(:params) {
    {
      name: 'Kane Baccigalupi',
      email: 'kane@socialchorus.com',
      password: 'secret',
      password_confirmation: 'sekret',
      dob: 'once upon a time'
    }
  }

  describe 'when the configuration is basic' do
    let(:config) {
      c = Repossessed::Config.new(persistence_class)
      c.allowed_keys = [:name, :dob, :email]
    }

    xit 'saves the record' do
      persistence_class.should_receive(:create).with({
        name: params[:name],
        dob: params[:dob],
        email: params[:email]
      }).returns(record)

      coordinator.perform
    end
  end
end
