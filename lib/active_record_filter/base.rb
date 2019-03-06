# frozen_string_literal: true

module ActiveRecordFilter
  # Base class that should be extended when creating filters.
  #
  class Base
    def execute(filter_object)
      pipeline.execute(filter_object)
    end

    def results
      applied_filters.last.results
    end

    def removed
      model_class.where.not(id: results)
    end

    def at_step(index)
      applied_filters[index]
    end

    def applied_filters
      pipeline.applied_filters
    end

    class << self
      attr_reader :filter_components, :model_class

      def execute(filter_object = nil)
        new.tap { |filter| filter.execute(filter_object) }
      end

      def components(*components)
        @filter_components = components
      end

      def applies_to(model_class)
        @model_class = model_class
      end
    end

    private

    def pipeline
      @pipeline ||= Pipeline.new(model_class, *filter_components)
    end

    def model_class
      self.class.model_class
    end

    def filter_components
      self.class.filter_components
    end
  end
end
