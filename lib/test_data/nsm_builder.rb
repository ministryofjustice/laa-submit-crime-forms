module TestData
  class NsmBuilder
    def build_many(count)
      count.times { build }
    end

    def build
      ActiveRecord::Base.transaction do
        args, kwargs = *options.values.sample
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
    def options
      {
        magistrates: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc { { disbursements_count: rand(25), work_items_count: rand(1..50) } }
        ],
        breach: [
          [:claim, :complete, :case_type_breach, :build_associates],
          proc { { disbursements_count: rand(25), work_items_count: rand(1..50) } }
        ],
        no_disburesments: [
          [:claim, :complete, :case_type_magistrates, :build_associates],
          proc { { disbursements_count: 0, work_items_count: rand(1..50) } }
        ],
        enhanced_rates: [
          [:claim, :complete, :case_type_magistrates, :with_enhanced_rates, :build_associates],
          proc { { disbursements_count: rand(25), work_items_count: rand(1..50) } }
        ],
      }
    end
    # rubocop:enable Metrics/MethodLength
  end
end
