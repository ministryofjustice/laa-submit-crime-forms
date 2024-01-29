module PriorAuthority
  module Steps
    module AdditionalCosts
      class OverviewForm < ::Steps::BaseFormObject
        attribute :additional_costs_still_to_add, :boolean
        validates :additional_costs_still_to_add, inclusion: { in: [true, false] }

        def additional_costs
          application.additional_costs.map { AdditionalCosts::DetailForm.build(_1, application:) }
        end

        def costs_added
          additional_costs.count
        end

        def any_costs_added?
          costs_added.positive?
        end

        private

        def persist!
          application.update!(attributes)
        end
      end
    end
  end
end
