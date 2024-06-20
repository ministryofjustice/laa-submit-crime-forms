
namespace :submit_dummy_data do
  desc "Submit dummy prior authority data to the app store"
  task prior_authority: :environment do
    application = FactoryBot.build(:prior_authority_application, :full, id: SecureRandom.uuid)
    SubmitToAppStore.new.submit(application)
  end

  desc "Submit bulk dummy prior authority data to the app store for a given year"
  task :bulk_prior_authority, [:bulk, :year] => :environment do |_task, args|
    args.with_defaults(bulk: 100, year: 2023)

    STDOUT.print "Will create #{args[:bulk]} PA/CRM4's for the year #{args[:year]}: Are you sure? (y/n): "
    input = STDIN.gets.strip

    if input.downcase.in?(['yes','y'])
      TestData::PaBuilder.new.build_many(bulk: args[:bulk].to_i, year: args[:year].to_i)
    end
  end

  desc "Submit bulk dummy NSM data to the app store for a given year"
  task :bulk_nsm, [:bulk, :large, :year] => :environment do |_task, args|
    args.with_defaults(bulk: 100, large: 4, year: 2023)

    STDOUT.print "Will create #{args[:bulk]} NSM/CRM7's, #{args[:large]} large, for the year #{args[:year]}: Are you sure? (y/n): "
    input = STDIN.gets.strip

    if input.downcase.in?(['yes','y'])
      TestData::NsmBuilder.new.build_many(bulk: args[:bulk].to_i, large: args[:large].to_i, year: args[:year].to_i)
      # puts "TestData::NsmBuilder.new.build_many(bulk: #{args[:bulk].to_i}, large: #{args[:large].to_i}, year: #{args[:year].to_i})"
    end
  end
end
