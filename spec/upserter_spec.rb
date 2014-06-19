require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'

describe Repossessed::Upserter do
  let(:persistence_class) {
    stub('AP persistence class', {
      where: stub(take: record),
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
    stub('AR record', {
      update_attributes: true
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
      let(:new_record) { mock('new record') }

      before do
        persistence_class.stubs(:create).returns(new_record)
      end

      it 'creates the record' do
        persistence_class.expects(:create).with(name: attrs[:name]).returns(new_record)
        upserter.save
      end

      it 'returns the record' do
        upserter.save.must_equal new_record
      end
    end

    describe 'when the record already can be found by id' do
      it 'finds the record in question' do
        persistence_class.expects(:where).with(id: attrs[:id]).returns(stub(take: record))
        upserter.save
      end

      it 'updates the record' do
        record.expects(:update_attributes).with(name: attrs[:name])
        upserter.save
      end

      it 'returns the record' do
        upserter.save.must_equal record
      end
    end
  end
end
