module Nsm
  class WorkItemsRow < SimpleDelegator
    include LaaMultiStepForms::CheckMissingHelper

    attr_reader :view

    def initialize(work_item, view)
      super(work_item)
      @work_item = work_item
      @view = view
    end

    delegate :each, to: :cells
    delegate :format_period, :current_application, :content_tag, :link_to, :t,
             to: :view

    def tr_html_attributes
      { id: }
    end

    def cells
      [
        { header: true, text: position, numeric: false, html_attributes: { id: "item#{position}" } },
        { header: true, text: item_with_link, numeric: false },
        { text: check_missing(completed_on) { completed_on.to_fs(:short_stamp) }, numeric: false },
        { text: check_missing(fee_earner), numeric: false },
        { text: check_missing(time_spent) { format_period(time_spent, style: :minimal_html) }, numeric: true },
        ({ text: NumberTo.percentage(uplift.to_f, multiplier: 1), numeric: true } if current_application.allow_uplift?),
        { text: action_links, numeric: true }
      ].compact
    end

    private

    def item_with_link
      link_to(
        check_missing(valid_work_type? && work_type) { t("laa_crime_forms_common.nsm.work_type.#{work_type}") },
        view.edit_nsm_steps_work_item_path(current_application, work_item_id: id),
        data: { turbo: 'false' },
        'aria-labelledby': "itemTitle item#{position} workType#{position}",
        id: "workType#{position}"
      )
    end

    def action_links
      content_tag(:ul, class: 'govuk-summary-list__actions-list') do
        content_tag(:li, duplicate_or_update_link, class: 'govuk-summary-list__actions-list-item') +
          content_tag(:li, delete_link, class: 'govuk-summary-list__actions-list-item')
      end
    end

    def duplicate_or_update_link
      if @work_item.complete?
        duplicate_link
      else
        update_link
      end
    end

    def duplicate_link
      link_to(
        t('.duplicate'),
        view.duplicate_nsm_steps_work_item_path(current_application, work_item_id: id),
        data: { turbo: 'false' },
        'aria-labelledby': "duplicate#{position} itemTitle item#{position} workType#{position}",
        id: "duplicate#{position}"
      )
    end

    def update_link
      link_to(
        t('.update'),
        view.edit_nsm_steps_work_item_path(current_application, work_item_id: id),
        data: { turbo: 'false' },
        'aria-labelledby': "itemTitle item#{position} workType#{position}"
      )
    end

    def delete_link
      link_to(
        t('.delete'),
        view.edit_nsm_steps_work_item_delete_path(current_application, work_item_id: id),
        data: { turbo: 'false' },
        'aria-labelledby': "delete#{position} itemTitle item#{position} workType#{position}",
        id: "delete#{position}"
      )
    end
  end
end
