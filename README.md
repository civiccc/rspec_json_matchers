# rspec_json_matchers

Are you tired of unreadable output while verifying your API's JSON output? What
about duplicating and losing track of your JSON structure definitions?
`rspec_json_matchers` provides declarative JSON structure definitions and
matchers with clear error output.

## How to use

### Add it to your `Gemfile`
```ruby
gem 'rspec_json_matchers'
```

### Add config `spec/spec_helper.rb`
```ruby
RSpec.configure do |config|
	config.include RSpecJsonMatchers
end
```

Optionally if you choose to define your matchers in a their own directory,
import them explicitly like this:

```ruby
Dir[Rails.root.join('spec/json_matchers/**/*.rb')].each { |f| require f }
```

### Define your matchers
```ruby
RSpecJsonMatchers.define_api_matcher :json_object do
	strings { an_instance_of(String) }
	integers { a_kind_of(Integer) }
	actual_values { 10 }
	keys_that_should_not_exist { absent }
	booleans { a_boolean_value }
	nilable { a_nil_value.or(a_kind_of(Integer)) }
	another_object { a_serialized_other_json_object }

	nested_structure do
		match_api_response(
			foo: an_instance_of(String),
			bar: 'baz'
		)
	end
end
```

Your matchers will be available as `a_serialized_object_name` and can be used
through `match_api_response(a_serialized_object_name)` or
`be_a_serialized_object_name`


### Write your test!

See the `spec/` folder for an example


## Authors
* Ryan Fitzgerald [rf-]
* Hao Su [haosu]
