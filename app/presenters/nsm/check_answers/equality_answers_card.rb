# frozen_string_literal: true

module Nsm
  module CheckAnswers
    class EqualityAnswersCard < Base
      attr_reader :claim

      def initialize(claim)
        @claim = claim
        @group = 'equality_answers'
        @section = 'equal_monitoring'
      end

      def row_data
        [
          {
            head_key: 'equality_questions',
            text: check_missing(claim.answer_equality?) do
              if claim.answer_equality == YesNoAnswer::YES.to_s
                I18n.t('helpers.label.nsm_steps_answer_equality_form.answer_equality_options.yes')
              else
                I18n.t('helpers.label.nsm_steps_answer_equality_form.answer_equality_options.no')
              end
            end
          },
          ethnicity_row,
          identification_row,
          disability_row
        ].compact
      end

      private

      def ethnicity_row
        return nil unless claim.answer_equality == YesNoAnswer::YES.to_s

        {
          head_key: 'defendants_ethnicity',
          text: check_missing(claim.ethnic_group.present?) do
            I18n.t("helpers.label.nsm_steps_equality_questions_form.ethnic_group_options.#{claim.ethnic_group}")
          end
        }
      end

      def identification_row
        return nil unless claim.answer_equality == YesNoAnswer::YES.to_s

        {
          head_key: 'defendant_identification',
          text: check_missing(claim.gender.present?) do
            I18n.t("helpers.label.nsm_steps_equality_questions_form.gender_options.#{claim.gender}")
          end
        }
      end

      def disability_row
        return nil unless claim.answer_equality == YesNoAnswer::YES.to_s

        {
          head_key: 'defendant_disabled',
          text: check_missing(claim.disability.present?) do
            I18n.t("helpers.label.nsm_steps_equality_questions_form.disability_options.#{claim.disability}")
          end
        }
      end
    end
  end
end
