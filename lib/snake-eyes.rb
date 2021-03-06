# frozen_string_literal: true

require 'snake_eyes/version'
require 'snake_eyes/interface_changes'

module SnakeEyes
  class << self
    attr_accessor :log_snake_eyes_parameters

    def configuration
      yield(SnakeEyes) if block_given?
    end

    alias config configuration
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
