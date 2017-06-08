# SnakeEyes

Automatically convert between camel case APIs to snake case for your Rails code

## Important

🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧🚧

If you are using a version below `0.0.4`, please upgrade to avoid [potentially logging sensitive user information](https://github.com/greena13/snake-eyes/issues/1)  

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
    #reference the params hash as normal
  end
end
```

### Dealing with nested params

Once `snake_eyes_params` has been enabled for a controllor, `params` accepts an options hash, which can be used to specify which attributes should have the `_attributes` suffix appended.

 ```ruby
 class WithoutSnakeEyesController < ApplicationController

    def show
       params # results in:
       # {
       #    'user' => {
       #      'name' => 'John Smith',
       #      'favouriteColor' => 'blue',
       #      'address' => { '123 street' },
       #      'billingAddress' => { '456 road' }
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
        #      'address_attributes' => { '123 street' },
        #      'billing_address_attributes' => { '456 road' }
        #    }
        #}
     end
  end
 ```

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
        #      'address_attributes' => { '123 street' },
        #      'billing_address_attributes' => { '456 road' }
        #    }
        #}
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
