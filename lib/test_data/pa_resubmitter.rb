module TestData
  class PaResubmitter
    def resubmit(percentage)
      total = PriorAuthorityApplication.sent_back.count

      PriorAuthorityApplication.sent_back.order('RANDOM()').limit(percentage * total / 100).find_each do |application|
        add_further_information(application) if application.further_information_needed?
        make_changes(application) if application.incorrect_information_explanation.present?
        update(application)
      end
    end

    def add_further_information(application)
      further_information = application.further_informations.order(:created_at).last
      further_information.supporting_documents << FactoryBot.build(:supporting_document,
                                                                   file_name: "#{SecureRandom.uuid}.pdf")
      further_information.update!(information_supplied: Faker::Lorem.paragraph)
    end

    def make_changes(application)
      application.defendant.update!(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name
      )

      application.firm_office.update!(
        name: Faker::Company.name,
        town: Faker::Address.city,
      )

      latest_incorrect_info = application.incorrect_informations.order(requested_at: :desc).first
      latest_incorrect_info.update!(sections_changed: %w[case_contact client_detail])
    end

    def update(application)
      application.provider_updated!
      SubmitToAppStore.new.submit(application)
    end
  end
end
