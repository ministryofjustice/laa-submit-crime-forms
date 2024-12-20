module Nsm
  module Steps
    class CaseDisposalForm < ::Steps::BaseFormObject
      attribute :plea, :value_object, source: PleaOptions
      attribute :plea_category
      validates :plea, presence: true, inclusion: { in: PleaOptions.values }

      # rubocop:disable Style/HashEachMethods
      PleaOptions.values.each do |plea|
        next unless plea.requires_date_field?

        attribute "#{plea.value}_date", :multiparam_date
        validates "#{plea.value}_date", presence: true,
                multiparam_date: { allow_past: true, allow_future: false },
                if: ->(obj) { obj.plea == plea }
      end
      # rubocop:enable Style/HashEachMethods

      def choices
        {
          guilty_pleas: PleaOptions::GUILTY_OPTIONS,
          not_guilty_pleas: PleaOptions::NOT_GUILTY_OPTIONS,
        }
      end

      private

      def persist!
        application.update!(attributes_with_resets)
      end

      # ensure we reset any date fields when not the plea
      def attributes_with_resets
        results = attributes.dup

        # rubocop:disable Style/HashEachMethods
        PleaOptions.values.each do |plea_inst|
          next if plea_inst == plea || !plea_inst.requires_date_field?

          results["#{plea_inst.value}_date"] = nil
        end
        # rubocop:enable Style/HashEachMethods

        results['plea_category'] = PleaOptions.new(results['plea']).category
        results
      end
    end
  end
end
