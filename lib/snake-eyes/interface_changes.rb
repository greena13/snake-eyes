module SnakeEyes
  module InterfaceChanges
    def params
      unless defined? @snake_eyes_params
        @snake_eyes_params = ActionController::Parameters.new(super.deep_transform_keys(&:underscore))

        if SnakeEyes.log_snake_eyes_parameters
          logger.info "  SnakeEyes Parameters: #{@snake_eyes_params.except(:controller, :action).inspect}"
        end
      end

      @snake_eyes_params
    end
  end
end
