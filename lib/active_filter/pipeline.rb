# frozen_string_literal: true

module ActiveFilter
  # Executes a series of filters on a specific model class.
  # Stores each execution step in order to figure out which step
  # filtered away which entities.
  #
  class Pipeline
    attr_reader :applied_filters

    def initialize(model_class, *component_classes)
      @model_class       = model_class
      @component_classes = component_classes
      @applied_filters   = []
    end

    def execute(filter_object)
      @applied_filters = []

      execute_pipeline(filter_object)
    end

    private

    attr_reader :component_classes, :model_class

    def execute_pipeline(filter_object)
      relation = model_class.all

      component_classes.each do |component_class|
        relation = apply_filter(relation, component_class, filter_object)

        break if relation.empty?
      end

      relation
    end

    def apply_filter(current_relation, component_class, filter_object)
      component = component_class.new(filter_object)

      applied_filter = AppliedFilter.new(current_relation, component)
      applied_filters << applied_filter

      applied_filter.relation
    end

    # Represents a step in the pipeline execution.
    # Stores how the relation looks after a specific component is applied.
    # Used for internal house keeping.
    #
    class AppliedFilter
      attr_reader :relation, :component

      def initialize(previous_relation, component)
        @previous_relation = previous_relation
        @component         = component
        @relation          = previous_relation.merge(component.filter)
      end

      def results
        relation
      end

      def removed
        previous_relation.where.not(id: relation)
      end

      private

      attr_reader :previous_relation
    end
  end
end
