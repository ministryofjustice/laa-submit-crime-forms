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

    EXPECTED_ITEM_TYPES = [:work_items, :disbursements, :defendants].freeze

    def initialize(claim, type, controller)
      @claim = claim
      @type = type
      @controller = controller
      raise "Cannot create items from '#{type}' for a Claim" unless claim.respond_to?(type)

      @items = claim.send(type)
    end

    def incomplete_items
      @items.reject(&:complete?).sort_by(&:position)
    end

    def summary
      "#{t("#{path_key}.incomplete_summary", count: incomplete_items.count)}: #{links}"
    end

    def links
      incomplete_items.each_with_index.map do |item, index|
        govuk_link_to(
          t("#{path_key}.item", index: index + 1),
          path_url(item)
        )
      end.join(', ')
    end

    private

    def path_url(item)
      edit_polymorphic_path([:nsm, :steps, path_route], { "#{@type.to_s.singularize}_id": item.id, id: @claim.id })
    end

    def path_route
      case @type
      when :disbursements then :disbursement_type
      when :defendants then :defendant_details
      else @type.to_s.singularize.to_sym
      end
    end

    def path_key
      "nsm.steps.#{@type}.edit"
    end
  end
end
