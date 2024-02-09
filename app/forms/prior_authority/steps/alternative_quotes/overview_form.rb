module PriorAuthority
  module Steps
    module AlternativeQuotes
      class OverviewForm < ::Steps::BaseFormObject
        attribute :alternative_quotes_still_to_add, :boolean
        validates :alternative_quotes_still_to_add, inclusion: { in: [true, false] }

        attribute :no_alternative_quote_reason, :string

        validates :no_alternative_quote_reason, presence: true, if: :no_alternative_quotes?

        def alternative_quotes
          application.alternative_quotes.map { AlternativeQuotes::DetailForm.build(_1, application:) }
        end

        def quotes_added
          application.alternative_quotes.count
        end

        private

        def persist!
          application.update!(attributes)
        end

        def no_alternative_quotes?
          alternative_quotes_still_to_add == false && application.alternative_quotes.none?
        end
      end
    end
  end
end
