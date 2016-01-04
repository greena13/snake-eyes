require "snake-eyes/version"
require "snake-eyes/interface_changes"

module SnakeEyes
  class << self
    attr_accessor :log_snake_eyes_parameters

    def configuration
      if block_given?
        yield(SnakeEyes)
      end
    end

    alias :config :configuration
  end

  @log_snake_eyes_parameters = true
end

module ActionController
  class Base
    class << self
      def snake_eyes_params
        include SnakeEyes::InterfaceChanges
      end
    end
  end
end
