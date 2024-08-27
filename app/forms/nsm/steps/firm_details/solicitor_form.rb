module Nsm
  module Steps
    module FirmDetails
      class SolicitorForm < ::Steps::BaseFormObject
        attribute :first_name, :string
        attribute :last_name, :string
        attribute :reference_number, :string

        validates :first_name, presence: true
        validates :last_name, presence: true
        validates :reference_number, presence: true

        private

        def persist!
          solicitor = application.solicitor || application.build_solicitor
          solicitor.update!(attributes)
          application.update!(solicitor:)
        end
      end
    end
  end
end
