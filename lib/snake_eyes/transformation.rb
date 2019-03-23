# frozen_string_literal: true

module SnakeEyes
  module Transformation
    def snakeize(original_params, options)
      ActionController::Parameters.new(
        deep_transform(_prepare(original_params), options)
      )
    end

    private

    def deep_transform(target, options = {})
      case target
      when Array
        deep_transform_array(
          target,
          nested_attributes(options),
          substitutions(options)
        )
      when Hash
        deep_transform_hash(
          target,
          nested_attributes(options),
          substitutions(options)
        )
      else
        perform_substitution(target, substitutions(options))
      end
    end

    def nested_attributes(options)
      options[:nested_attributes] || {}
    end

    def substitutions(options)
      if options[:substitutions].is_a?(Array)
        options[:substitutions].map(&:stringify_keys)
      else
        (options[:substitutions] || {}).stringify_keys
      end
    end

    def deep_transform_array(target, nested_attributes, substitutions)
      target.map do |target_element|
        array_nested_attributes = nested_attributes['*']

        array_substitutions =
          substitutions.is_a?(Array) ? {} : substitutions['*']

        deep_transform(
          target_element,
          nested_attributes: array_nested_attributes,
          substitutions: array_substitutions
        )
      end
    end

    def deep_transform_hash(target, nested_attributes, substitutions)
      target.each_with_object({}) do |(key, value), memo|
        # Append the '_attributes' suffix if the original params key has the
        # same name and is nested in the same place as one mentioned in the
        # nested_attributes option
        transformed_key_base = key.to_s.underscore

        transformed_key =
          if nested_attributes[transformed_key_base] &&
            nested_attributes[transformed_key_base][:_attributes_suffix]

            transformed_key_base + '_attributes'
          else
            transformed_key_base
          end

        transformed_key_base = key.to_s.underscore

        hash_nested_attributes =
          nested_attributes[transformed_key_base] || nested_attributes['_' + transformed_key_base]

        hash_substitutions =
          substitutions.is_a?(Array) ? {} : substitutions[transformed_key_base]

        memo[transformed_key] = deep_transform(
          value,
          nested_attributes: hash_nested_attributes,
          substitutions: hash_substitutions
        )
      end
    end

    def perform_substitution(target, substitution)
      if substitution.is_a?(Array)
        matching_substitution = substitution.find do |substitution_item|
          substitution_keys?(substitution_item) && target == substitution_item['replace']
        end

        if matching_substitution
          matching_substitution['with']
        else
          target
        end

      elsif substitution_keys?(substitution)
        target == substitution['replace'] ? substitution['with'] : target
      else
        target
      end
    end

    def substitution_keys?(substitution)
      substitution.key?('replace') && substitution.key?('with')
    end
  end
end
