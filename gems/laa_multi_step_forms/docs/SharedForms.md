# Shared forms

These are form objects that are generic enough the have been added into the gem
and can be reused in specific situations

## AddAnotherForm

This form is designed to be used when it is possible to add multiple instance of
an object, and the index page asks the question `Do you want to add another`.

The form has a single YesNoAnswer attribute and does not modify the application
when processed.

When using this pattern:
*  the controller will need to load any other data need for
the view into a separate data variable, this should be done in both thge `edit`
and `update` endpoints.
* `additional_permitted_params` need to be set to `[:add_another]` otherwise
the users selection will be ignored

example:

```ruby
module Steps
  class ItemsController < Steps::BaseStepController
    def edit
      @data_for_view = current_application.data_for_view
      @form_object = AddAnotherForm.build(
        current_application
      )
    end

    def update
      @data_for_view = current_application.data_for_view
      update_and_advance(AddAnotherForm, as: :work_items)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def additional_permitted_params
      [:add_another]
    end
  end
end
```

## DeleteForm

This form is designed to be used when it is possible to add multiple instance of
an object, and the objects need to be able to be deleted. This form take an `id`
attribute (to track which sub object should be deleted) and destorys the record
when processed.

When using this pattern:
* when determining the specific item to be deleted the id is passed in different
ways from the `edit` and `update` endpoints. (TODO: review how this can be
improved, potentially with nested routes)
* a flash message should be passed on success
* a fallback if the record can't be found should redirect the user to the index
page (for the set fo objects)

example:
```ruby
module Steps
  class ItemDeleteController < Steps::BaseStepController
    before_action :ensure_item

    def edit
      @form_object = DeleteForm.build(
        item,
        application: current_application,
      )
    end

    def update
      update_and_advance(DeleteForm, as: :item_delete, record: item, flash: flash_msg)
    end

    private

    def decision_tree_class
      Decisions::SimpleDecisionTree
    end

    def item
      @item ||= begin
        work_item_id = params[:item_id] || params.dig(:steps_delete_form, :id)
        current_application.items.find_by(id: item_id)
      end
    end

    def flash_msg
      { success: t('.edit.deleted_flash') }
    end

    def ensure_work_item
      item || redirect_to(edit_steps_items_path(current_application))
    end
  end
end
```