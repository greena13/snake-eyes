# frozen_string_literal: true

module SnakeEyes
  module Memoization
    def self.included(base)
      base.class_eval do
        private

        def params_from_cache(key)
          previous_params[key]
        end

        def params_in_cache?(key)
          previous_params.key?(key)
        end

        def cache!(key, value)
          previous_params[key] = value
        end

        def previous_params
          @previous_params ||= {}
        end
      end
    end
  end
end
