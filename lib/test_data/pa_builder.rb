module TestData
  class PaBuilder
    # rubocop:disable Metrics/MethodLength, Metrics/ParameterLists
    def build_many(bulk: 100, year: 2023, providers: 1, office_codes: 1, max_versions: 1, seed: nil,
                   high_volume_office_ratio: default_high_volume_office_ratio,
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
        assignment = profile.assignment_for(index)
        application_id = build(year: year, provider: assignment.provider, office_code: assignment.office_code)
        version_count = profile.versions_for(index)
        submit_additional_versions(PriorAuthorityApplication.find(application_id), version_count - 1)

        summary[:applications] += 1
        summary[:versions] += version_count
        summary[:applications_per_office_code][assignment.office_code] += 1
        log '.'
        # avoid issues with large number of applications with the same last_updated_at time
        sleep 0.1 if sleep
      end
      log "\nComplete\n"
      log_summary(summary)
      summary
    end
    # rubocop:enable Metrics/MethodLength, Metrics/ParameterLists

    def build(**build_options)
      ActiveRecord::Base.transaction do
        assignment_attributes = build_options.slice(:provider, :office_code)
        generator_options = build_options.except(:provider, :office_code)
        args, kwfct = *options(**generator_options).values.sample
        kwargs = kwfct.call
        paa = FactoryBot.create(*args, :randomised, further_informations: [], incorrect_informations: [],
                                                   **kwargs.merge(assignment_attributes))
        paa.update!(state: :submitted, updated_at: paa.updated_at + 1.minute)

        invalid_tasks = check_tasks(paa)

        raise "Invalid for #{invalid_tasks.map(&:first).join(', ')}" if invalid_tasks.any?

        SubmitToAppStore.new.submit(paa)
        paa.id
      end
    end

    # we use tasks here as they already know how to build all the required forms for the more complicated scenarios
    def check_tasks(paa)
      skipped_tasks = %w[Base FurtherInformation]
      tasks = (PriorAuthority::Tasks.constants.map(&:to_s) - skipped_tasks)
              .map { |name| [name, PriorAuthority::Tasks.const_get(name)] }

      tasks.reject { |_name, klass| klass.new(application: paa).completed? }
    end

    # rubocop:disable Metrics/MethodLength
    def options(year: 2023)
      {
        simple_non_prision: [
          [:prior_authority_application, :with_complete_non_prison_law],
          proc do
            date = date_for(year)
            { date: date, updated_at: date, service_type_cost_type: %i[per_hour per_item].sample }
          end
        ],
        simple_prision: [
          [:prior_authority_application, :with_complete_prison_law],
          proc do
            date = date_for(year)
            { date: date, updated_at: date, service_type_cost_type: %i[per_hour per_item].sample }
          end
        ],
        complex_non_prision: [
          [:prior_authority_application, :with_complete_non_prison_law, :with_alternative_quotes, :with_additional_costs],
          proc do
            date = date_for(year)
            {
              date: date, updated_at: date, quote_count: [1, 2].sample,
              service_type_cost_type: %i[per_hour per_item].sample
            }
          end
        ],
        complex_prision: [
          [:prior_authority_application, :with_complete_prison_law, :with_alternative_quotes, :with_additional_costs],
          proc do
            date = date_for(year)
            {
              date: date, updated_at: date, quote_count: [1, 2].sample,
              service_type_cost_type: %i[per_hour per_item].sample
            }
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

    def submit_additional_versions(application, count)
      count.times do
        application.provider_updated!
        SubmitToAppStore.new.submit(application)
      end
    end

    def summary_for(profile)
      {
        providers: profile.provider_count,
        office_codes: profile.office_code_count,
        applications: 0,
        versions: 0,
        applications_per_office_code: Hash.new(0)
      }
    end

    def log_summary(summary)
      log "\nSummary: #{summary.except(:applications_per_office_code).to_json}\n"
      log "Applications per office code: #{summary[:applications_per_office_code].sort.to_h.to_json}\n"
    end

    def date_for(year)
      last_day = year == Date.current.year ? [Date.current.yday - 7, 0].max : 350
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
end
