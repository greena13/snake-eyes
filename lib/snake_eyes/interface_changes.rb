# frozen_string_literal: true

require File.expand_path('configuration', __dir__)
require File.expand_path('memoization', __dir__)
require File.expand_path('compatibility', __dir__)
require File.expand_path('logging', __dir__)
require File.expand_path('transform', __dir__)

module SnakeEyes
  module InterfaceChanges
    include Configuration
    include Memoization
    include Compatibility
    include Logging
    include Transform

    KEYS_ALWAYS_PRESENT = %w[controller action].freeze

    def self.included(base)
      base.class_eval do
        alias_method :old_params, :params

        def params(options = {})
          # noinspection RubyResolve
          original_params = old_params

          return original_params unless keys_to_snakeize?(original_params)

          validate_options(options)
          add_nested_attributes!(options)

          return params_from_cache(options) if params_in_cache?(options)

          @snake_eyes_params = transform(original_params, options)

          log(@snake_eyes_params)

          cache!(options, @snake_eyes_params)
        end

        private

        def keys_to_snakeize?(params)
          (params.keys || KEYS_ALWAYS_PRESENT).length > KEYS_ALWAYS_PRESENT.length
        end
      end
    end
  end
end
