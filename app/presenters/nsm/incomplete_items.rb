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

    EXPECTED_ITEM_TYPES = [:work_items, :disbursements].freeze

    def initialize(claim, type, controller)
      @claim = claim
      @type = type
      @controller = controller
      @items ||= case @type
                 when :work_items then @claim.work_items
                 when :disbursements then @claim.disbursements
                 else
                   raise "Cannot create items from type: '#{type}'"
                 end
    end

    def incomplete_items
      @items.reject(&:complete?).sort_by(&:position)
    end

    def summary
      "#{t("#{path_key}.incomplete_summary", count: incomplete_items.count)} #{links}"
    end

    def error_summary
      ApplicationController.helpers.sanitize("#{t("#{path_key}.error_summary", count: incomplete_items.count)} #{links}",
                                             tags: %w[a])
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
      # programatically generate path method with polymorphic path
      # e.g edit_nsm_steps_work_item, id: @claim.id, work_item_id: item.id
      edit_polymorphic_path([:nsm, :steps, path_symbols[:route]], { path_symbols[:id] => item.id, :id => @claim.id })
    end

    def path_symbols
      #  disbursements has a custom multi-step flow so need to
      # explicitly state the path
      {
        route: @type == :disbursements ? :disbursement_type : @type.to_s.singularize.to_sym,
        id: :"#{@type.to_s.singularize}_id"
      }
    end

    def path_key
      "nsm.steps.#{@type}.edit"
    end
  end
end
