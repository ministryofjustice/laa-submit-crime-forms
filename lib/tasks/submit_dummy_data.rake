# rubocop:disable Metrics/BlockLength
namespace :submit_dummy_data do
  desc 'Submit dummy prior authority data to the app store'
  task prior_authority: :environment do
    application = FactoryBot.build(:prior_authority_application, :full, id: SecureRandom.uuid,
                                   created_at: DateTime.current, updated_at: DateTime.current, state: :submitted)
    SubmitToAppStore.new.submit(application)
  end

  desc 'Submit bulk dummy prior authority data to the app store for a given year'
  task :bulk_prior_authority, [:bulk, :year, :providers, :office_codes, :max_versions] => :environment do |_task, args|
    args.with_defaults(bulk: 100, year: 2023, providers: 1, office_codes: 1, max_versions: 1)

    $stdout.print "Will create #{args[:bulk]} PA/CRM4's for the year #{args[:year]} " \
                  "using #{args[:providers]} provider(s), #{args[:office_codes]} office code(s), " \
                  "and up to #{args[:max_versions]} version(s): Are you sure? (y/n): "
    input = $stdin.gets.strip

    if input.downcase.in?(%w[yes y])
      TestData::PaBuilder.new.build_many(
        bulk: args[:bulk].to_i,
        year: args[:year].to_i,
        providers: args[:providers].to_i,
        office_codes: args[:office_codes].to_i,
        max_versions: args[:max_versions].to_i,
        seed: ENV.fetch('SEED', nil),
        version_mix: TestData::DataProfile.parse_version_mix(ENV.fetch('VERSION_MIX', nil)),
        sleep: ENV.fetch('SLEEP', 'true') != 'false'
      )
    end
  end

  desc 'Resubmit a proportion of sent-back prior authority applications'
  task :prior_authority_rfi, [:percentage] => :environment do |_task, args|
    $stdout.print "Will resubmit #{args[:percentage]}% of PA/CRM4's in the sent_back state: Are you sure? (y/n): "
    input = $stdin.gets.strip

    TestData::PaResubmitter.new.resubmit(args[:percentage].to_i) if input.downcase.in?(%w[yes y])
  end

  desc 'Submit bulk dummy NSM data to the app store for a given year'
  task :bulk_nsm, [:bulk, :large, :year, :providers, :office_codes, :max_versions] => :environment do |_task, args|
    args.with_defaults(bulk: 100, large: 4, year: 2023, providers: 1, office_codes: 1, max_versions: 1)

    $stdout.print "Will create #{args[:bulk]} NSM/CRM7's, #{args[:large]} large, for the year #{args[:year]} " \
                  "using #{args[:providers]} provider(s), #{args[:office_codes]} office code(s), " \
                  "and up to #{args[:max_versions]} version(s): Are you sure? (y/n): "
    input = $stdin.gets.strip

    if input.downcase.in?(%w[yes y])
      TestData::NsmBuilder.new.build_many(
        bulk: args[:bulk].to_i,
        large: args[:large].to_i,
        year: args[:year].to_i,
        providers: args[:providers].to_i,
        office_codes: args[:office_codes].to_i,
        max_versions: args[:max_versions].to_i,
        seed: ENV.fetch('SEED', nil),
        version_mix: TestData::DataProfile.parse_version_mix(ENV.fetch('VERSION_MIX', nil)),
        sleep: ENV.fetch('SLEEP', 'true') != 'false',
        claim_type_mix: TestData::NsmBuilder.parse_claim_type_mix(ENV.fetch('CLAIM_TYPE_MIX', nil))
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength
