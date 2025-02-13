module Nsm
  class IncompleteItems
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TranslationHelper

    # govuk_link_to required modules
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include ActionView::Helpers::UrlHelper
    # for path methods
    include Routing

    attr_reader :controller

    def initialize(items, claim, type, controller)
      @items = items
      @claim = claim
      @type = type
      @controller = controller
    end

    def incomplete_items
      @items.reject(&:complete?).sort_by(&:position)
    end

    def summary
      "#{t("#{path_key}.incomplete_summary", count: incomplete_items.count)}: #{links}"
    end

    def links
      incomplete_items.map do |item|
        govuk_link_to(
          path_title(item),
          path_url(item)
        )
      end.join(', ')
    end

    private

    def path_title(item)
      t("#{path_key}.item", index: item.position)
    end

    def path_url(item)
      if item.is_a? WorkItem
        edit_nsm_steps_work_item_path(@claim, work_item_id: item.id)
      elsif item.is_a? Disbursement
        edit_nsm_steps_disbursements_path(@claim, disbursement_id: item.id)
      end
    end

    def path_key
      "nsm.steps.#{@type}.edit"
    end
  end
end
