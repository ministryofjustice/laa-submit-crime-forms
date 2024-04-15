
namespace :submit_dummy_data do
  desc "Submit dummy prior authority data to the app store"
  task prior_authority: :environment do
    application = FactoryBot.build(:prior_authority_application, :full, id: SecureRandom.uuid)
    SubmitToAppStore.new.submit(application)
  end

  desc "Submit bulk dummy prior authority data to the app store for a given year"
  task bulk_prior_authority: :environment do
    year = ENV.fetch('YEAR', 2023).to_i

    TestData::PaBuilder.new.build_many(bulk: 100_000, year: year)
  end

  desc "Submit bulk dummy NSM data to the app store for a given year"
  task bulk_nsm: :environment do
    year = ENV.fetch('YEAR', 2023).to_i

    TestData::NsmBuilder.new.build_many(bulk: 24_000, large: 20, year: year)
  end
end
