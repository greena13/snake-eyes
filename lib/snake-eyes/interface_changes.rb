module SnakeEyes
  module InterfaceChanges
    def params(options = {})
      validate_options(options)

      untransformed_params = super()

      traverse_positions = [
          untransformed_params
      ]

      nested_attributes = nested_attributes_hash(options[:nested_attributes])

      nested_attributes_positions = [
          nested_attributes
      ]

      transformed_params = untransformed_params.deep_transform_keys do |key|
        underscored_key = key.underscore

        nested_attributes_position = nested_attributes_positions.last

        transformed_key =
            if nested_attributes_position[underscored_key]
              underscored_key + '_attributes'
            else
              underscored_key
            end

        while traverse_positions.length > 1 && traverse_positions.last[key].nil?
          traverse_positions.pop
          nested_attributes_positions.pop
        end

        current_position = traverse_positions.last[underscored_key]

        if current_position.kind_of?(Hash)
          traverse_positions.push(current_position)

          nested_attributes_positions.push(
              nested_attributes_position[underscored_key] || nested_attributes_position['_' + underscored_key] || {}
          )
        end

        transformed_key
      end

      @snake_eyes_params = ActionController::Parameters.new(transformed_params)

      log_snakized_params

      @snake_eyes_params
    end

    private

    def validate_options(options)
      options.keys.each do |key|
        raise ArgumentError.new("SnakeEyes: params received unrecognised option '#{key}'") if key != :nested_attributes
      end
    end

    def log_snakized_params
      if SnakeEyes.log_snake_eyes_parameters
        ignored_params = ActionController::LogSubscriber::INTERNAL_PARAMS
        filtered_params = request.send(:parameter_filter).filter(@snake_eyes_params.except(*ignored_params))
        logger.info "  SnakeEyes Parameters: #{filtered_params.inspect}"
      end
    end

    def nested_attributes_hash(attributes_list = [])

      if attributes_list.kind_of?(Array)
        attributes_list.inject({}) do |memo, nested_attribute|
          memo.merge(nested_attributes_hash(nested_attribute))
        end
      elsif attributes_list.kind_of?(Hash)
        attributes_list.inject({}) do |memo, key_and_value|
          key, value = key_and_value
          memo[key.to_s] = nested_attributes_hash(value)
          memo
        end
      else
        { attributes_list.to_s.underscore => {} }
      end

    end
  end
end
