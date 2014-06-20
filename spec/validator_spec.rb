require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'

describe Repossessed::Validator do
  let(:validator) { Repossessed::Validator.new(attrs) }

  let(:attrs) {
    {
      gerbil: 'fuzzy'
    }
  }

  describe "#ensure" do
    it 'creates a rule' do
      validator.ensure(:name, 'Name must not be nil') do |value, attrs|
        !value.nil?
      end
      validator.rules.size.must_equal 1
      validator.rules.first.class.must_equal Repossessed::Validator::Rule
    end
  end

  describe "#validate" do
    it 'calls the rule(s) and reports back the error' do
      validator.ensure(:name) { |value| !value.nil? }
      validator.ensure(:gerbil, 'must be cute') { |value| value.include?('cute') }

      validator.validate.must_equal({
        name: 'name is not valid',
        gerbil: 'must be cute'
      })
    end

    it "returns an empty hash when valid" do
      validator.validate.must_equal({})
    end
  end

  describe "#valid?" do
    it 'returns true if there are no errors' do
      validator.valid?.must_equal true
    end

    it 'returs false when there are errors' do
      validator.ensure(:name) { |value| !value.nil? }
      validator.valid?.must_equal false
    end
  end
end
