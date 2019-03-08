# frozen_string_literal: true

require 'minitest/autorun'
require 'active_record_filter'
require 'support/helper'

class ActiveRecordFilterTest < Minitest::Test
  class TestComponentA < ActiveRecordFilter::Component
    def filter
      TestModel.where(column_a: filter_object.query)
    end
  end

  class TestComponentB < ActiveRecordFilter::Component
    def filter
      TestModel.order(column_b: :desc)
    end
  end

  class TestComponentC < ActiveRecordFilter::Component
    def filter
      TestModel.where('column_c > ?', filter_object.min_value)
    end
  end

  class TestFilterAB < ActiveRecordFilter::Base
    applies_to TestModel

    components TestComponentA,
               TestComponentB
  end

  class TestFilterAC < ActiveRecordFilter::Base
    applies_to TestModel

    components TestComponentA,
               TestComponentC
  end

  class TestFilterB < ActiveRecordFilter::Base
    applies_to TestModel

    components TestComponentB
  end

  class TestFilterNotImplemented < ActiveRecordFilter::Base
    applies_to TestModel

    components ActiveRecordFilter::Component
  end

  class FilterObject
    attr_reader :query, :min_value

    def initialize(query: nil, min_value: nil)
      @query     = query
      @min_value = min_value
    end
  end

  def setup
    TestModel.destroy_all

    @model1 = TestModel.create(column_a: 'test', column_b: 100, column_c: 3)
    @model2 = TestModel.create(column_a: 'test', column_b: 500, column_c: 7)
    @model3 = TestModel.create(column_a: 'spec', column_b: 500, column_c: 9)
    @model4 = TestModel.create(column_a: 'spec', column_b: 100, column_c: 1)
  end

  def test_execution_results
    filter_object = FilterObject.new(query: 'test')
    filter        = TestFilterAB.execute(filter_object)
    results       = filter.results

    assert_equal results.count, 2
    assert_equal results.first, @model2
    assert_equal results.second, @model1
    assert_equal filter.applied_filters.count, 2
  end

  def test_execution_removed
    filter_object = FilterObject.new(query: 'test')
    filter        = TestFilterAB.execute(filter_object)
    removed       = filter.removed

    assert_equal removed.count, 2
    assert_equal removed, [@model3, @model4]
  end

  def test_at_step
    filter_object = FilterObject.new(query: 'test')
    filter        = TestFilterAB.execute(filter_object)


    assert_equal filter.at_step(0).component.class, TestComponentA
    assert_equal filter.at_step(1).component.class, TestComponentB
  end

  def test_applied_filters
    filter_object = FilterObject.new(query: 'test')
    filter        = TestFilterAB.execute(filter_object)
    components    = filter.applied_filters.map(&:component).map(&:class)

    assert_equal components, [TestComponentA, TestComponentB]
  end

  def test_execution_without_filter_object
    filter = TestFilterB.execute

    assert_equal filter.results.count, 4
  end

  def test_raises_not_implemented_without_filter_method
    assert_raises NotImplementedError do
      TestFilterNotImplemented.execute
    end
  end

  def test_filter_results
    filter_object = FilterObject.new(query: 'test', min_value: 5)
    filter        = TestFilterAC.execute(filter_object)
    filters       = filter.applied_filters

    assert_equal filters[0].results, [@model1, @model2]
    assert_equal filters[1].results, [@model2]
  end

  def test_filter_removed
    filter_object = FilterObject.new(query: 'test', min_value: 5)
    filter        = TestFilterAC.execute(filter_object)
    filters       = filter.applied_filters

    assert_equal filters[0].removed, [@model3, @model4]
    assert_equal filters[1].removed, [@model1]
  end

  def test_filter_component
    filter_object = FilterObject.new(query: 'test', min_value: 5)
    filter        = TestFilterAC.execute(filter_object)
    filters       = filter.applied_filters

    assert_equal filters[0].component.class, TestComponentA
    assert_equal filters[1].component.class, TestComponentC
  end
end
