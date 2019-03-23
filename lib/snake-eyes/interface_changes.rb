# frozen_string_literal: true

module SnakeEyes
  module InterfaceChanges
    KEYS_ALWAYS_PRESENT = %w[controller action].freeze

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

    def params(options = {})
      validate_options(options)

      original_params = super()

      params_present =
        (original_params.keys || KEYS_ALWAYS_PRESENT).length > KEYS_ALWAYS_PRESENT.length

      return original_params unless params_present

      @previous_params ||= {}

      nested_attributes_options = options[:nested_attributes] || {}

      nested_schema = build_options_schema(nested_attributes_options, '') do |target, parent_name|
        if parent_name.empty? || parent_name.starts_with?('_')
          target
        else
          target.merge(_attributes_suffix: true)
        end
      end

      options[:nested_attributes] = nested_schema

      return @previous_params[options] if @previous_params[options]

      transformed_params = deep_transform(_prepare(original_params), options)

      @snake_eyes_params = ActionController::Parameters.new(transformed_params)

      log_snakized_params

      @previous_params[options] = @snake_eyes_params
    end

    private

    def validate_options(options)
      options.keys.each do |key|
        if key != :nested_attributes && key != :substitutions
          raise ArgumentError,
                "SnakeEyes: params received unrecognised option '#{key}'"
        end
      end
    end

    def log_snakized_params
      return unless SnakeEyes.log_snake_eyes_parameters

      ignored_params = ActionController::LogSubscriber::INTERNAL_PARAMS
      filtered_params =
        request.send(:parameter_filter).filter(
          @snake_eyes_params.except(*ignored_params)
        )

      logger.info "  SnakeEyes Parameters: #{_prepare(filtered_params).inspect}"
    end

    def deep_transform(target, options = {})
      nested_attributes = options[:nested_attributes] || {}

      substitutions =
        if options[:substitutions].is_a?(Array)
          options[:substitutions].map(&:stringify_keys)
        else
          (options[:substitutions] || {}).stringify_keys
        end

      if target.is_a?(Array)
        target.map do |target_element|
          deep_transform(target_element,
                         nested_attributes: nested_attributes['*'],
                         substitutions: substitutions.is_a?(Array) ? {} : substitutions['*'])
        end
      elsif target.is_a?(Hash)
        target.each_with_object({}) do |key_and_value, memo|
          key, value = key_and_value

          # Append the '_attributes' suffix if the original params key has the
          # same name and is nested in the same place as one mentioned in the
          # nested_attributes option

          transformed_key_base = key.to_s.underscore

          transformed_key =
            if nested_attributes[transformed_key_base] && nested_attributes[transformed_key_base][:_attributes_suffix]
              transformed_key_base + '_attributes'
            else
              transformed_key_base
            end

          transformed_value = deep_transform(value,
                                             nested_attributes: nested_attributes[transformed_key_base] || nested_attributes['_' + transformed_key_base],
                                             substitutions: substitutions.is_a?(Array) ? {} : substitutions[transformed_key_base])

          memo[transformed_key] = transformed_value
        end
      else
        perform_substitution(target, substitutions)
      end
    end

    def perform_substitution(target, substitution)
      if substitution.is_a?(Array)
        matching_substitution = substitution.find do |substitution_item|
          has_substitution_keys?(substitution_item) && target === substitution_item['replace']
        end

        if matching_substitution
          matching_substitution['with']
        else
          target
        end

      else
        if has_substitution_keys?(substitution)
          target === substitution['replace'] ? substitution['with'] : target
        else
          target
        end
      end
    end

    def has_substitution_keys?(substitution)
      substitution.key?('replace') && substitution.key?('with')
    end

    def build_options_schema(attributes_list = [], parent_name = '', options = {}, &block)
      if attributes_list.is_a?(Array)
        attributes_array = attributes_list.inject({}) do |memo, nested_attribute|
          memo.merge(build_options_schema(nested_attribute, parent_name, options, &block))
        end

        yield(attributes_array, parent_name)
      elsif attributes_list.is_a?(Hash) && (!options[:internal_attributes] || (attributes_list.keys & options[:internal_attributes]).length > options[:internal_attributes].length)
        attributes_hash = attributes_list.each_with_object({}) do |key_and_value, memo|
          key, value = key_and_value

          memo[key.to_s] = yield(build_options_schema(value, '', options, &block), key.to_s)
        end

        yield(attributes_hash, parent_name)
      else
        {
          attributes_list.to_s.underscore => yield({}, attributes_list.to_s.underscore)
        }
      end
    end
  end
end
