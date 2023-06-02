require 'steps/base_form_object'

# TODO: move this to the engine

# This is a generic form to allow a record to be deleted

module Steps
  class DeleteForm < Steps::BaseFormObject
    attribute :id

    private

    def persist!
      record.destroy
    end
  end
end
