module PriorAuthority
  module Steps
    class HearingDetailForm < ::Steps::BaseFormObject
      attribute :next_hearing, :boolean
      attribute :next_hearing_date, :multiparam_date
      attribute :plea, :value_object, source: PleaOptions
      attribute :court_type, :value_object, source: CourtTypeOptions

      validates :next_hearing, inclusion: { in: [true, false] }
      validates :next_hearing_date,
                presence: true,
                multiparam_date: { allow_past: false, allow_future: true },
                if: :validate_next_hearing_date?

      validates :plea, inclusion: { in: PleaOptions.values }
      validates :court_type, inclusion: { in: CourtTypeOptions.values }

      def pleas
        PleaOptions.values
      end

      def court_types
        CourtTypeOptions.values
      end

      private

      def validate_next_hearing_date?
        next_hearing && (next_hearing_date.nil? || attribute_changed?(:next_hearing_date))
      end

      def persist!
        application.update!(attributes_with_resets)
      end

      def attributes_with_resets
        attributes.merge(reset_attributes)
      end

      def reset_attributes
        next_hearing_attributes_to_reset.merge(court_type_attributes_to_reset)
      end

      def next_hearing_attributes_to_reset
        {
          next_hearing_date: next_hearing ? next_hearing_date : nil
        }
      end

      def court_type_attributes_to_reset
        if court_type.magistrates_court?
          { psychiatric_liaison: nil,
            psychiatric_liaison_reason_not: nil }
        elsif court_type.central_criminal_court?
          { youth_court: nil }
        else
          { youth_court: nil,
            psychiatric_liaison: nil,
            psychiatric_liaison_reason_not: nil }
        end
      end
    end
  end
end
