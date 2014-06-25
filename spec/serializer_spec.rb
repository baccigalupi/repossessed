require 'spec_helper'

describe Repossessed::Serializer do
  let(:serializer) {
    s = Repossessed::Serializer.new(attrs, errors, is_valid)
    s.allow(:name, :email)
    s
  }

  let(:attrs) {
    {
      name: 'Kane Baccigalupi',
      email: 'kane@socialchorus.com',
      password: 'secret',
      password_confirmation: 'sekret',
      dob: 'once upon a time'
    }
  }

  let(:errors) {
    {
      it: 'is broken'
    }
  }

  let(:is_valid) { false }

  describe '#as_json' do
    it 'includes the errors' do
      serializer.as_json[:errors].should == errors
    end

    it 'works like a parser' do
      serializer.as_json[:name].should == attrs[:name]
      serializer.as_json[:email].should == attrs[:email]

      serializer.as_json.keys.should_not include(:password)
    end
  end

  describe '#to_response' do
    it "includes the json" do
      serializer.to_response[:json].should == serializer.as_json
    end

    describe "status" do
      describe "when something has gone wrong" do
        it "should be 400 on failure" do
          serializer.to_response[:status].should == 400
        end
      end

      describe "when successful" do
        let(:errors) { {} }
        let(:is_valid) { true}

        it "should be 200 on success" do
          serializer.to_response[:status].should == 200
        end
      end
    end
  end
end
