require 'spec_helper'

RSpec.describe ApplicationController, type: :controller do
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

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index"
        })
      end
    end

    context 'and there are params' do
      it 'then returns correctly snake cased params' do
        get :index, {
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
                },
            ],
            'complexObject' => {
                'nestedObject' => {
                    'deeperNestedObject' => {
                        'name' => 'deeplyNested'
                    }
                },
                'anotherNestedObject' => {
                    'deeperNestedObject' => {
                        'name' =>  'anotherDeeplyNested',
                        'deepestNestedObject' => {
                            'name' => 'deeplyNested'
                        }
                    }
                },
            },
            'arrayOfNestedObjects' => [
                {
                    'level' => 1,
                    'children' => [
                        {
                            'index' => 1,
                        },
                        {
                            'index' => 2,
                        },
                        {
                            'index' => 3,
                        },
                    ]

                },
                {
                    'level' => 1,
                    'parent' => {
                        'index' => 1,
                    }
                }
            ]

        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'integer' => "3",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
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
                },
            ],
            'complex_object' => {
                'nested_object' => {
                    'deeper_nested_object' => {
                        'name' => 'deeplyNested'
                    }
                },
                'another_nested_object' => {
                    'deeper_nested_object' => {
                        'name' =>  'anotherDeeplyNested',
                        'deepest_nested_object' => {
                            'name' => 'deeplyNested'
                        }
                    }
                },
            },
            'array_of_nested_objects' => [
                {
                    'level' => "1",
                    'children' => [
                        {
                            'index' => "1",
                        },
                        {
                            'index' => "2",
                        },
                        {
                            'index' => "3",
                        },
                    ]

                },
                {
                    'level' => "1",
                    'parent' => {
                        'index' => "1",
                    }
                }
            ]

        })
      end
    end
  end

  context "and the nested_attributes option" do
    context "is empty" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: {})

          render nothing: true
        end
      end

      it "then does not attempt to add the _attributes suffix" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        })
      end
    end

    context "is nil" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: nil)

          render nothing: true
        end
      end

      it "then does not attempt to add the _attributes suffix" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        })
      end
    end

    context "points to an attribute that is not a nested object" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: [ :string ])

          render nothing: true
        end
      end

      it "then adds the _attributes suffix" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string_attributes' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        })
      end
    end

    context "points to an attribute that is a nested object" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: [ :shallow_object ])

          render nothing: true
        end
      end

      it "then adds the _attributes suffix" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object_attributes' => {
                'nested_attribute' => 'value'
            }
        })
      end
    end

    context "points to a deeply nested attribute" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: { shallow_object: :nested_attribute })

          render nothing: true
        end
      end

      it "then adds the _attributes suffix to all parents" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object_attributes' => {
                'nested_attribute_attributes' => 'value'
            }
        })
      end
    end

    context "points to a deeply nested attribute using nested array" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: { shallow_object: [ :nested_attribute ] })

          render nothing: true
        end
      end

      it "then adds the _attributes suffix to all parents" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object_attributes' => {
                'nested_attribute_attributes' => 'value'
            }
        })
      end
    end

    context "points to an attribute using the leading underscore convention" do
      controller ApplicationController do
        def index
          @params_snake_case = params(nested_attributes: { _shallow_object: :nested_attribute })

          render nothing: true
        end
      end

      it "then adds the _attributes suffix to the inner object only" do
        get :index, {
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute' => 'value'
            }
        }

        expect(assigns(:params_snake_case)).to eql({
            "controller" => "anonymous",
            "action" => "index",
            'string' => 'string',
            'boolean' => true,
            'simple_array' => [
                "0", "1", "2"
            ],
            'shallow_object' => {
                'nested_attribute_attributes' => 'value'
            }
        })
      end
    end
  end
end
