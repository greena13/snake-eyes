# frozen_string_literal: true

module SnakeEyes
  module Configuration
    protected

    def validate_options(options)
      options.keys.each do |key|
        if key != :nested_attributes && key != :substitutions
          raise ArgumentError,
                "SnakeEyes: params received unrecognised option '#{key}'"
        end
      end
    end

    def add_nested_attributes!(options)
      options[:nested_attributes] =
        build_options_schema(options[:nested_attributes] || {}, '') do |target, parent_name|
          # noinspection RubyResolve
          if parent_name.empty? || parent_name.starts_with?('_')
            target
          else
            target.merge(_attributes_suffix: true)
          end
        end
    end

    def build_options_schema(attributes_list = [], parent_name = '', options = {}, &block)
      if attributes_list.is_a?(Array)
        attributes_array = attributes_list.inject({}) do |memo, nested_attribute|
          memo.merge(build_options_schema(nested_attribute, parent_name, options, &block))
        end

        yield(attributes_array, parent_name)
      elsif attributes_list.is_a?(Hash) && (
      !options[:internal_attributes] ||
        (attributes_list.keys && options[:internal_attributes]).length > options[:internal_attributes].length)

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
