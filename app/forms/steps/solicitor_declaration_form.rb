require 'steps/base_form_object'

module Steps
  class SolicitorDeclarationForm < Steps::BaseFormObject
    attribute :signatory_name, :string
    validates :signatory_name, presence: true

    private

    def persist!
      application.status = 'completed'
      application.update!(attributes)
    end
  end
end
