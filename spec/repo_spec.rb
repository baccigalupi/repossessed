require 'spec_helper'

describe Repossessed::Repo do
  let(:attrs) {
    {
      id: 323,
      name: 'name'
    }
  }

  before do
    User.delete_all
    ProgramConfiguration.delete_all
  end

  describe "when all the needed stuff is passed in" do
    let(:repo) {
      Repossessed::Repo.new({
        persistence_class: User,
        attrs: attrs
      })
    }

    describe 'when the record is new' do
      it 'creates the record' do
        expect {
          repo.save
        }.to change { User.count }.by(1)
      end

      it 'returns the record' do
        expect(repo.save).to be_a(User)
      end

      it 'adds has the right attributes' do
        repo.save
        expect(repo.record.name).to eq(attrs[:name])
      end

      describe "when no exception is raised" do
        it 'should be a success' do
          repo.save
          repo.success?.should == true
        end
      end

      describe "when an exception is raised" do
        before do
          User.stub(:create).and_raise(ArgumentError.new('wha?'))
        end

        it 'should not be a success' do
          repo.save
          repo.success?.should == false
        end

        it 'makes the exception available' do
          repo.save
          expect(repo.exception.message).to eq('wha?')
        end
      end
    end

    describe 'when the record already can be found by id' do
      let!(:record) {
        User.create(id: attrs[:id], name: 'not yo daddy')
      }

      it 'finds the record in question' do
        repo.save
        expect(repo.record).to eq(record)
      end

      it 'updates the record' do
        repo.save
        expect(repo.record.name).to eq(attrs[:name])
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

    let(:repo) { repo_class.new(attrs: attrs, persistence_class: ProgramConfiguration) }

    let(:attrs) {
      {
        program_id: 324,
        type: 'that_thing',
        _value: 'it is!'
      }
    }

    let!(:record) {
      ProgramConfiguration.create(program_id: attrs[:program_id], type: attrs[:type], _value: 'wha?')
    }

    it 'finds existing record via these keys' do
      repo.save
      expect(repo.record).to eq(record)
    end

    it 'updates the record' do
      repo.save
      expect(repo.record._value).to eq(attrs[:_value])
    end
  end
end
