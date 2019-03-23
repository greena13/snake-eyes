# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'params default behaviour:', type: :controller do
  context 'when no arguments are passed' do
    controller ApplicationController do
      def index
        @params_snake_case = params

        render nothing: true
      end
    end

    context 'and there are no params' do
      it 'then returns an empty object' do
        get :index

        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index'
        )
      end
    end

    context 'and there are params' do
      it 'then returns correctly snake cased params' do
        # noinspection RubyStringKeysInHashInspection
        get :index,
            'integer' => 3,
            'string' => 'string',
            'boolean' => true,
            'simpleArray' => [
              0, 1, 2
            ],
            'shallowObject' => {
              'nestedAttribute' => 'value'
            },
            'arrayOfObjects' => [
              {
                'name' => 'object1'
              },
              {
                'name' => 'object2'
              },
              {
                'name' => 'object3'
              }
            ],
            'complexObject' => {
              'nestedObject' => {
                'deeperNestedObject' => {
                  'name' => 'deeplyNested'
                }
              },
              'anotherNestedObject' => {
                'deeperNestedObject' => {
                  'name' => 'anotherDeeplyNested',
                  'deepestNestedObject' => {
                    'name' => 'deeplyNested'
                  }
                }
              }
            },
            'arrayOfNestedObjects' => [
              {
                'level' => 1,
                'children' => [
                  {
                    'index' => 1
                  },
                  {
                    'index' => 2
                  },
                  {
                    'index' => 3
                  }
                ]

              },
              {
                'level' => 1,
                'parent' => {
                  'index' => 1
                }
              }
            ]

        # noinspection RubyStringKeysInHashInspection
        expect(assigns(:params_snake_case)).to eql(
          'controller' => 'anonymous',
          'action' => 'index',
          'integer' => '3',
          'string' => 'string',
          'boolean' => true,
          'simple_array' => %w[0 1 2],
          'shallow_object' => {
            'nested_attribute' => 'value'
          },
          'array_of_objects' => [
            {
              'name' => 'object1'
            },
            {
              'name' => 'object2'
            },
            {
              'name' => 'object3'
            }
          ],
          'complex_object' => {
            'nested_object' => {
              'deeper_nested_object' => {
                'name' => 'deeplyNested'
              }
            },
            'another_nested_object' => {
              'deeper_nested_object' => {
                'name' => 'anotherDeeplyNested',
                'deepest_nested_object' => {
                  'name' => 'deeplyNested'
                }
              }
            }
          },
          'array_of_nested_objects' => [
            {
              'level' => '1',
              'children' => [
                {
                  'index' => '1'
                },
                {
                  'index' => '2'
                },
                {
                  'index' => '3'
                }
              ]

            },
            {
              'level' => '1',
              'parent' => {
                'index' => '1'
              }
            }
          ]
        )
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
