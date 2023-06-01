# Tasklist

This is a generic component for an multi step form submission process,
with the goal being to show how far through the steps our user is, as
well as provide a function to allow a user to retrace their steps.

The tasklist is comprised of two parts:

## 1. TaskList::Collection subclass

This is used to define the tasks that a user needs to complete via
the `SECTIONS` constant, this also defines the order and grouping for
the tasks (a task must have a grouping)

```ruby
class MyTaskList < TaskList::Collection
  SECTIONS = [
    [:group1, [:item1]],
    [:group2, [:item2, :item3]],
  ].feeze
end
```

### Name and translation

To provide flexibility on on tasks, the task name can be determined by
a proc instead of a sttaic symbol, the proc should take the application
as the input and return a string that is used as the translation key
(said key will be nested under `tasklist.task` when translated).

If the key contains a `.`, then only the part prior to the dot is used
to in the subtask selection process defined below.

```ruby
SECTIONS = [
  [:group1, [->(app) { "item.#{app.item_type}" }, :item2]],
  ...
]
```

## 2. Task definitions

Each task in the above defined tasklist should have a presenter that
is used to determine the state of the defined task.

`Task::BaseTask` is provides a template for the available methods each
presenter needs to expose.

The specific base subclass selected using the `Tasks::BaseTask.build`
method that looks for an object under `Tasks` matching the provided
name (after constantize)

The following methods are available to overwrite:

### #path

This is the path to open when the step is clicked

### #not_applicable?

Determines if the step can be reached - this is set to `false` by default
in the base class to indiciate it has not been fully implemented.

### #can_start?

Indicates the task can be started. This can be done using either the
`fulfilled?` method with the previous task, or a direct check against
the DB.

example

```ruby
def can_start?
  fulfilled?(PreviousTask)
end
```

### #in_progress?

Indicates the task is currently in progress, it defaults to checking if the
URL is in the navigation stack.

> NOTE: This should not need to be overwritten

### #completed?

Indicates the task is completed, can either be a DB check or for more complex
forms it is recommended to use the valid check.

example

```ruby
def completed?
  Steps::ComplexStep.new(application:).valid?
end
```

### #fulfilled?

This is a helper method of the base task that loads the specified task
and checks if it reached a completed status.

## Complexity and Performance

It is recommended this page has a performance review, as with more complex
routes through the form objects and more complex checks on each steps it
is easy to imagine the load times on this page being sub-standard.

## 3. Additional configuration

### without section index numbering

It is possible to generate a tasklist without index numbering by passing
in the `show_index` variable as false when initializing the tasklist.

```ruby
@tasklist = MyTaskList.new(view_context, application: application, show_index: false)
```