require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'

describe Repossessed::Validator::Registrar do
  let(:registrar) { Repossessed::Validator::Registrar.new }

  let(:stub_lambda) { stub('lambda', call: true) }

  describe "#get" do
    it "returns the registered class" do
      registrar.cache = {
        presence: stub_lambda
      }

      registrar.get(:presence).must_equal(stub_lambda)
    end

    it "raises an error when not registered yet" do
      proc {
        registrar.get(:foo)
      }.must_raise Repossessed::Validator::NotRegistered
    end
  end

  describe '#add' do
    it 'adds the key to the registrar' do
      registrar.add(:my_validator, stub_lambda)
      registrar.get(:my_validator).must_equal stub_lambda
    end
  end
end
