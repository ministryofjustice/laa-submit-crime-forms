module TestData
  class NsmBuilder
    def build_many(bulk: 100, large: 4, year: 2023)
      bulk.times { build(year:) }

      large_ids = Array.new(large) { build(min: 400, max: 600, year: year) }

      Rails.logger.info "Created large examples: #{large_ids.to_sentence}"
    end

    def build(**options)
      ActiveRecord::Base.transaction do
        args, kwargs = *options(**options).values.sample
        claim = FactoryBot.create(*args, kwargs.call)

        invalid_tasks = check_tasks(claim)

        if invalid_tasks.any?
          Rails.logger.debug { "Invalid for #{invalid_tasks.map(&:last).join(', ')}" }

          # rubocop:disable Lint/Debugger
          debugger if ENV['DEBUG_TEST_DATA']
          # rubocop:enable Lint/Debugger

          # help with debugging for base tasks run (for simple objects):
          #   errors_for(task_klass, claim)
          #   errors_for(task_klass, claim, record)

          raise "Invalid for #{invalid_tasks.map(&:first).join(', ')}"
        end

        SubmitToAppStore.new.submit(claim)

        claim.id
      end
    end

    def errors_for(task_klass, claim, record = nil)
      task = task_klass.new(application: claim)
      form = task.send(:associated_form).build(record || task.send(:record), application: claim)
      form.valid?
      form.errors
    end

    # we use tasks here as they already know how to build all the required forms for the more complicated scenarios
    def check_tasks(claim)
      invalid_tasks = %w[ClaimConfirmation Base AlwaysDisabled CostSummary CheckAnswers]
      tasks = (Nsm::Tasks.constants.map(&:to_s) - invalid_tasks)
              .map { |name| [name, Nsm::Tasks.const_get(name)] }

      tasks.reject { |_name, klass| klass.new(application: claim).completed? }
    end

    # rubocop:disable Metrics/MethodLength
    def options(min: 1, max: 50, year: 2023)
      {
        magistrates: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc { { date: date(year), disbursements_count: rand(max / 2), work_items_count: rand(min..max) } }
        ],
        breach: [
          [:claim, :complete, :case_type_breach, :build_associates],
          proc { { date: date(year), disbursements_count: rand(max / 2), work_items_count: rand(min..max) } }
        ],
        no_disburesments: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc { { date: date(year), disbursements_count: 0, work_items_count: rand(min..max) } }
        ],
        enhanced_rates: [
          [:claim, :complete, :case_type_magistrates, :with_enhanced_rates, :build_associates],
          proc { { date: date(year), disbursements_count: rand(max / 2), work_items_count: rand(min..max) } }
        ],
      }
    end
    # rubocop:enable Metrics/MethodLength

    def date(year)
      (Date.new(year, 1, 1) + rand(350)).next_weekday
    end
  end
end
