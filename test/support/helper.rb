# frozen_string_literal: true

require 'support/test_model'

ActiveRecord::Base.establish_connection adapter: 'sqlite3', database: ':memory:'
load 'support/schema.rb'
