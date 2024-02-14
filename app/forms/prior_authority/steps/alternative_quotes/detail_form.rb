module PriorAuthority
  module Steps
    module AlternativeQuotes
      class DetailForm < PriorAuthority::Steps::QuoteCostForm
        include Rails.application.routes.url_helpers

        attribute :id, :string
        attribute :contact_full_name, :string
        attribute :organisation, :string
        attribute :postcode, :string
        attribute :travel_time, :time_period
        attribute :travel_cost_per_hour, :decimal, precision: 10, scale: 2
        attribute :additional_cost_list, :string
        attribute :additional_cost_total, :decimal, precision: 10, scale: 2

        validates :contact_full_name, presence: true
        validates :organisation, presence: true
        validates :postcode, presence: true, uk_postcode: true

        include QuoteCostValidations

        validates :travel_time, time_period: true

        def total_cost
          main_cost + travel_cost + additional_cost
        end

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

        def main_cost
          per_item? ? item_cost : time_cost
        end

        def travel_cost
          return 0 unless travel_cost_per_hour.to_i.positive? && travel_time.to_i.positive?

          (travel_cost_per_hour * (travel_time.hours + (travel_time.minutes / 60.0))).round(2)
        end

        def additional_cost
          additional_cost_total.to_f
        end

        private

        def persist!
          record.update!(attributes.except('id', 'service_type'))
        end
      end
    end
  end
end
