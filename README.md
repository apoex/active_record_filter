# ActiveRecordFilter

ActiveRecordFilter provides a simple interface to build large filters out
of smaller reusable components. Filters can be investigated to see which
step in the filter removed which entities.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'active_record_filter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install active_record_filter

## Usage

### Defining components

Each component is defined as a subclass to `ActiveRecordFilter::Component` and
implements `filter`. The implemented method should return an ActiveRecord
relation and a `filter_object` can be accessed for dynamic filtering.

```ruby
class UserWithActiveSubscriptionsComponent < ActiveRecordFilter::Component
  def filter
    User.joins(:subscriptions).merge(Subscription.active)
  end
end

class UserEmailComponent < ActiveRecordFilter::Component
  def filter
    User.where("email LIKE '%@?'", filter_object.domain)
  end
end

class UserRatingPrioritizerComponent < ActiveRecordFilter::Component
  def filter
    User.order(rating: :desc)
  end
end
```

### Defining filters

Filters are defined by extending `ActiveRecordFilter::Base`, specifying which model
it `applies_to` and which `components` should be applied.

```ruby
class PromotableUsersFilter < ActiveRecordFilter::Base
  applies_to User

  components UserWithActiveSubscriptionsComponent,
             UserEmailComponent,
             UserRatingPrioritizerComponent
end
```

### Defining filter objects

Filters can be executed with an optional `filter_object`.
This object must implement any methods used in the components of the filter.

It can be an already existing object, e.g a company that in the example above
implements `domain` that could return for example `google.com` or `facebook.com`

Or it could be a wrapper object like below:

```ruby
class PromotableUserFilterObject
  attr_reader :domain

  def initialze(domain)
    @domain = domain
  end
end
```

### Executing filters

In order to execute a filter, simply call `execute` with an optional
`filter_object`. The `execute` method returns an instance of a filter.
`results` can then be called in order to get the final ActiveRecord relation.
`removed` can be called to see which records were filtered away.

```ruby
def find_promotable_users(domain, count)
  filter_object = PromotableUserFilterObject.new(domain)
  filter        = PromotableUsersFilter.execute(filter_object)

  filter.results.limit(count)
end
```

To find out what happened at each step the following can be done:

```ruby

def print_filter
  filter_object = PromotableUserFilterObject.new('google.com')
  filter        = PromotableUsersFilter.execute(filter_object)

  filter.applied_filters.each do |applied_filter|
    results   = applied_filter.results.distinct.count
    removed   = applied_filter.removed.distinct.count
    component = applied_filter.component.class.name

    puts "#{component}, results: #{results}, removed: #{removed}"
  end
end
```

Or what happened at a specific step:

```ruby
def print_filter_at(index)
  filter_object = PromotableUserFilterObject.new('google.com')
  filter        = PromotableUsersFilter.execute(filter_object)

  applied_filter = filter.at_step(index)

  results   = applied_filter.results.distinct.count
  removed   = applied_filter.removed.distinct.count
  component = applied_filter.component.class.name

  puts "#{component}, results: #{results}, removed: #{removed}"
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/apoex/active_record_filter. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ActiveRecordFilter project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/apoex/active_record_filter/blob/master/CODE_OF_CONDUCT.md).
