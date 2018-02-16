module SnakeEyes
  module InterfaceChanges
    KEYS_ALWAYS_PRESENT = [
        "controller",
        "action"
    ]

    def params(options = {})
      validate_options(options)

      original_params = super()

      params_present = (original_params.keys | KEYS_ALWAYS_PRESENT).length > KEYS_ALWAYS_PRESENT.length

      unless params_present
        return original_params
      end

      # List of subtrees maintained to mark the depth-first traversal's position
      # throughout the transformation of the original param's keys, whereby the
      # last element is the traversal's current position and backtracking (going
      # from child to parent) is achieved by popping off the last element.

      original_params_sub_trees = [
          original_params
      ]

      # Convert the relatively flat format used to specify the nested attributes
      # (easier for specification) into a series of nested objects (easier for
      # look-ups)

      nested_schema = build_nested_schema(options[:nested_attributes] || {})

      @previous_params ||= { }

      return @previous_params[nested_schema] if @previous_params[nested_schema]

      # Similar to original_params_sub_trees, a list of subtrees used to maintain
      # the traversal position of nested_schema. This is kept in sync with the
      # traversal of original_params, to ensure the correct leaf of
      # nested_schema is checked at each point in the traversal of original_params

      nested_schema_sub_trees = [
        nested_schema
      ]

      transformed_params = original_params.deep_transform_keys do |original_key|
        # Synchronise the original params sub-tree with the current key being
        # transformed. We can detect that the sub-tree is stale because the key
        # being transformed does not appear amongst its own. When the sub-tree is
        # indeed stale, move the position to its parent for the original params
        # sub-tree and the nested schema sub-tree and repeat the check.

        while original_params_sub_trees.length > 1 && original_params_sub_trees.last[original_key].nil?
          original_params_sub_trees.pop
          nested_schema_sub_trees.pop
        end

        original_params_sub_tree = original_params_sub_trees.last[original_key]

        # Append the '_attributes' suffix if the original params key has the
        # same name and is nested in the same place as one mentioned in the
        # nested_attributes option

        transformed_key_base = original_key.underscore

        transformed_key =
            if nested_schema_sub_trees.last[transformed_key_base]
              transformed_key_base + '_attributes'
            else
              transformed_key_base
            end

        if original_params_sub_tree.kind_of?(Hash)
          original_params_sub_trees.push(original_params_sub_tree)

          nested_schema_sub_trees.push(
              nested_schema_sub_trees.last[transformed_key_base] ||
                  nested_schema_sub_trees.last['_' + transformed_key_base] ||
                  {}
          )
        end

        transformed_key
      end

      @previous_params[nested_schema] = @snake_eyes_params = ActionController::Parameters.new(transformed_params)

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

    def build_nested_schema(attributes_list = [])

      if attributes_list.kind_of?(Array)

        attributes_list.inject({}) do |memo, nested_attribute|
          memo.merge(build_nested_schema(nested_attribute))
        end

      elsif attributes_list.kind_of?(Hash)

        attributes_list.inject({}) do |memo, key_and_value|
          key, value = key_and_value
          memo[key.to_s] = build_nested_schema(value)
          memo
        end

      else

        { attributes_list.to_s.underscore => {} }

      end

    end
  end
end
