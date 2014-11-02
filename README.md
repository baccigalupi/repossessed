# Repossessed

Repossessed aims to take all the things that make active record easy and fast to
work with, and put them in another object. Huh? The problem with everything that
AR tries to do for you, is that you can't make it stop; you can't decompose it
easily into simple, easy to change objects with just on responsibilities ... when
things go terribly big and complicated.

Repossessed uses the builder pattern to configure a class that parses params,
validates the params (yup, the params), saves and serializes to a json response
replete with a status and errors.

It was built for creating json APIs, but you can just ignore that part, if you want.

## Installation

Add this line to your application's Gemfile:

    gem 'repossessed'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repossessed

## Usage

### Creating A Do-Everything Repossessed Class

    AdvocateManager = Repossessed::Config.build('Advocate') do
      permit :name, :dob, :email
    end

This kind of a class will filter down big params into just something with those
three keys.

### Using Your Class

    class MyController < ApplicationController
      def create
        render AdvocateManager.new(params).save
      end
    end

By default, #save will do everything update or save and then return a response:

    {
      json: {
        name: 'Kane',
        email: 'kane@socialchorus.com',
        dob: 'long ass time ago',

        errors: {}
      },

      status: 200
    }

If the save fails, the status is 400. If validations are defined, the errors get
populated.

    AdvocateManager = Repossessed::Config.build('Advocate') do
      permit :name, :dob, :email

      validate(:password, 'password must match confirmation') do |attr, attrs|
        attrs[:password] == attrs[:password_confirmation]
      end
    end

Error response:

    {
      json: {
        name: 'Kane',
        email: 'kane@socialchorus.com',
        dob: 'long ass time ago',

        errors: {
          password: 'password must match confirmation'
        }
      },

      status: 400
    }

### But Why? ActiveRecord already does this??

We found that connecting our database directly to our UI through ActiveRecord and
Rails 4 params is initially easy, but gets expensive when product or our code assumptions
change. While building small single responsibility object solved this problem (hugely),
we saw the same kinds of code, over and over: parsing params, 

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
