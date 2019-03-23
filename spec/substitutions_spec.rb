# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'param\'s substitutions option:', type: :controller do
  context 'is empty' do
    controller ApplicationController do
      def index
        @params_snake_case = params(substitutions: {})

        render nothing: true
      end
    end

    it 'then does not attempt to perform any substitutions' do
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

  context 'is nil' do
    controller ApplicationController do
      def index
        @params_snake_case = params(substitutions: nil)

        render nothing: true
      end
    end

    it 'then does not attempt to perform any substitutions' do
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

  context 'points to an attribute that is not a nested object' do
    controller ApplicationController do
      def index
        @params_snake_case =
          params(substitutions: { string: { replace: 'abc', with: '123' } })

        render nothing: true
      end
    end

    context 'and the value of the attribute does NOT match' do
      it 'then does not do any substitution' do
        get :index,
            'string' => 'string'

        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'string' => 'string'
        )
      end
    end

    context 'and the value of the attribute does match' do
      it 'then does not do any substitution' do
        get :index,
            'string' => 'abc'

        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'string' => '123'
        )
      end
    end
  end

  context 'points to an attribute that is a nested object' do
    controller ApplicationController do
      def index
        @params_snake_case =
          params(
            substitutions: {
              shallow_object: {
                nested_attribute: { replace: 'abc', with: '123' }
              }
            }
          )

        render nothing: true
      end
    end

    context 'and the value of the attribute does NOT match' do
      it 'then does not do any substitution' do
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
            'nested_attribute' => 'value'
          }
        )
      end
    end

    context 'and the value of the attribute does match' do
      it 'then then performs the correct substitution' do
        # noinspection RubyStringKeysInHashInspection
        get :index,
            'shallowObject' => {
              'nestedAttribute' => 'abc'
            }

        # noinspection RubyStringKeysInHashInspection
        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'shallow_object' => {
            'nested_attribute' => '123'
          }
        )
      end
    end
  end

  context 'points to an attribute that is an array' do
    controller ApplicationController do
      def index
        @params_snake_case =
          params(
            substitutions: {
              array: {
                '*' => {
                  shallow_object: {
                    nested_attribute: { replace: 'abc', with: '123' }
                  }
                }
              }
            }
          )

        render nothing: true
      end
    end

    context 'and the value of the attribute does NOT match' do
      it 'then does not do any substitution' do
        # noinspection RubyStringKeysInHashInspection
        get :index,
            'array' => [
              {
                'shallowObject' => {
                  'nestedAttribute' => 'value'
                }
              },
              {
                'shallowObject' => {
                  'nestedAttribute' => 'value'
                }
              }
            ]

        # noinspection RubyStringKeysInHashInspection
        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'array' => [
            {
              'shallow_object' => {
                'nested_attribute' => 'value'
              }
            },
            {
              'shallow_object' => {
                'nested_attribute' => 'value'
              }
            }
          ]
        )
      end
    end

    context 'and the value of the attribute does match' do
      it 'then performs the correct substitution' do
        # noinspection RubyStringKeysInHashInspection
        get :index,
            'array' => [
              {
                'shallowObject' => {
                  'nestedAttribute' => 'value'
                }
              },
              {
                'shallowObject' => {
                  'nestedAttribute' => 'abc'
                }
              }
            ]

        # noinspection RubyStringKeysInHashInspection
        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'array' => [
            {
              'shallow_object' => {
                'nested_attribute' => 'value'
              }
            },
            {
              'shallow_object' => {
                'nested_attribute' => '123'
              }
            }
          ]
        )
      end
    end
  end

  context 'is an array' do
    controller ApplicationController do
      def index
        @params_snake_case =
          params(
            substitutions: {
              string:
                [{ replace: 'abc', with: '123' }, { replace: 'cde', with: '456' }]
            }
          )

        render nothing: true
      end
    end

    context 'and the value of the attribute does NOT match' do
      it 'then does not do any substitution' do
        get :index,
            'string' => 'string'

        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'string' => 'string'
        )
      end
    end

    context 'and the value of the attribute matches the first substitution' do
      it 'then performs the correct substitution' do
        get :index,
            'string' => 'abc'

        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'string' => '123'
        )
      end
    end

    context 'and the value of the attribute matches the second substitution' do
      it 'then performs the correct substitution' do
        get :index,
            'string' => 'cde'

        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'string' => '456'
        )
      end
    end
  end
end

# rubocop:enable Metrics/BlockLength
