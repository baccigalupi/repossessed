require 'spec_helper'

describe Repossessed::Coordinator do
  let(:coordinator) {
    coordinator_class.new(params)
  }

  let(:coordinator_class) {
    klass = Class.new(Repossessed::Coordinator)
    klass.config = config
    klass
  }

  let(:params) {
    {
      name: 'Kane Baccigalupi',
      email: 'kane@socialchorus.com',
      password: 'secret',
      password_confirmation: 'secret',
      dob: 'once upon a time'
    }
  }

  before do
    User.delete_all
    Greeter.delete_all
  end

  describe '#save aliased to #perform' do
    describe 'when the configuration is basic' do
      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :dob, :email
        end
      }

      let(:attrs) {
        {
          name: params[:name],
          dob: params[:dob],
          email: params[:email]
        }
      }

      it 'saves the record' do
        expect {
          coordinator.save
        }.to change { User.count }.by(1)
      end

      it 'returns the serialized response' do
        coordinator.save.should == {
          json: attrs.merge(errors: {}),
          status: 200
        }
      end
    end

    describe "when adding validations" do
      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :email, :dob

          validate(:password, 'password must match confirmation') do |attr, attrs|
            attrs[:password] == attrs[:password_confirmation]
          end
        end
      }

      let(:response) { coordinator.save }

      context 'when valid' do
        it 'should save the record' do
          expect {
            coordinator.save
          }.to change { User.count }.by(1)
        end

        it "should have empty errors" do
          response[:json][:errors].should be_empty
        end

        it "should have a success status" do
          response[:status].should == 200
        end
      end

      context 'when not valid' do
        before do
          params.merge!(password_confirmation: 'not-right')
        end

        it 'should not save the record' do
          expect {
            coordinator.save
          }.to_not change { User.count }
        end

        it "should report errors" do
          response[:json][:errors][:password].should == 'password must match confirmation'
        end

        it "should have a failure status" do
          response[:status].should == 400
        end
      end
    end

    describe 'when adding to after save behavior' do
      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :email, :dob

          validate(:password) do |attr, attrs|
            attrs[:password] == attrs[:password_confirmation]
          end

          after_save do |coordinator|
            coordinator.instance_variable_set('@foo', 'bar')
          end
        end
      }

      context 'when not valid' do
        before do
          params.merge!(password_confirmation: 'not-right')
        end

        it "does not get called" do
          coordinator.save
          coordinator.instance_variable_get('@foo').should be_nil
        end
      end

      context 'when valid' do
        it "gets called" do
          coordinator.save
          coordinator.instance_variable_get('@foo').should == 'bar'
        end
      end
    end

    describe 'when a parser class is defined' do
      let(:config) {
        Repossessed::Config.build(Greeter) do
          parser_class ParserClass
        end
      }

      class ParserClass
        def initialize(*args)
        end

        def allowed_keys
          [:hello]
        end

        def attrs
          {
            hello: 'new parser class'
          }
        end
      end

      it 'uses it for making the attrs' do
        coordinator.save
        Greeter.first.hello.should == 'new parser class'
      end
    end

    describe "when a repository is defined" do
      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :email, :dob

          repo_class RepositoryClassityClassClass
        end
      }

      class RepositoryClassityClassClass
      end

      let(:repo) {
        double('repo', save: true, success?: true, record: nil)
      }

      it 'uses it for saving the record' do
        RepositoryClassityClassClass.should_receive(:new).and_return(repo)
        repo.should_receive(:save)
        coordinator.save
      end
    end

    describe 'when a validator class is defined' do
      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :email, :dob

          validator_class ValidatorClass
        end
      }

      class ValidatorClass
      end

      let(:validator) { double('validator', errors: {}, valid?: true) }

      it "should use it" do
        ValidatorClass.should_receive(:new).and_return(validator)
        coordinator.save
      end
    end

    describe 'when a serializer class is defined' do
      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :email, :dob

          serializer_class SerializerClass
        end
      }

      class SerializerClass
      end

      let(:serializer) {
        double('serializer', allow: nil, to_response: {to: 'response'})
      }

      it "uses it to serialize" do
        SerializerClass.should_receive(:new).and_return(serializer)
        coordinator.save.should == {to: 'response'}
      end
    end

    describe 'when configuring a class with a string that has to be evaluated' do
      class DoMyValidations
      end

      let(:validator) { double('validator', errors: {}, valid?: true) }

      let(:config) {
        Repossessed::Config.build(User) do
          permit :name, :email, :dob

          validator_class 'DoMyValidations'
        end
      }

      it 'finds it and uses it' do
        DoMyValidations.should_receive(:new).and_return(validator)
        coordinator.save
      end
    end
  end

  describe "#delete" do
    let(:params) {
      {
        id: found_record.id
      }
    }

    let(:config) {
      Repossessed::Config.build(User)
    }

    let(:found_record) {
      User.create
    }

    it "deletes the record" do
      coordinator = coordinator_class.new(params)
      expect {
        coordinator.delete
      }.to change { User.count }.by(-1)
    end

    it "serializes a response" do
      coordinator.delete.should == {
        json: {errors: {}},
        status: 200
      }
    end
  end

  describe "when there are mixins" do
    let(:config) {
      Repossessed::Config.build(User) do
        permit :name, :email, :dob

        mixin do
          def after_save
            @hello = 'hola'
          end

          def hello
            @hello
          end
        end
      end
    }

    it "makes that available in the coordinator" do
      coordinator.save
      coordinator.hello.should == 'hola'
    end
  end
end
