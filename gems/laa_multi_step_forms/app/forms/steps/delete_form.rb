require 'steps/base_form_object'

module Steps
  class DeleteForm < Steps::BaseFormObject
    attribute :id

    private

    def persist!
      record.destroy
    end
  end
end
