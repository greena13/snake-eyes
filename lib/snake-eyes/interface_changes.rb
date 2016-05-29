module SnakeEyes
  module InterfaceChanges
    def params
      unless defined? @snake_eyes_params
        @snake_eyes_params = ActionController::Parameters.new(super.deep_transform_keys(&:underscore))

        if SnakeEyes.log_snake_eyes_parameters
          ignored_params = ActionController::LogSubscriber::INTERNAL_PARAMS
          filtered_params = request.send(:parameter_filter).filter(@snake_eyes_params.except(*ignored_params))
          logger.info "  SnakeEyes Parameters: #{filtered_params.inspect}"
        end
      end

      @snake_eyes_params
    end
  end
end
