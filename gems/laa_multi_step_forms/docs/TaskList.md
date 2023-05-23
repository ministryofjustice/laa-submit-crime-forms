# Tasklist

This is a generic component for an mutli step form submission process,
with the goal being to show how far through the steps are user is, as
well as provide a function to allow a user to retrace there steps.

The tasklist if comprised of two parts:

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

## 2. Task definitions

Each task in the above defined tasklist should have a presenter that
is used to determine the state of the defined task.

`Task::BaseTask` is provides a template for the available methods each
presenter needs to expose.

The following methods are available to overrite:

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

Idicates the task is currently in progress, it defaults to checking if the
URL is in the navigation stack.

> NOTE: This should not need to be overwritten

### #completed?

Indicates the task is completed, can eitehr be a DB check or for more complex
forms it is recommended to use the valid check.

example

```ruby
def completed?
  Steps::ComplexStep.new(application:).valid?
end
```

### #filfilled?

This is a helper method of the base task that loads the specified task
and checks if it reached a completed status.

## Complexity and Performance

It is recommended this page has a performance review, as with more complex
routes through the form objects and more complex checks on each steps it
is easy to image the load times on this page being sub-standard.

