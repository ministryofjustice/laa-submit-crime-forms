module Nsm
  class IncompleteItems
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TranslationHelper

    # govuk_link_to required modules
    include GovukLinkHelper
    include GovukVisuallyHiddenHelper
    include ActionView::Helpers::UrlHelper

    def initialize(items, claim, type)
      @items = items
      @claim = claim
      @type = type
    end

    def incomplete_items
      @items.reject(&:complete?)
    end

    def summary
      # "#{t('.incomplete_summary', count: incomplete_items.count)} #{links}"
      t("#{path_key}.incomplete_summary", count: incomplete_items.count).to_s
    end

    # def links
    #   incomplete_items.map do |item|
    #     govuk_link_to(
    #     t('.item', index: item.position),
    #     edit_nsm_steps_work_item_path(claim, work_item_id: item.id)
    #   )
    # end

    private

    def path_key
      "nsm.steps.#{@type}.edit"
    end
  end
end
