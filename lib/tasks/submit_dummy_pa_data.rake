
namespace :prior_authority do
  desc "Submit dummy prior authority data to the app store"
  task submit_dummy_data: :environment do
    application = FactoryBot.build(:prior_authority_application, :full, id: SecureRandom.uuid)
    SubmitToAppStore.new.submit(application)
  end
end
