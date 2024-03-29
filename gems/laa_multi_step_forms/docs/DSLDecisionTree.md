# DSL Decision Tree

This documentation refers to the code implemented (here)[https://github.com/ministryofjustice/laa-submit-crime-forms/blob/main/app/services/decisions/dsl_decision_tree.rb].

Look (here)[https://github.com/ministryofjustice/laa-submit-crime-forms/commit/82a50d76dad2bf6ee8e9c32edbbcce7fe03731f6#diff-603684f9e79565b6842d793e2bfaebf72f76ca1e2a45208d49d02ef7feb0df90] to review against the previous implementation.

## What?

This is a simple DSL that implements the same interface as the previous DecisionTree code implementation and as such it
the implementation can easily be swapped out without requiring changes to other aspects of the codebase. It currently layers on top of the existing DecisionTree code that was used in crime apply. Due to
this it is fully backwards compatible with the previous implementation.

## Why?

This was created to simplify the expression of the logical flow of the system. Making it easier to
read, understand and update the flow compared to the previous implementation. This has been coupled with an update to
the testing helper to try and make the tests easy to read, understand and update.

## How does it work?

The basic concept of the decision tree is that given the user has come from some location `A` they are redirected
to a new location `B`, this can then be complicated by adding logic such that they would instead be redirected to
a different location `C` if a specified condition is `X` met.

Hence the basic syntax of the DSl for the previous example would be:

```
from(A)
  .when(X).goto(show: C)
  .goto(show: B)
```

The above could be written on a single line, however breaking it down into `when` and `goto` pairs makes it easier
to parse, the logic will return the result of the first `goto` after a `when` condition has been met - notice the
final `goto` does not require a `when` condition as it catches all remaining choices.

## Downsides

The main downside of this approach is that the DSL is loaded within the Class object - this means we only need to
create a single instance of it on boot, but that does result in slower boot. This may become a concern as the
ruleset grows in the future - or multiple large rulesets exist.

It would be possible to move the rule definition into a instance, however this would have the downside of
needing to load the ruleset into memory each time it was used, slowing response times.

## Examples (with tests)

> NOTES in the below examples:
> * when I refer to the form object I am actually referring to the wrapper form object

### Simple transition from A -> B

```
from('A').goto(show: 'B')
from('B').goto(edit: 'C')
from('C').goto(index: 'D')

it_behaves_like 'a generic decision', from: 'A', goto: { action: :show, controller: 'B' }
it_behaves_like 'a generic decision', from: 'B', goto: { action: :edit, controller: 'C' }
it_behaves_like 'a generic decision', from: 'C', goto: { action: :index, controller: 'D' }
```

The goto must have a key of `show`, `edit` or `index`, which is used to set the action and
controller of the redirect.

### Transition with a conditional

The block in the `when` condition is applied to the form object that is passed in, so in this instance it is
expecting the form object to expose a `add_another` object/method.

```
from('A)
  .when(-> { add_another.yes? })
  .goto(edit: 'B')
  .goto(edit: 'C')

context 'answer yes to add_another' do
  before { allow(form).to receive(:add_another).and_return(YesNoAnswer::YES) }

  it_behaves_like 'a generic decision', from: 'A', goto: { action: :edit, controller: 'B' }
end

context 'answer no to add_another' do
  before { allow(form).to receive(:add_another).and_return(YesNoAnswer::NO) }

  it_behaves_like 'a generic decision', from: 'A', goto: { action: :edit, controller: 'C' }
end
```

### Additional parameters in the goto location

Additional parameters can be set in 3 ways:
1. static value -> this just adds the additional params in the hash
2. dynamic value (block without params) -> this executes on the block form object allowing the value to be set
3. dynamic value (block with params) -> this passes the result of the `when` block into the `goto` block
4. dynamic goto -> this is expected to return a hash

> NOTE: type 3 is not currently in use and unsure of a required use-case - documented for completeness

```
from('A').goto(edit: 'B', tag: 'help')
from('B').goto(edit: 'C', tag: -> { record.id })
from('C')
  .when(-> { record }).goto(edit: 'D', tag: ->(inst) { inst.id })
from('D').goto { { show: 'apples } }

it_behaves_like 'a generic decision', from: 'A', goto: { action: :edit, controller: 'B', tag: 'help' }
context do
  let(:tag) { record.id }
  it_behaves_like 'a generic decision', from: 'B', goto: { action: :edit, controller: 'C', tag: 'help' }, additional_param: :tag
end
context do
  let(:tag) { record.id }
  it_behaves_like 'a generic decision', from: 'C', goto: { action: :edit, controller: 'D', tag: 'help' }, additional_param: :tag
end
it_behaves_like 'a generic decision', from: 'C', goto: { action: :show, controller: 'apples' }
```

> NOTE: for non-static values the tests expects a `let` to expose the tag value (must have matching name to param) to exist that
> can be called from the text scope.

### Additional logic functionality

By default the `WRAPPER_CLASS` is set to the `SimpleDelegator` library, with the idea that this can be
overwritten with a custom class (inheriting from SimpleDelegator) which adding reusable methods that can
be called in the `when` and `goto` blocks.

This class is used to avoid adding methods to the form objects that are only used in the decision tree checks.

```
class CustomWrapperClass < SimpleDelegator
  def check?(value)
    form_list_field.include?(value)
  end
end

class MyDecisionTree < DslDecisionTree
  WRAPPER_CLASS = CustomWrapperClass

  from('A)
    .when(-> { check?('apples) }).goto('B')
end
```
