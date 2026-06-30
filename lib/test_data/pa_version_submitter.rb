module TestData
  class PaVersionSubmitter
    def submit(application, count)
      count.times do
        if application.sent_back?
          submit_provider_update(application)
        else
          submit_sent_back(application)
        end
      end
    end

    private

    def submit_sent_back(application)
      requested_at = DateTime.current
      resubmission_deadline = 14.days.from_now
      information_requested = Faker::Lorem.sentence
      application.update!(
        state: :sent_back,
        resubmission_requested: requested_at,
        resubmission_deadline: resubmission_deadline,
        app_store_updated_at: requested_at
      )
      application.further_informations.create!(
        information_requested: information_requested,
        caseworker_id: SecureRandom.uuid,
        requested_at: requested_at,
        resubmission_deadline: resubmission_deadline
      )

      AppStoreCaseworkerClient.new.put(sent_back_payload(application, information_requested, resubmission_deadline))
    end

    def sent_back_payload(application, information_requested, resubmission_deadline)
      payload = SubmitToAppStore::PayloadBuilder.call(application)
      payload[:application].merge!(
        updates_needed: ['further_information'],
        further_information_explanation: information_requested,
        resubmission_deadline: resubmission_deadline.as_json
      )
      payload[:events] = [send_back_event(information_requested)]
      payload
    end

    def submit_provider_update(application)
      application.pending_further_information.update!(
        information_supplied: Faker::Lorem.paragraph,
        signatory_name: Faker::Name.name
      )
      application.provider_updated!
      SubmitToAppStore.new.submit(application)
    end

    def send_back_event(information_requested)
      {
        id: SecureRandom.uuid,
        event_type: 'send_back',
        details: {
          updates_needed: ['further_information'],
          comments: { further_information: information_requested }
        },
        does_not_constitute_update: false
      }
    end
  end
end
