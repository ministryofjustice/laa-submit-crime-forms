module PriorAuthority
  class ApplicationValidator
    attr_reader :application

    def initialize(application)
      @application = application
    end

    def call
      return nil if incomplete_sections.blank?

      prefix = I18n.t('prior_authority.steps.check_answers.edit.incomplete_flash', count: incomplete_sections.count)
      "#{prefix}: #{incomplete_sections.join(', ')}"
    end

    def incomplete_sections
      items = sections.reject { _1.new(application).completed? }
      items.map do |task|
        task.new(application).section_link
      end
    end

    private

    def sections
      items = %w[
        AlternativeQuotesCard
        CaseContactCard
        ClientDetailCard
        PrimaryQuoteCard
        ReasonWhyCard
        UfnCard
      ]
      items << 'CaseDetailCard' unless application.prison_law?
      items << 'NextHearingCard' if application.prison_law?
      items << 'HearingDetailCard' unless application.prison_law?
      items << 'FurtherInformationCard' if application.further_information_needed?
      items.map { "PriorAuthority::CheckAnswers::#{_1.camelize}".constantize }
    end
  end
end
