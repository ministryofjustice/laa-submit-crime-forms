# LAA Multi Step Form Step creation

A step is used to represent a single screen in the multi stage form
processing, the following is a starter guide to help create new steps
in the task list. This guide should be used with existing steps as a
guide to the process.

## 1. Types of Steps

Both and edit and show steps are possible.

The difference being that edit steps are used to input data, while show steps
are to display data (generally used to confirm previously input data).

Edit steps type has a corresponding method that can be used in the routing file:

```ruby
scope 'applications/:id' do
  namespace :steps do
    edit_step :claim_type
    show_step :start_page
  end
end
```

In addition to this there are nested steps, these are helpful when adding
has_many records as they allow the nested objects ID to be in the url.

```ruby
scope 'applications/:id' do
  namespace :steps do
    crud_step :defendant, param: :defendant_id
  end
end
```
The above snippet creates an edit path of
`\applications\#{id}\steps\defendant\#{defendant_id}`
which is then handled by the `Steps::DefendantController` controller.

These types of controller operate the same as the basic `edit_step`
controllers, with the exception of having the addition `param` parameter
availble in the controller to help select the nested object. The also
provide a delete and confirm_destroy endpoint (this has not beed used
in the CRM-7 replacement, opting to use separate Delete endpoints).

> NOTE: we are using application and steps in the URL to provide a unique path
> for the step. While this is not required it is recommended to use a consistant
> approach across applications.

### Show steps

These create a routing record with just a `show` endpoint for the controller

### Edit steps

These create a `edit` and `update` endpoint

## 2. Controllers

By default both edit and show step controllers should inherit from
`Steps::BaseStepController`. This provides a number of reusable features, the main
one being:

### Navigation stack

By default the navigation stack will automatically be updated to include the
current path whenever a step controller is accessed.

The main purpose of this is to track which path the user took through the pages
as well as tracking progress. When a user visit a previous page all progress is
erased from the navigation stack, this is done as the user may take a different
path when moving through the steps (This does not effect the data that is stored
and each step needs to ensure it deletes old data when updating if it not valid
in the current path).

### update_and_advance

This is magic method that is responsible for permitting the attributes associated
with the current step, and either running the validations and saving it or just
saving the data (this is done when saving a draft version). It also redirects to
the next step based on the `decision_tree_class` (see Routing between steps).

There are a few "magic" params that will cause special behaviour to be applied here:

* `commit_draft` will skip validations and redirect to `after_commit_redirect_path`. This is used for the "Save and come back later" flow
* `reload` will skip validations, not persist data, and re-render the page. This is used to updatean on-screen calculation based on data entered so far without persisting anything in the database (particularly relevant when dealing with "add another" forms)
* `save_and_refresh` will skip validations, persist the data, and redirect back to the same page again

### additional_permitted_params

By default the `update_and_advance` method will permit params based on the attributes
in the form being processed, however it is sometimes required to pass additional
attributes into the form to allow further processing to occur. This is done by
adding the parameter names to the `additional_permitted_params` response

> NOTE: This is expecting an array or hash as the response.

## 3. Routing between steps

Routing to the next step is handled by the DecisionTree object returned from the
`decision_tree_class` method. The key here is that the current step and the
underlying application object are passing into this class and it returns a
hash that can be used by the rails router to redirect to the next step.

This means that routing for multiple paths can be more easily tested outside
the controller object.

## 3. Value Objects

These are useful when process a list of items - i.e. radio buttons or checkboxes
where the resulting value/s will be stored in a single field.

This is an alternative to having a lookup table and is preferred due to it NOT
requiring maintenance in the DB, and being easier to add/remove values through
the code itself.

## 4. Form objects

The form object is the core of the multi step form engine, it is responsible for
the specific attributes that appear on the screen, as well as the validations
required for those attributes - the underlying ActiveRecord model does not contain
any validations by design, with all updates being done via the form object.

The below example is the simpliest implementation of a form object:

```
class ClaimTypeForm < ::Steps::BaseFormObject
  attribute :name, :string

  private

  def persist!
    application.update!(attributes)
  end
end
```

It add a single attribute `claim_type` (this is part of ActiveModel::Attributes)
using the `:string` type, it then implements the required `persist!` method which
is responsible for writing the data to the database.

> NOTE: `persist!` is designed to write the data directly to the DB WITHOUT validations,
> calls to `valid?` are handled by higher level (and public) methods `save` and `save!`

## 6. Task list

The task menu represent a generic type of step that shows the progress
through the form as well as allow users to backtrack previous progress.

This is documented separately.

## 7. HTML View

To use the form in the the view there is a shortcut helper `step_form` that should be
used instead of the default `form_with` rails helper as without doing this the screen
will have multiple errors when attempting to render which are NOT easy to debug.

> NOTE: The `step_form` helper is just a wrapper around `form_with` as such the object `f` can be
> used in the same way as as normal.

```
<%= step_form @form_object do |f| %>
  # form stuff
<% end >
```