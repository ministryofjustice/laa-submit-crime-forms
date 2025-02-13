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
          t("#{path_key}.item", index: item.position),
          edit_nsm_steps_work_item_path(@claim, work_item_id: item.id)
        )
      end.join(', ')
    end

    private

    def path_key
      "nsm.steps.#{@type}.edit"
    end
  end
end
