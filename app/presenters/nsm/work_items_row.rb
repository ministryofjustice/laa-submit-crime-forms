module Nsm
  class WorkItemsRow
    attr_reader :work_item, :view

    def initialize(work_item, view)
      @work_item = work_item
      @view = view
    end

    delegate :each, to: :cells
    delegate :id, to: :work_item
    delegate :format_period, :current_application, :tag, :link_to, :t,
      to: :view

    def tr_html_attributes
      { id: }
    end

    def cells
      [
        { header: true, text: work_item.position, numeric: false, html_attributes: { id: "item#{work_item.position}" } },
        { header: true, text: item_with_link, numeric: false},
        { text: work_item.completed_on&.to_fs(:short_stamp), numeric: false},
        { text: work_item.fee_earner, numeric: false},
        { text: format_period(work_item.time_spent, style: :minimal_html), numeric: true },
        ({ text: NumberTo.percentage(work_item.uplift.to_f, multiplier: 1), numeric: true } if current_application.allow_uplift?),
        { text: action_links, numeric: true }
      ].compact
    end

    private

    def item_with_link
      link_to(
        t("summary.nsm/cost_summary/work_items.#{work_item.work_type.to_s}"),
        view.edit_nsm_steps_work_item_path(current_application, work_item_id: work_item.id),
        data: { turbo: 'false' },
        'aria-labelledby': "itemTitle item#{work_item.position} workType#{work_item.position}",
        id: "workType#{work_item.position}"
      )
    end

    def action_links
      tag.uk(class: 'govuk-summary-list__actions-list') do
        tag.li(class: "govuk-summary-list__actions-list-item") do
          link_to(
            t('.duplicate'),
            view.duplicate_nsm_steps_work_item_path(current_application, work_item_id: work_item.id),
            data: { turbo: 'false' },
            'aria-labelledby': "duplicate#{work_item.position} itemTitle item#{work_item.position} workType#{work_item.position}",
            id: "duplicate#{work_item.position}"
          )
        end +
        tag.li(class: "govuk-summary-list__actions-list-item") do
          link_to(
            t('.delete'),
            view.edit_nsm_steps_work_item_delete_path(current_application, work_item_id: work_item.id),
            data: { turbo: 'false' },
            'aria-labelledby': "delete#{work_item.position} itemTitle item#{work_item.position} workType#{work_item.position}",
            id: "workType#{work_item.position}"
          )
        end
      end
    end
  end
end