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
        process_boolean_value(boolean_field: claim.remitted_to_magistrate,
                              value_field: claim.remitted_to_magistrate_date,
                              boolean_key: 'remitted_to_magistrate',
                              value_key: 'remitted_to_magistrate_date') do
          claim.remitted_to_magistrate_date.strftime('%d %B %Y')
        end
      ].flatten
    end
    # rubocop:enable Metrics/AbcSize
  end
end
