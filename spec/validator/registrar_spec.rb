require 'spec_helper'

describe Repossessed::Validator::Registrar do
  let(:registrar) { Repossessed::Validator::Registrar.new }

  let(:double_lambda) { double('lambda', call: true) }

  describe "#get" do
    it "returns the registered class" do
      registrar.cache = {
        presence: double_lambda
      }

      registrar.get(:presence).should ==(double_lambda)
    end

    it "raises an error when not registered yet" do
      expect {
        registrar.get(:foo)
      }.to raise_error Repossessed::Validator::NotRegistered
    end
  end

  describe '#add' do
    it 'adds the key to the registrar' do
      registrar.add(:my_validator, double_lambda)
      registrar.get(:my_validator).should == double_lambda
    end
  end
end
