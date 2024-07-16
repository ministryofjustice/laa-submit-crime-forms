module Fixes
  class MultiplePrimaryQuoteFixer
    # We discovered that by multi-clicking the primary quote submit screen, users
    # could cause multiple primary quotes to be registered on our system
    def identify
      PriorAuthorityApplication.where(id: affected_application_ids).pluck(:id, :status, :laa_reference)
    end

    def fix
      affected_application_ids.each do |id|
        application = PriorAuthorityApplication.find(id)
        application.quotes.where(primary: true).where.not(id: true_primary_quote_id(application)).find_each do |quote|
          delete_upload(quote)
          quote.destroy
        end

        update_app_store(application) unless application.draft?
      end
    end

    private

    def affected_application_ids
      Quote.group(:prior_authority_application_id)
           .having('COUNT(id) > 1')
           .where(primary: true)
           .pluck('prior_authority_application_id')
    end

    def true_primary_quote_id(application)
      application.quotes.where(primary: true).detect { _1.total_cost.positive? }.id
    end

    def delete_upload(quote)
      file_uploader.destroy(quote.document.file_path) if quote.document.file_path
    end

    def update_app_store(application)
      old_status = application.status

      # The app store will only allow updates from "sent_back" to "provider_updated"
      # We assume that any affected submissions will be manually put into "sent_back"
      #  before this job runs, and then put into their intended state after it runs.
      application.provider_updated!
      SubmitToAppStore.new.submit(application, include_events: false)
      application.update(status: old_status)
    end

    def file_uploader
      @file_uploader ||= FileUpload::FileUploader.new
    end
  end
end
