module PriorAuthority
  class ApplicationValidator
    def self.call(application)
      new(application).call
    end

    attr_reader :application

    def initialize(application)
      @application = application
    end

    def call
      incomplete_tasks = tasks.reject { _1.new(application).completed? }
      incomplete_tasks = incomplete_tasks.map do |task|
        task.new(application).section_link
      end

      return if incomplete_tasks.blank?

      prefix = I18n.t('prior_authority.steps.check_answers.edit.incomplete_flash', count: incomplete_tasks.count)
      "#{prefix}: #{incomplete_tasks.join(', ')}"
    end

    private

    def tasks
      sections = %w[
        AlternativeQuotesCard
        CaseContactCard
        ClientDetailCard
        PrimaryQuoteCard
        ReasonWhyCard
        UfnCard
      ]
      sections << 'CaseDetailCard' unless application.prison_law?
      sections << 'NextHearingCard' if application.prison_law?
      sections << 'HearingDetailCard' unless application.prison_law?
      sections << 'FurtherInformationCard' if application.further_information_needed?
      sections.map { "PriorAuthority::CheckAnswers::#{_1.camelize}".constantize }
    end
  end
end
