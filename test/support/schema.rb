# frozen_string_literal: true

ActiveRecord::Schema.define do
  self.verbose = false

  create_table :test_models, force: true do |t|
    t.string :column_a
    t.integer :column_b
    t.integer :column_c
  end
end
