module Nsm
  module AllowedWorkItems
    class Table
      include ActionView::Helpers::OutputSafetyHelper
      include ActionView::Helpers::TagHelper
      include ActionView::Helpers::UrlHelper

      attr_reader :type_changed

      def initialize(work_items)
        @work_items = work_items
        @type_changed = []
      end

      def rows
        @work_items.map do |work_item|
          [
            { header: true, text: work_item.position, numeric: false },
            { header: true, text: name(work_item), numeric: false },
            { text: work_item.adjustment_comment, numeric: false,
html_attributes: { class: 'govuk-!-text-break-anywhere govuk-!-width-one-quarter' } },
            { text: ApplicationController.helpers.format_period(work_item.assessed_time_spent, style: :minimal_html),
                    numeric: true },
            { text: NumberTo.percentage(work_item.assessed_uplift.to_f, multiplier: 1), numeric: true },
            { text: NumberTo.pounds(work_item.allowed_total_cost), numeric: true },
          ]
        end
      end

      def name(work_item)
        item_with_link = link_to(I18n.t("summary.nsm/cost_summary/work_items.#{work_item.assessed_work_type}"),
                                 item_path(work_item))

        return item_with_link unless work_item.assessed_work_type != work_item.work_type

        @type_changed << work_item

        span = tag.span(id: "changed-#{@type_changed.length}",
                        title: I18n.t('nsm.work_items.type_changes.type_changed')) do
          item_with_link
        end

        sup = tag.sup { link_to("[#{@type_changed.length}]", "#fn#{@type_changed.length}") }
        safe_join([span, ' ', sup])
      end

      def item_path(work_item)
        Rails.application.routes.url_helpers.item_nsm_steps_view_claim_path(id: work_item.claim_id,
                                                                            item_type: :work_item,
                                                                            item_id: work_item.id)
      end
    end
  end
end
