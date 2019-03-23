# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'param\'s nested_attributes option:', type: :controller do
  context 'when it is empty' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: {})

        render nothing: true
      end
    end

    it 'then does not attempt to add the _attributes suffix' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'string' => 'string',
          'boolean' => true,
          'simpleArray' => %w[0 1 2],
          'shallowObject' => {
            'nestedAttribute' => 'value'
          }

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'string' => 'string',
        'boolean' => true,
        'simple_array' => %w[0 1 2],
        'shallow_object' => {
          'nested_attribute' => 'value'
        }
      )
    end
  end

  context 'when it is nil' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: nil)

        render nothing: true
      end
    end

    it 'then does not attempt to add the _attributes suffix' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'string' => 'string',
          'boolean' => true,
          'simpleArray' => %w[0 1 2],
          'shallowObject' => {
            'nestedAttribute' => 'value'
          }

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'string' => 'string',
        'boolean' => true,
        'simple_array' => %w[0 1 2],
        'shallow_object' => {
          'nested_attribute' => 'value'
        }
      )
    end
  end

  context 'when it points to an attribute that is not a nested object' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: [:string])

        render nothing: true
      end
    end

    it 'then adds the _attributes suffix' do
      get :index,
          'string' => 'string'

      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'string_attributes' => 'string'
      )
    end
  end

  context 'when it points to an attribute that is a nested object' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: [:shallow_object])

        render nothing: true
      end
    end

    it 'then adds the _attributes suffix' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'shallowObject' => {
            'nestedAttribute' => 'value'
          }

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'shallow_object_attributes' => {
          'nested_attribute' => 'value'
        }
      )
    end
  end

  context 'when it points to a deeply nested attribute' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: { shallow_object: :nested_attribute })

        render nothing: true
      end
    end

    it 'then adds the _attributes suffix to all parents' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'shallowObject' => {
            'nestedAttribute' => 'value'
          }

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'shallow_object_attributes' => {
          'nested_attribute_attributes' => 'value'
        }
      )
    end
  end

  context 'when it points to a deeply nested attribute using nested array' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: { shallow_object: [:nested_attribute] })

        render nothing: true
      end
    end

    it 'then adds the _attributes suffix to all parents' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'shallowObject' => {
            'nestedAttribute' => 'value'
          }

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'shallow_object_attributes' => {
          'nested_attribute_attributes' => 'value'
        }
      )
    end
  end

  context 'when it points to an attribute using the leading underscore convention' do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: { _shallow_object: :nested_attribute })

        render nothing: true
      end
    end

    it 'then adds the _attributes suffix to the inner object only' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'shallowObject' => {
            'nestedAttribute' => 'value'
          }

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'shallow_object' => {
          'nested_attribute_attributes' => 'value'
        }
      )
    end
  end

  context "when it points to an attribute using the '*' array index wildcard" do
    controller ApplicationController do
      def index
        @params_snake_case = params(nested_attributes: [_array: { '*' => :string }])

        render nothing: true
      end
    end

    it 'then adds the _attributes suffix' do
      # noinspection RubyStringKeysInHashInspection
      get :index,
          'array' => [
            { 'string' => 'string' },
            { 'string' => 'string2' }
          ]

      # noinspection RubyStringKeysInHashInspection
      expect(assigns(:params_snake_case)).to eql(
        'controller' => 'anonymous',
        'action' => 'index',
        'array' => [
          { 'string_attributes' => 'string' },
          { 'string_attributes' => 'string2' }
        ]
      )
    end
  end
end
