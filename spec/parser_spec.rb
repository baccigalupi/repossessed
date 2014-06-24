require 'spec_helper'

describe Repossessed::Parser do
  class SiftingParser < Repossessed::Parser
    def allowed_keys
      [:gerbil, :fish]
    end
  end

  class AddingParser < Repossessed::Parser
    def allowed_keys
      [:gerbil, :fish]
    end

    def additions
      [:dog]
    end

    def dog
      'ria'
    end
  end

  describe 'when filtering a large hash into something smaller' do
    let(:params) {
      {
        bird: 'robin',
        fish: 'the dying betta',
        gerbil: 'fuzzy'
      }
    }

    let(:parser) { SiftingParser.new(params) }

    it 'returns only those attributes' do
      parser.attrs.should ==({
        fish: 'the dying betta',
        gerbil: 'fuzzy'
      })
    end
  end

  describe 'when original hash does not include those keys' do
    let(:params) {
      {
        bird: 'robin',
        gerbil: 'fuzzy'
      }
    }

    let(:parser) { SiftingParser.new(params) }

    it 'does not include those keys or values' do
      parser.attrs.should ==({
        gerbil: 'fuzzy'
      })
    end
  end

  describe 'when adding additional attributes' do
    let(:params) {
      {
        bird: 'robin',
        gerbil: 'fuzzy'
      }
    }

    let(:parser) { AddingParser.new(params) }

    it 'does include the tranformations' do
      parser.attrs.should ==({
        gerbil: 'fuzzy',
        dog: 'ria'
      })
    end
  end

  describe "when the passed in params have string keys" do
    let(:params) {
      {
        'bird' => 'robin',
        'gerbil' => 'fuzzy'
      }
    }

    let(:parser) { SiftingParser.new(params) }

    it 'just works' do
      parser.attrs.should ==({
        gerbil: 'fuzzy'
      })
    end
  end

  describe 'when using the default class' do
    let(:parser) {
      Repossessed::Parser.new(params)
    }

    let(:params) {
      {
        'bird' => 'robin',
        'gerbil' => 'fuzzy'
      }
    }

    it "can be told to allow certain keys" do
      parser.allow(:bird, :dog)
      parser.attrs.should ==({
        bird: 'robin'
      })
    end

    it "can add key value pairs" do
      parser.allow(:bird, :gerbil) # so that it works
      parser.add({
        random: 'thing',
        also: 'this'
      })

      parser.attrs.should ==({
        bird: 'robin',
        gerbil: 'fuzzy',
        random: 'thing',
        also: 'this'
      })
    end
  end
end
