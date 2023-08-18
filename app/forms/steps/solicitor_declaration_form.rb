require 'steps/base_form_object'

module Steps
  class SolicitorDeclarationForm < Steps::BaseFormObject
    attribute :signatory_name, :string
    validates :signatory_name, presence: true, format: { with: /\A[a-z,.'\-]+( +[a-z,.'\-]+)+\z/i }

    private

    def persist!
      application.status = 'completed'
      application.update!(attributes)

      NotifyAppStore.new(claim: application).process
    end
  end
end
