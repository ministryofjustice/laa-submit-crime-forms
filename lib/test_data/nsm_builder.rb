module TestData
  # rubocop:disable Metrics/ClassLength
  class NsmBuilder
    CLAIM_TYPE_OPTIONS = {
      nsm: :vanilla_nsm,
      boi: :breach,
      breach: :breach,
      supplemental: :supplemental,
      enhanced_rates: :enhanced_rates
    }.freeze
    DEFAULT_CLAIM_TYPE_OPTIONS = %i[magistrates breach no_disbursements enhanced_rates].freeze
    CLAIM_TYPE_MIX_ERROR = 'CLAIM_TYPE_MIX supports nsm, boi, breach, supplemental, enhanced_rates ' \
                           'with positive integer weights'.freeze

    def self.parse_claim_type_mix(raw_value)
      return if raw_value.blank?

      mix = raw_value.split(',').to_h do |pair|
        claim_type, weight = pair.split(':', 2)
        [claim_type.strip.to_sym, Integer(weight)]
      end

      raise ArgumentError, CLAIM_TYPE_MIX_ERROR if invalid_claim_type_mix?(mix)

      mix
    rescue ArgumentError, TypeError
      raise ArgumentError, CLAIM_TYPE_MIX_ERROR
    end

    def self.invalid_claim_type_mix?(mix)
      mix.any? { |claim_type, weight| CLAIM_TYPE_OPTIONS.exclude?(claim_type) || weight < 1 }
    end

    # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
    def build_many(bulk: 100, large: 4, year: 2023, providers: 1, office_codes: 1, max_versions: 1, seed: nil,
                   claim_type_mix: nil, high_volume_office_ratio: default_high_volume_office_ratio,
                   high_volume_claim_ratio: default_high_volume_claim_ratio, version_mix: nil, sleep: true)
      raise 'Do not run on production' if HostEnv.production?

      profile = DataProfile.new(
        provider_count: providers,
        office_code_count: office_codes,
        max_versions: max_versions,
        seed: seed,
        high_volume_office_ratio: high_volume_office_ratio,
        high_volume_claim_ratio: high_volume_claim_ratio,
        version_mix: version_mix
      )
      summary = summary_for(profile)

      bulk.times do |index|
        build_and_record(index:, profile:, summary:, year:, claim_type_mix:)
        log '.'

        # avoid issues with large number of applications with the same last_updated_at time
        sleep 0.1 if sleep
      end
      log "\nBulk complete\n"

      large_ids = Array.new(large) do |large_index|
        claim_id = build_and_record(
          index: bulk + large_index,
          profile: profile,
          summary: summary,
          year: year,
          claim_type_mix: claim_type_mix,
          min: 400,
          max: 600
        )
        log '.'
        # avoid issues with large number of applications with the same last_updated_at time
        sleep 0.1 if sleep
        claim_id
      end
      log "\nLarge complete\n"

      Rails.logger.info "Created large examples: #{large_ids.to_sentence}"
      log_summary(summary)
      summary
    end
    # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

    def build(submit: true, claim_type_mix: nil, **build_options)
      ActiveRecord::Base.transaction do
        assignment_attributes = build_options.slice(:submitter, :office_code)
        generator_options = build_options.except(:submitter, :office_code)
        args, kwargs = *selected_options(generator_options, claim_type_mix:).sample
        claim = FactoryBot.create(*args, :randomised, kwargs.call.merge(assignment_attributes))
        claim.update!(state: submit ? :submitted : claim.state, updated_at: claim.updated_at + 1.minute)

        invalid_tasks = check_tasks(claim)
        raise "Invalid for #{invalid_tasks.map(&:first).join(', ')}" if invalid_tasks.any?

        SubmitToAppStore.new.submit(claim) if submit
        claim.id
      end
    end

    # we use tasks here as they already know how to build all the required forms for the more complicated scenarios
    def check_tasks(claim)
      skipped_tasks = %w[ClaimConfirmation Base AlwaysDisabled CostSummary CheckAnswers]
      tasks = (Nsm::Tasks.constants.map(&:to_s) - skipped_tasks)
              .map { |name| [name, Nsm::Tasks.const_get(name)] }

      tasks.reject do |_name, klass|
        task = klass.new(application: claim)
        task.completed? || task.not_applicable?
      end
    end

    # rubocop:disable Metrics/MethodLength
    def options(min: 1, max: 50, year: 2023)
      {
        vanilla_nsm: [
          [:claim, :complete, :case_type_magistrates, :claim_details_no, :build_associates],
          proc do
            date = date_for(year)
            { date: date, disbursements_count: rand(max / 2), work_items_count: rand(min..max), updated_at: date }
          end
        ],
        magistrates: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc do
            date = date_for(year)
            { date: date, disbursements_count: rand(max / 2), work_items_count: rand(min..max), updated_at: date }
          end
        ],
        breach: [
          [:claim, :complete, :case_type_breach, :build_associates],
          proc do
            date = date_for(year)
            { date: date, disbursements_count: rand(max / 2), work_items_count: rand(min..max), updated_at: date }
          end
        ],
        supplemental: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc do
            date = date_for(year)
            { date: date, disbursements_count: rand(max / 2), work_items_count: rand(min..max), updated_at: date }
          end
        ],
        no_disbursements: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc do
            date = date_for(year)
            { date: date, disbursements_count: 0, work_items_count: rand(min..max), updated_at: date }
          end
        ],
        enhanced_rates: [
          [:claim, :complete, :case_type_magistrates, :with_enhanced_rates, :build_associates],
          proc do
            date = date_for(year)
            { date: date, disbursements_count: rand(max / 2), work_items_count: rand(min..max), updated_at: date }
          end
        ],
      }
    end
    # rubocop:enable Metrics/MethodLength

    private

    def default_high_volume_office_ratio
      ENV.fetch('HIGH_VOLUME_OFFICE_RATIO', DataProfile::DEFAULT_HIGH_VOLUME_OFFICE_RATIO)
    end

    def default_high_volume_claim_ratio
      ENV.fetch('HIGH_VOLUME_CLAIM_RATIO', DataProfile::DEFAULT_HIGH_VOLUME_CLAIM_RATIO)
    end

    def build_and_record(index:, profile:, summary:, year:, claim_type_mix:, **build_options)
      assignment = profile.assignment_for(index)
      claim_id = build(
        year: year,
        claim_type_mix: claim_type_mix,
        submitter: assignment.provider,
        office_code: assignment.office_code,
        **build_options
      )
      version_count = profile.versions_for(index)
      submit_additional_versions(Claim.find(claim_id), version_count - 1)

      summary[:claims] += 1
      summary[:versions] += version_count
      summary[:claims_per_office_code][assignment.office_code] += 1
      claim_id
    end

    def selected_options(generator_options, claim_type_mix:)
      available_options = options(**generator_options)
      return available_options.slice(*DEFAULT_CLAIM_TYPE_OPTIONS).values if claim_type_mix.blank?

      claim_type_mix.flat_map do |key, weight|
        option_key = CLAIM_TYPE_OPTIONS.fetch(key.to_sym)
        [available_options.fetch(option_key)] * weight.to_i
      end
    end

    def submit_additional_versions(claim, count)
      count.times do
        app_store_claim = app_store_claim_for(claim)
        app_store_claim.provider_updated!
        SubmitToAppStore.new.submit(app_store_claim)
      end
    end

    def app_store_claim_for(claim)
      data = AppStoreClient.new.get(claim.id)
      AppStore::V1::Nsm::Claim.new(data.merge(data.delete('application')))
    end

    def summary_for(profile)
      {
        providers: profile.provider_count,
        office_codes: profile.office_code_count,
        claims: 0,
        versions: 0,
        claims_per_office_code: Hash.new(0)
      }
    end

    def log_summary(summary)
      log "\nSummary: #{summary.except(:claims_per_office_code).to_json}\n"
      log "Claims per office code: #{summary[:claims_per_office_code].sort.to_h.to_json}\n"
    end

    def date_for(year)
      last_day = year == Date.current.year ? Date.current.yday - 7 : 350
      (Date.new(year, 1, 1) + rand(last_day)).next_weekday
    end

    # rubocop:disable Rails/Output
    def log(str)
      if Rails.env.test?
        Rails.logger.info str
        # :nocov:
      else
        print str
        # :nocov:
      end
    end
    # rubocop:enable Rails/Output
  end
  # rubocop:enable Metrics/ClassLength
end
