# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class HearingDetailsCard < Base
      attr_reader :hearing_details_form

      def initialize(claim)
        @hearing_details_form = Nsm::Steps::HearingDetailsForm.build(claim)
        @group = 'about_case'
        @section = 'hearing_details'
        super()
      end

      def row_data
        [
          hearing_date_row,
          number_of_hearing_row,
          court_row,
          youth_court_row,
          hearing_outcome_row,
          matter_type_row
        ]
      end

      private

      def hearing_date_row
        {
          head_key: 'hearing_date',
          text: check_missing(hearing_details_form.first_hearing_date) do
            hearing_details_form.first_hearing_date.to_fs(:stamp)
          end
        }
      end

      def number_of_hearing_row
        {
          head_key: 'number_of_hearing',
          text: check_missing(hearing_details_form.number_of_hearing)
        }
      end

      def court_row
        {
          head_key: 'court',
          text: check_missing(hearing_details_form.court.present?) do
            hearing_details_form.court
          end
        }
      end

      def youth_court_row
        {
          head_key: 'youth_court',
          text: check_missing(hearing_details_form.youth_court.present?) do
            hearing_details_form.youth_court.to_s.capitalize
          end
        }
      end

      def hearing_outcome_row
        {
          head_key: 'hearing_outcome',
          text: check_missing(hearing_details_form.hearing_outcome.present?) do
            get_value_obj_desc(LaaCrimeFormsCommon::OutcomeCode, hearing_details_form.hearing_outcome)
          end
        }
      end

      def matter_type_row
        {
          head_key: 'matter_type',
          text: check_missing(hearing_details_form.matter_type.present?) do
            get_value_obj_desc(LaaCrimeFormsCommon::MatterType, hearing_details_form.matter_type)
          end
        }
      end
    end
  end
end
