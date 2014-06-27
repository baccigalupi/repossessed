require 'spec_helper'

describe Repossessed::Repo do
  let(:attrs) {
    {
      id: 323,
      name: 'name'
    }
  }

  let(:persistence_class) {
    double('AR persistence class', {
      where: double(take: record),
      create: record
    })
  }

  let(:record) {
    double('AR record', {
      update_attributes: true,
    })
  }

  describe "when all the needed stuff is passed in" do
    let(:repo) {
      Repossessed::Repo.new({
        persistence_class: persistence_class,
        attrs: attrs
      })
    }

    describe 'when the record is new' do
      let(:record) { nil }
      let(:new_record) { double('new record') }

      before do
        persistence_class.stub(:create).and_return(new_record)
      end

      it 'creates the record' do
        persistence_class.should_receive(:create).with(name: attrs[:name]).and_return(new_record)
        repo.save
      end

      it 'returns the record' do
        repo.save.should == new_record
      end

      describe "when no exception is raised" do
        it 'should be a success' do
          repo.save
          repo.success?.should == true
        end
      end

      describe "when an exception is raised" do
        before do
          persistence_class.stub(:create).and_raise(ArgumentError.new('wha?'))
        end

        it 'should not be a success' do
          repo.save
          repo.success?.should == false
        end
      end
    end

    describe 'when the record already can be found by id' do
      it 'finds the record in question' do
        persistence_class.should_receive(:where).with(id: attrs[:id]).and_return(double(take: record))
        repo.save
      end

      it 'updates the record' do
        record.should_receive(:update_attributes).with(name: attrs[:name])
        repo.save
      end

      it 'returns the record' do
        repo.save.should == record
      end
    end
  end

  describe "when class is configured" do
    let(:repo_class) {
      class RepoClass < Repossessed::Repo
        def find_keys
          [:program_id, :type]
        end
      end

      RepoClass
    }

    let(:repo) { repo_class.new(attrs: attrs, persistence_class: persistence_class) }

    let(:attrs) {
      {
        program_id: 324,
        type: 'that_thing',
        _value: 'it is!'
      }
    }

    it 'finds existing record via these keys' do
      persistence_class.should_receive(:where).with(program_id: 324, type: 'that_thing').and_return(double(take: record))
      repo.save
    end
  end
end
