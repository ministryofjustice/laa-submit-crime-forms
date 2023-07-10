# Suggestion Box

This is a hack on the existing accessibility autocomplete (AA) code  to allow it to
acception values not currently in the list.

The functionality works by using the `showNoOptionsFound` option of the AA code, as
well as the feature that allow the setting of `name` parameter on the input box that
is generated. The name is required for the value to be present in the data passed to
the backend server.

> Example JS code:

```Javascript
const $acElements = document.querySelectorAll('[data-module="accessible-autocomplete"]')
if ($acElements) {
  for (let i = 0; i < $acElements.length; i++) {
    const name = $acElements[i].getAttribute('data-name')

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: $acElements[i],
      defaultValue: '',
      showNoOptionsFound: name === null,
      name: name
    })
  }
}
```

> We set the showNoOptionsFound based on the presence of the name variable. This allows
> us to use the Autocomplete functionality when limited to the list with the desired
> 'No Result found' messaging

By giving using the data comping from the AA input field we can allow the form to use this
as the source of truth.

> We need to allow the field to be passed through in the controller:

```ruby
def additional_permitted_params
  [:court_suggestion]
end
```

> And have the form set the value - We need to guard against the storing the value v's
> the ID in the field (not done in this instance)

```ruby
def court_suggestion=(value)
  self.court = value
end
```

This allows suggestion to be saved to the database, however it does raise issues when
revisiting the page, as the suggestion would not (by default) be in the list of default
options, this would in turn result in the field being empty and no data being deplayed.

The easiest way to overcome this is to add the suggestion to the list of options on page
load. To streamline this process I have created a helper to correctly render the element

> Example of helper code, using fake record being inserted at the top of the list

```ruby
def suggestion_select(form, field, values, id_field, value_field, *args, data: {}, **kwargs)
  values.unshift(fake_record(id_field, value_field, form.object[field]))

  data[:module] = 'accessible-autocomplete'
  data[:name] = "#{form.object_name}[#{field}_suggestion]"

  form.govuk_collection_select(field, values, id_field, value_field, *args, data:, **kwargs)
end

private

def fake_record(id_field, value_field, value)
  if id_field == value_field
    Struct.new(id_field).new(value)
  else
    Struct.new(id_field, value_field).new(value, value)
  end
end
```

