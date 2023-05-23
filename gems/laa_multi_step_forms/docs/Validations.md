# Validations

A number of custoim validators have been created to help simplify using the forms.

## Multi param date

This is used with the `govuk_date_field` and validates both the parts of the date
field (day, month, year) and the full date to provide the simpliest error messages
to follow. In addition this validator supports the following criteria:

* allow_past - true by default
* allow_future - false by default
* earliest_year - 1900 by default
* latest_year - 2050 by default

In order to use the default value, just pass true into the validator, otherwise you
can specify an override:

```ruby
validates :date, multiparam_date: true # use the defaults values
validates :next_event_date, multiparam_date: { allow_past: false, allow_future: true }
```

> NOTE: This is designed to be use in conjunction with the `Type::MultiparamDate` type

## Nested Objects

The `NestedValidator` is designed to allow the `govuk_error_summary` method to render
error messages that occurred on nested objects. This validator will work with a single
nested object or an array (i.e. has_many) of nested object.

When validating an array of objects a `name` variable is passed into the I18n resolver
for the error message, by default this is an integer (starting at 1) for the position
of the object in the array. It is possible to overwrite this value to instead call a
message on the underlying object.

```ruby
class MyForm << Steps::BaseFormObject
  attribute :single_nested_object
  attribute :array_of_nested_objects

  validates :single_nested_object, nested: true
  validates :array_of_nested_objects, nested: { name: :nested_object_name }

  private

  def nested_object_name(index)
    return 'main' if index.zero?
    "record #{index}"
  end
end
```

> NOTE: Validations rae skipped if no object is passed in

## UK postcode

This uses the `uk_postcode` gem to validate postcode fields.

example:

```ruby
validates :postcode, uk_postcode: true
```