module IncompleteItemsConcern
  extend ActiveSupport::Concern

  private

  def incomplete_items_summary
    @incomplete_items_summary ||= Nsm::IncompleteItems.new(current_application, item_type,
                                                           self)
  end

  def build_items_incomplete_flash
    flash = if import_notification_needed?
              if incomplete_items_summary.incomplete_items.blank?
                { default: t('.items_imported', count: imported_items_count) }
              else
                { default: { title: t('.items_imported', count: imported_items_count),
        content: @incomplete_items_summary.summary } }
              end
            else
              incomplete_items_summary.incomplete_items.blank? ? nil : { default: incomplete_items_summary.summary }
            end
    current_application.update("imported_#{item_type}_viewed": true)
    flash
  end

  def import_notification_needed?
    current_application.import_date.present? && !page_viewed?
  end

  def page_viewed?
    current_application.send(:"imported_#{item_type}_viewed")
  end

  def imported_items_count
    current_application.send(item_type).select { _1.created_at < current_application.import_date }.count
  end
end
