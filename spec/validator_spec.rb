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

  describe "#ensure" do
    describe "when passing in a block" do
      describe "with a message" do
        before do
          validator.ensure(:name, 'Name must not be nil') do |value, attrs|
            !value.nil?
          end
        end

        it 'creates a rule' do
          validator.rules.size.must_equal 1
          validator.rules.first.class.must_equal Repossessed::Validator::Rule
        end

        it 'builds an error with the message' do
          validator.validate.must_equal({
            name: 'Name must not be nil'
          })
        end
      end

      describe "whithout a message" do
        before do
          validator.ensure(:name) do |value, attrs|
            !value.nil?
          end
        end

        it 'uses a custom message' do
          validator.validate.must_equal({
            name: 'name is not valid'
          })
        end
      end
    end

    describe "when passing in a symbol (for a registered validator)" do
      let(:rule_proc) { Proc.new {|value| !value.nil? && value != ''} }

      before do
        Repossessed.register_validation(:is_present, rule_proc)
      end

      describe "when using passing a message too" do
        before do
          validator.ensure(:name, :is_present, 'Yo, include a name')
        end

        it "uses the custom message" do
          validator.validate.must_equal({
            name: 'Yo, include a name'
          })
        end
      end

      describe "when not passing a message" do
        before do
          validator.ensure(:name, :is_present)
        end

        it 'uses the default' do
          validator.validate.must_equal({
            name: 'name is not valid'
          })
        end
      end
    end
  end

  describe '#add' do
    it "creates a rule via that class" do
      rule = Repossessed::Validator::Rule.new(:name, {other_value: 'fishy'}) do |value|
        value.include?('fish')
      end
      validator.add(rule)
      validator.rules.first.must_equal(rule)
    end
  end
end
