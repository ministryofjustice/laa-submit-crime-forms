module Nsm
  module AllowedWorkItems
    class SummaryTable
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::TagHelper

      def initialize(work_items)
        @work_items = work_items
      end

      def rows
        WorkItem::WORK_TYPE_SUMMARY_ORDER.map do |work_type|
          claimed_work_items = @work_items.select { _1.work_type == work_type }
          allowed_work_items = @work_items.select { _1.assessed_work_type == work_type }
          time = claimed_work_items.sum(&:time_spent)
          net_cost = claimed_work_items.sum(&:total_cost)
          allowed_time = allowed_work_items.sum(&:assessed_time_spent)
          allowed_net_cost = allowed_work_items.sum(&:allowed_total_cost)

          [
            { text: name_text(work_type, claimed_work_items), width: 'govuk-!-width-one-quarter' },
            { text: time_text(time), numeric: true },
            { text: NumberTo.pounds(net_cost), numeric: true },
            { text: time_text(allowed_time), numeric: true },
            { text: NumberTo.pounds(allowed_net_cost), numeric: true },
          ]
        end
      end

      def name_text(work_type, claimed_work_items)
        any_changes = claimed_work_items.any? { _1.assessed_work_type != _1.work_type }
        work_type_name = I18n.t("summary.nsm/cost_summary/work_items.#{work_type}")

        return work_type_name unless any_changes

        span = tag.span(work_type_name, title: I18n.t('nsm.work_items.type_changes.types_changed'))
        sup = tag.sup do
          tag.a(I18n.t('nsm.work_items.type_changes.asterisk'), href: '#fn*')
        end

        safe_join([span, ' ', sup])
      end

      def time_text(time)
        ApplicationController.helpers.format_period(time, style: :minimal_html)
      end
    end
  end
end
