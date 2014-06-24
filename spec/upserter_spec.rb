require 'spec_helper'

describe Repossessed::Upserter do
  let(:persistence_class) {
    double('AR persistence class', {
      where: double(take: record),
      create: record
    })
  }

  let(:attrs) {
    {
      id: 323,
      name: 'name'
    }
  }

  let(:record) {
    double('AR record', {
      update_attributes: true,
      errors: errors
    })
  }

  let(:errors) {
    double('AR errors', {
      empty?: true
    })
  }

  describe "when all the needed stuff is passed in" do
    let(:upserter) {
      Repossessed::Upserter.new({
        persistence_class: persistence_class,
        attrs: attrs
      })
    }

    describe 'when the record is new' do
      let(:record) { nil }
      let(:new_record) { double('new record') }

      before do
        new_record.stub(:errors).and_return(errors)
        persistence_class.stub(:create).and_return(new_record)
      end

      it 'creates the record' do
        persistence_class.should_receive(:create).with(name: attrs[:name]).and_return(new_record)
        upserter.save
      end

      it 'returns the record' do
        upserter.save.should == new_record
      end

      describe "when errors are empty" do
        it 'should be a success' do
          upserter.save
          upserter.success?.should == true
        end
      end

      describe "when errors are not empty" do
        before do
          errors.should_receive(:empty?).and_return(false)
        end

        it 'should not be a success' do
          upserter.save
          upserter.success?.should == false
        end
      end
    end

    describe 'when the record already can be found by id' do
      it 'finds the record in question' do
        persistence_class.should_receive(:where).with(id: attrs[:id]).and_return(double(take: record))
        upserter.save
      end

      it 'updates the record' do
        record.should_receive(:update_attributes).with(name: attrs[:name])
        upserter.save
      end

      it 'returns the record' do
        upserter.save.should == record
      end
    end
  end

  describe "when class is configured" do
    let(:upserter_class) {
      class UpserterClass < Repossessed::Upserter
        def find_keys
          [:program_id, :type]
        end
      end

      UpserterClass
    }

    let(:upserter) { upserter_class.new(attrs: attrs, persistence_class: persistence_class) }

    let(:attrs) {
      {
        program_id: 324,
        type: 'that_thing',
        _value: 'it is!'
      }
    }

    it 'finds existing record via these keys' do
      persistence_class.should_receive(:where).with(program_id: 324, type: 'that_thing').and_return(double(take: record))
      upserter.save
    end
  end
end
