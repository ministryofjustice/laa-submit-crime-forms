module IncompleteItemsConcern
  extend ActiveSupport::Concern

  private

  def incomplete_items_summary
    @incomplete_items_summary ||= Nsm::IncompleteItems.new(items, current_application, item_type,
                                                           self)
  end

  def build_items_incomplete_flash
    incomplete_items_summary.incomplete_items.blank? ? nil : { default: incomplete_items_summary.summary }
  end
end
