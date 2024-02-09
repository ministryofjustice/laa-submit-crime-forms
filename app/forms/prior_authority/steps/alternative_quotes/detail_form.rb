module PriorAuthority
  module Steps
    module AlternativeQuotes
      class DetailForm < ::Steps::BaseFormObject
        include Rails.application.routes.url_helpers

        attribute :id, :string
        attribute :contact_full_name, :string
        attribute :organisation, :string
        attribute :postcode, :string

        validates :contact_full_name, presence: true
        validates :organisation, presence: true
        validates :postcode, presence: true, uk_postcode: true

        def http_verb
          record.persisted? ? :patch : :post
        end

        def url
          if record.persisted?
            prior_authority_steps_alternative_quote_detail_path(application, record)
          else
            prior_authority_steps_alternative_quote_details_path(application)
          end
        end

        private

        def persist!
          record.update!(attributes.except('id'))
        end
      end
    end
  end
end
