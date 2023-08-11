# frozen_string_literal: true

module CheckAnswers
  class CaseDetailsCard < Base
    attr_reader :claim

    def initialize(claim)
      @claim = claim
      @group = 'about_case'
      @section = 'case_details'
    end

    # TO DO: update remittal to include date of remittal when CRM457-172 is done
    # rubocop:disable Metrics/AbcSize
    def row_data
      [
        {
          head_key: 'main_offence',
          text: check_missing(claim.main_offence)
        },
        {
          head_key: 'main_offence_date',
          text: check_missing(claim.main_offence_date) do
                  claim.main_offence_date.strftime('%d %B %Y')
                end
        },
        {
          head_key: 'assigned_counsel',
          text: check_missing(claim.assigned_counsel.present?) do
                  claim.assigned_counsel.capitalize
                end
        },
        {
          head_key: 'unassigned_counsel',
          text: check_missing(claim.unassigned_counsel.present?) do
                  claim.unassigned_counsel.capitalize
                end
        },
        {
          head_key: 'agent_instructed',
          text: check_missing(claim.agent_instructed.present?) do
                  claim.agent_instructed.capitalize
                end
        },
        {
          head_key: 'remitted_to_magistrate',
          text: check_missing(claim.remitted_to_magistrate.present?) do
                  claim.remitted_to_magistrate.capitalize
                end
        },
        ({
          head_key: 'remitted_to_magistrate_date',
          text: check_missing(claim.remitted_to_magistrate_date.present?) do
                  claim.remitted_to_magistrate_date.strftime('%d %B %Y')
                end
        } unless claim.remitted_to_magistrate == 'no')
      ].compact
    end
    # rubocop:enable Metrics/AbcSize
  end
end
