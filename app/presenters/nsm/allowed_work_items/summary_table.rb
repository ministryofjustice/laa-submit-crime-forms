module Nsm
  module AllowedWorkItems
    class SummaryTable
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::TagHelper

      def initialize(claim, skip_links: false)
        @claim = claim
        @skip_links = skip_links
      end

      def rows
        WorkItem::WORK_TYPE_SUMMARY_ORDER.map do |work_type|
          data = @claim.totals[:work_types][work_type.to_sym]
          time = data[:claimed_time_spent_in_minutes]
          net_cost = data[:claimed_total_exc_vat]
          allowed_time = data[:assessed_time_spent_in_minutes]
          allowed_net_cost = data[:assessed_total_exc_vat]

          [
            { text: name_text(work_type, data[:at_least_one_claimed_work_item_assessed_as_different_type]),
              width: 'govuk-!-width-one-quarter' },
            { text: time_text(time), numeric: true },
            { text: NumberTo.pounds(net_cost), numeric: true },
            { text: time_text(allowed_time), numeric: true },
            { text: NumberTo.pounds(allowed_net_cost), numeric: true },
          ]
        end
      end

      def name_text(work_type, any_changes)
        work_type_name = I18n.t("laa_crime_forms_common.nsm.work_type.#{work_type}")

        return work_type_name unless any_changes

        span = tag.span(work_type_name, title: I18n.t('nsm.work_items.type_changes.types_changed'))
        sup = tag.sup do
          if @skip_links
            I18n.t('nsm.work_items.type_changes.asterisk')
          else
            tag.a(I18n.t('nsm.work_items.type_changes.asterisk'), href: '#fn*')
          end
        end

        safe_join([span, ' ', sup])
      end

      def time_text(time)
        ApplicationController.helpers.format_period(IntegerTimePeriod.new(time.to_i), style: :minimal_html)
      end
    end
  end
end
