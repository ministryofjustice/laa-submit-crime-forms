# LAA Multi Step Form Step creation

A step is used to represent a single screen in the multi stage form
processing, the following is a starter guild to help create new steps
in the process. This guide should be used with existing steps as a
guide to the process.

## 1. Types of Steps

Both and edit and show steps are possible.

The difference being that edit steps are used to input data, while show steps
are to display data (generally used to confirm previously input data).

Edit steps type has a corresponding method that can be used in the routing file:

```
scope 'applications/:id' do
  namespace :steps do
    edit_step :claim_type
    show_step :start_page
  end
end
```

> NOTE: we are using application and steps in the URL to provide a unique path
> for the step. While this is not required it is recommended to use a consistant
> approach across applications.

> TODO: should we create a seperate help to setup this namespacing?

### Show steps

These create a routing record with just a `show` endpoint for the controller

### Edit steps

These create a `edit` and `update` endpoint

## 2. Controllers

By default both edit and show step controllers should inherit from
`Steps::BaseStepController`. This provides a number of reusable feature the main
one being:

### Navigation stack

By default the navigation stack will automatically be update to include the
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
hash that can be used by teh rails router to redirect to the next step.

This means that routing for multiple paths can be more easily tested outside
the controller object.

## 3. Value Objects



## 4. Form objects

The form object is the core of the multi step form engine, it is responsible for
the specific attributes that appear on the screen, as well as the validations
required for those attributes - the underlying ActiveRecord model does not contain
any validations by design, with all updates being done via the form object.

The below example is the simpliest implementation of a form object:

```
class ClaimTypeForm < Steps::BaseFormObject
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