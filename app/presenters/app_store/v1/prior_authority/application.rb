module AppStore
  module V1
    module PriorAuthority
      class Application < AppStore::V1::Base
        include PriorAuthorityDetails

        one :firm_office, AppStore::V1::FirmOffice
        one :solicitor, AppStore::V1::Solicitor
        one :defendant, AppStore::V1::Defendant
        many :supporting_documents, AppStore::V1::SupportingDocument
        many :additional_costs, AppStore::V1::PriorAuthority::AdditionalCost
        many :further_informations, AppStore::V1::FurtherInformation, key: :further_information
        many :incorrect_informations, AppStore::V1::PriorAuthority::IncorrectInformation, key: :incorrect_information
        many :quotes, AppStore::V1::PriorAuthority::Quote

        def primary_quote
          @primary_quote ||= quotes.detect(&:primary)
        end

        def alternative_quotes
          @alternative_quotes ||= quotes.reject(&:primary)
        end

        def pending_further_information
          further_informations.select { _1.information_supplied.blank? }.max_by(&:requested_at)
        end

        def pending_incorrect_information
          incorrect_informations.select { _1.sections_changed.blank? }.max_by(&:requested_at)
        end

        PriorAuthorityApplication.states.each_key do |state_string|
          define_method(:"#{state_string}?") { state == state_string }
        end

        attribute :office_code, :string
        attribute :prison_law, :boolean
        attribute :ufn, :string
        attribute :laa_reference, :string
        attribute :rep_order_date, :date
        attribute :reason_why, :string
        attribute :main_offence_id, :string
        attribute :custom_main_offence_name, :string
        attribute :client_detained, :boolean
        attribute :prison_id, :string
        attribute :custom_prison_name, :string
        attribute :subject_to_poca, :boolean
        attribute :next_hearing_date, :date
        attribute :plea, :string
        attribute :court_type, :string
        attribute :youth_court, :boolean
        attribute :psychiatric_liaison, :boolean
        attribute :psychiatric_liaison_reason_not, :string
        attribute :next_hearing, :boolean
        attribute :service_type, :string
        attribute :custom_service_name, :string
        attribute :prior_authority_granted, :boolean
        attribute :no_alternative_quote_reason, :string
        attribute :created_at, :datetime
        attribute :updated_at, :datetime
        attribute :last_updated_at, :datetime
        attribute :status, :string
        attribute :resubmission_requested, :datetime
        attribute :resubmission_deadline, :datetime
        attribute :assessment_comment, :string
        attribute :application_id, :string

        alias state status
        alias app_store_updated_at last_updated_at
        alias id application_id
        alias to_param id
      end
    end
  end
end
