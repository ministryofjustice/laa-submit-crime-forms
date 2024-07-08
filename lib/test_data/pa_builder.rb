module TestData
  class PaBuilder
    def build_many(bulk: 100, year: 2023, sleep: true)
      raise 'Do not run on production' if HostEnv.production?

      bulk.times do
        build(year:)
        log '.'
        # avoid issues with large number of applications with the same last_updated_at time
        sleep 0.1 if sleep
      end
      log "\nComplete\n"
    end

    def build(**options)
      ActiveRecord::Base.transaction do
        args, kwfct = *options(**options).values.sample
        kwargs = kwfct.call
        paa = FactoryBot.create(*args, :randomised, further_informations: [], incorrect_informations: [], **kwargs)
        paa.update!(status: :submitted, updated_at: paa.updated_at + 1.minute)

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

    def date_for(year)
      (Date.new(year, 1, 1) + rand(350)).next_weekday
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
