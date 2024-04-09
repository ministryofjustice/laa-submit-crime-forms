
namespace :submit_dummy_data do
  desc "Submit dummy prior authority data to the app store"
  task prior_authority: :environment do
    application = FactoryBot.build(:prior_authority_application, :full, id: SecureRandom.uuid)
    SubmitToAppStore.new.submit(application)
  end

  desc "Submit dummy NSM data to the app store for a given year"
  task nsm: :environment do
    year = ENV.fetch('YEAR', 2023).to_i

    TestData::NsmBuilder.new.build_many(bulk: 2000, large: 20, year: year)
  end
end
