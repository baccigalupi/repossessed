require 'spec_helper'

describe Repossessed::Builder do
  let(:repo_class) {
    Repossessed::Builder.config(persistence_class) do |config|
      config.allowed_keys = [:name, :email, :dob]
    end
  }

  let(:params) {
    {
      name: 'Kane Baccigalupi',
      email: 'kane@socialchorus.com',
      password: 'secret',
      password_confirmation: 'secret',
      dob: 'once upon a time'
    }
  }

  let(:persistence_class) {
    double('AR persistence class', {
      where: double(take: found_record),
      create: found_record
    })
  }

  let(:found_record) {
    nil
  }

  it "builds a viable coordinator class" do
    repo_class.new(params).perform.should == {
      json: {
        name: params[:name],
        email: params[:email],
        dob: params[:dob],
        errors: {}
      },

      status: 200
    }
  end
end
