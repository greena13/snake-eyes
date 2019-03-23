# SnakeEyes

[![Gem](https://img.shields.io/gem/dt/snake-eyes.svg)]()
[![Build Status](https://travis-ci.org/greena13/snake-eyes.svg)](https://travis-ci.org/greena13/snake-eyes)
[![GitHub license](https://img.shields.io/github/license/greena13/snake-eyes.svg)](https://github.com/greena13/snake-eyes/blob/master/LICENSE)

Automatically convert between camel case APIs to snake case for your Rails code

## Installation

Add this line to your application's Gemfile:

    gem 'snake-eyes'

And then execute:

    $ bundle

## Usage

To use SnakeEyes, simply add the following to the top of any controller in which you wish to have snake case parameters. All controllers that inherit from it shall also have the behaviour

```ruby
class JsonController < ApplicationController
  snake_eyes_params

  def show
    #reference the params method as normal
  end
end
```

### Dealing with nested params

Once `snake_eyes_params` has been enabled for a controller, `params` accepts an options hash, which can be used to specify which attributes should have the `_attributes` suffix appended.

 ```ruby
 class WithoutSnakeEyesController < ApplicationController

    def show
       params # results in:
       # {
       #    'user' => {
       #      'name' => 'John Smith',
       #      'favouriteColor' => 'blue',
       #      'address' => { line1: '123 street' },
       #      'billingAddress' => { line1: '456 road' }
       #    }
       #}
    end
 end

 class WithSnakeEyesController < ApplicationController
     snake_eyes_params

     def show
        params(nested_attributes: { user: [ :address, :billing_address ] }) # results in:
        # {
        #    'user_attributes' => {
        #      'name' => 'John Smith',
        #      'favourite_color' => 'blue',
        #      'address_attributes' => { line1: '123 street' },
        #      'billing_address_attributes' => { line1: '456 road' }
        #    }
        #}
     end
  end
 ```

#### Avoid _attributes suffix on parents: the _ prefix

To specify nested objects that should not have the `_attributes` suffix (but contain attributes that should), you can prefix them with an underscore:


```ruby
 class WithSnakeEyesController < ApplicationController
     snake_eyes_params

     def show
        params(nested_attributes: { _user: [ :address, :billing_address ] }) # results in:
        # {
        #    'user' => {
        #      'name' => 'John Smith',
        #      'favourite_color' => 'blue',
        #      'address_attributes' => { 'line1: 123 street' },
        #      'billing_address_attributes' => { line1: '456 road' }
        #    }
        #}
     end
  end
 ```

#### Reference any element of an array: the '*' wildcard

To apply the `_attributes` suffix to all elements of an array, use the `'*'` wildcard in place of the array index:

```ruby
class WithSnakeEyesController < ApplicationController
    snake_eyes_params

    def show
        # Given
        params(nested_attributes: [ _array: { '*' => :string } ])

        # If the params are:
        #
        # 'array' => [
        #      { 'string' => 'string' },
        #      { 'string' => 'string2' },
        #  ]
        #
        # What will be returned:
        #
        # 'array' => [
        #      { 'string_attributes' => 'string' },
        #      { 'string_attributes' => 'string2' },
        #  ]
    end
end
```

## Substitutions

If you want to substitute alternative values for the ones that the controller actually receives, you can do that using the `substitutions` option:

```ruby
class WithSnakeEyesController < ApplicationController
    snake_eyes_params

    def show
        # Given
        params(substitutions: {
            shallow_object: {
                price: { replace: 'FREE', with: 0.00 }
            }
        })

        # If params is:
        #
        # 'shallowObject' => {
        #      'price' => 'FREE'
        #  }
        #
        # What will be returned:
        #
        # 'shallow_object' => {
        #     'price' => 0.00
        # }
    end
end
```

You can also provide multiple substitutions as an array. They are matched left-to-right, and the first matching substitution is the one that is used.

```ruby
class WithSnakeEyesController < ApplicationController
    snake_eyes_params

    def show
        # Given
        params(substitutions: {
            shallow_object: {
                price: [
                    { replace: 'FREE', with: 0.00 } ,
                    { replace: 'EXPENSIVE', with: 999.00 }
                ]
            }
        })

        # If params is:
        #
        # 'shallowObject' => {
        #      'price' => 'FREE'
        #  }
        #
        # What will be returned:
        #
        # 'shallow_object' => {
        #     'price' => 0.00
        # }

        # If params is:
        #
        # 'shallowObject' => {
        #      'price' => 'EXPENSIVE'
        #  }
        #
        # What will be returned:
        #
        # 'shallow_object' => {
        #     'price' => 999.00
        # }
    end
end
```

## Configuration

By default SnakeEyes logs the snake case parameters to the Rails console. You can prevent this behaviour by configuring the gem:

```ruby
SnakeEyes.configuration do |config|
  config.log_snake_eyes_parameters = false
end
```

## Contributing

1. Fork it ( https://github.com/greena13/snake-eyes/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
