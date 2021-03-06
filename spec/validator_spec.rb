require 'spec_helper'

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

      validator.validate.should ==({
        name: 'name is not valid',
        gerbil: 'must be cute'
      })
    end

    it "returns an empty hash when valid" do
      validator.validate.should ==({})
    end
  end

  describe "#valid?" do
    it 'returns true if there are no errors' do
      validator.valid?.should == true
    end

    it 'returs false when there are errors' do
      validator.ensure(:name) { |value| !value.nil? }
      validator.valid?.should == false
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
          validator.rules.size.should == 1
          validator.rules.first.class.should == Repossessed::Validator::Rule
        end

        it 'builds an error with the message' do
          validator.validate.should ==({
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
          validator.validate.should ==({
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
          validator.validate.should ==({
            name: 'Yo, include a name'
          })
        end
      end

      describe "when not passing a message" do
        before do
          validator.ensure(:name, :is_present)
        end

        it 'uses the default' do
          validator.validate.should ==({
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
      validator.rules.first.should ==(rule)
    end
  end
end
