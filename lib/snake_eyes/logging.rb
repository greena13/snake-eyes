# frozen_string_literal: true

module SnakeEyes
  module Logging
    private

    def log(snake_eyes_params)
      return unless SnakeEyes.log_snake_eyes_parameters

      ignored_params = ActionController::LogSubscriber::INTERNAL_PARAMS
      filtered_params =
        request.send(:parameter_filter).filter(
          snake_eyes_params.except(*ignored_params)
        )

      logger.info "  SnakeEyes Parameters: #{_prepare(filtered_params).inspect}"
    end
  end
end
