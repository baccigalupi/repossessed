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

  let(:new_record) {
    double('AR record', {
      update_attributes: true,
      attributes: params
    })
  }

  describe 'when the configuration is basic' do
    let(:config) {
      c = Repossessed::Config.new(persistence_class)
      c.allowed_keys = [:name, :dob, :email]
      c
    }

    let(:attrs) {
      {
        name: params[:name],
        dob: params[:dob],
        email: params[:email]
      }
    }

    it 'saves the record' do
      persistence_class.should_receive(:create)
        .with(attrs)
        .and_return(new_record)

      coordinator.perform
    end

    it 'returns the serialized response' do
      coordinator.perform.should == {
        json: attrs.merge(errors: {}),
        status: 200
      }
    end
  end

  describe "when adding validations" do
    let(:config) {
      Repossessed::Config.build(persistence_class) do |c|
        c.allowed_keys = [:name, :email, :dob]
        c.ensure(:password, 'password must match confirmation') do |attr, attrs|
          attrs[:password] == attrs[:password_confirmation]
        end
      end
    }

    let(:response) { coordinator.perform }

    context 'when valid' do
      it 'should save the record' do
        persistence_class.should_receive(:create).and_return(found_record)
        coordinator.perform
      end

      it "should have empty errors" do
        response[:json][:errors].should be_empty
      end

      it "should have a success status" do
        response[:status].should == 200
      end
    end

    context 'when not valid' do
      before do
        params.merge!(password_confirmation: 'not-right')
      end

      it 'should not save the record' do
        persistence_class.should_not_receive(:create)
        coordinator.perform
      end

      it "should report errors" do
        response[:json][:errors][:password].should == 'password must match confirmation'
      end

      it "should have a failure status" do
        response[:status].should == 400
      end
    end
  end
end
