# Once a submission has been sent to the app store we have 2 copies of the data, 1 in the local DB
# and 1 in the app store. We used to use the former to populate our UIs when viewing details
# of these submissions, but that meant we had to commit to syncing changes to the submission
# back to the local DB. In an effort to move away from that we now load the data from
# the app store. However, the UIs often reuse components with the "Check answers screen"
# that is viewed pre-submission, and therefore uses data contained in ActiveRecord objects.
# This service therefore exists to load data from the app store BUT to return it in
# ActiveRecord-like form, so that those shared components continue to work.
class AppStoreDetailService
  class << self
    def prior_authority(submission_id, provider)
      retrieve(submission_id, provider, AppStore::V1::PriorAuthority::Application)
    end

    def nsm(submission_id, provider)
      retrieve(submission_id, provider, AppStore::V1::Nsm::Claim)
    end

    def retrieve(submission_id, provider, klass)
      data = AppStoreClient.new.get(submission_id)
      combined = data.merge(data.delete('application'))

      submission = klass.new(combined)
      raise Errors::ApplicationNotFound unless submission.office_code.in?(provider.office_codes)

      submission
    end
  end
end
