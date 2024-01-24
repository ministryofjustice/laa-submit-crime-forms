module PriorAuthority
  module Steps
    class HearingDetailForm < ::Steps::BaseFormObject
      attribute :next_hearing_date, :multiparam_date
      attribute :plea, :value_object, source: PleaOptions
      attribute :court_type, :value_object, source: CourtTypeOptions

      validates :next_hearing_date, presence: true, multiparam_date: { allow_past: true, allow_future: true }
      validates :plea, inclusion: { in: PleaOptions.values }
      validates :court_type, inclusion: { in: CourtTypeOptions.values }

      def pleas
        PleaOptions.values
      end

      def court_types
        CourtTypeOptions.values
      end

      private

      def persist!
        application.update!(attributes)
      end
    end
  end
end
