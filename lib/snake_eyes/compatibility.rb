# frozen_string_literal: true

module SnakeEyes
  module Compatibility
    if Rails::VERSION::MAJOR >= 5
      def _prepare(transformed_params)
        # We permit all parameter values so that we many convert it to a hash,
        # to work with ActionPack 5.2's ActionController::Parameters initializer
        params_duplicate = transformed_params.dup
        params_duplicate.permit!
        params_duplicate.to_h
      end
    else
      def _prepare(transformed_params)
        transformed_params
      end
    end
  end
end
