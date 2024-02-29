module PriorAuthority
  module Steps
    class CaseDetailForm < ::Steps::BaseFormObject
      attribute :rep_order_date, :multiparam_date
      attribute :client_detained, :boolean
      attribute :subject_to_poca, :boolean

      validates :defendant, presence: true, nested: true
      validates :main_offence_autocomplete, presence: true
      validates :rep_order_date, presence: true, multiparam_date: { allow_past: true, allow_future: false }
      validates :client_detained, inclusion: { in: [true, false] }
      validates :prison_autocomplete, presence: true, if: :client_detained
      validates :subject_to_poca, inclusion: { in: [true, false] }

      attr_accessor :main_offence_id, :custom_main_offence_name, :local_main_offence_values,
                    :prison_id, :custom_prison_name, :local_prison_values,
                    :defendant_attributes

      def main_offence_autocomplete
        construct_autocomplete_value(:main_offence, :offences)
      end

      def prison_autocomplete
        construct_autocomplete_value(:prison, :prisons)
      end

      def main_offence_autocomplete=(value)
        assign_autocomplete_value(:main_offence, value)
      end

      def prison_autocomplete=(value)
        assign_autocomplete_value(:prison, value)
      end

      def main_offence_autocomplete_suggestion=(value)
        assign_autocomplete_suggestion_value(:main_offence, :offences, value)
      end

      def prison_autocomplete_suggestion=(value)
        assign_autocomplete_suggestion_value(:prison, :prisons, value)
      end

      # The value returned by this is used to prepopulate the form field
      # and validate the form
      def construct_autocomplete_value(field_type, list_type)
        scope = send(:"local_#{field_type}_values") ? self : application
        if scope.send(:"#{field_type}_id") == 'custom'
          scope.send(:"custom_#{field_type}_name")
        elsif scope.send(:"#{field_type}_id").present?
          I18n.t("prior_authority.#{list_type}.#{scope.send(:"#{field_type}_id")}")
        end
      end

      # This value is set whether on not JS is disabled, but if there is JS we
      # want the _suggestion assignment to take precedence
      def assign_autocomplete_value(field_type, value)
        # ensure that if the suggestion is set first it cannot be overwritten
        return if send(:"local_#{field_type}_values")

        # used to ensure we use the right scope in validations
        send(:"local_#{field_type}_values=", true)

        send(:"#{field_type}_id=", value)
        send(:"custom_#{field_type}_name=", nil)
      end

      # The _suggestion value is only in the payload if JS is enabled.
      # If it's there, we use its value to work out everything else,
      # as it represents what the user has actually put in the textbox
      def assign_autocomplete_suggestion_value(field_type, list_type, value)
        send(:"local_#{field_type}_values=", true)

        if value.in?(I18n.t("prior_authority.#{list_type}").values)
          send(:"#{field_type}_id=", I18n.t("prior_authority.#{list_type}").invert[value])
          send(:"custom_#{field_type}_name=", nil)
        else
          send(:"#{field_type}_id=", value.present? ? 'custom' : nil)
          send(:"custom_#{field_type}_name=", value)
        end
      end

      def defendant
        @defendant ||= PriorAuthority::Steps::CaseDetail::DefendantForm.new(defendant_fields.merge(application:))
      end

      def offence_list
        I18n.t('prior_authority.offences').transform_keys(&:to_s).to_a
      end

      def prison_list
        I18n.t('prior_authority.prisons').transform_keys(&:to_s).to_a
      end

      private

      def defendant_fields
        (defendant_attributes || application.defendant&.attributes || {})
          .slice(*PriorAuthority::Steps::CaseDetail::DefendantForm.attribute_names)
      end

      def persist!
        defendant.save!
        to_update = attributes.dup
        if main_offence_id
          to_update[:main_offence_id] = main_offence_id
          to_update[:custom_main_offence_name] = custom_main_offence_name
        end
        if prison_id
          to_update[:prison_id] = prison_id
          to_update[:custom_prison_name] = custom_prison_name
        end
        application.update!(to_update)
      end
    end
  end
end
