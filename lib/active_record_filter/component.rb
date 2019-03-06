# frozen_string_literal: true

module ActiveRecordFilter
  # Base component that other filter components should extend.
  # A component must implement `filter` that returns an ActiveRecord relation.
  #
  class Component
    def initialize(filter_object)
      @filter_object = filter_object
    end

    def filter
      raise NotImplementedError
    end

    protected

    attr_reader :filter_object
  end
end
