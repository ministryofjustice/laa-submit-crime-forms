require 'steps/base_form_object'

module Steps
  class DefendantsDetailsForm < Steps::BaseFormObject
    # transient attribute
    attr_accessor :defendants_attributes

    validates :defendants, nested: { name: :error_message_name }, unless: :any_marked_for_destruction?

    def defendants
      @defendants ||= defendants_collection.map do |defendant|
        DefendantDetailsForm.new(defendant.merge(application:))
      end.tap do |defendants|
        defendants << main_defendant if defendants.none?
      end
    end

    def any_marked_for_destruction?
      defendants.any?(&:_destroy)
    end

    def show_destroy?
      defendants.size > 1
    end

    def next_position
      defendants.last.position + 1
    end

    private

    def defendants_collection
      if defendants_attributes
        # This is a params hash in the format:
        # { "0"=>{"date_from(3i)"=>"21", ...}, "1"=>{"date_from(3i)"=>"21", ...} }
        defendants_attributes.values
      else
        application.defendants.map do |d|
          d.slice(:id, :full_name, :maat, :position, :main)
        end
      end
    end

    def persist!
      application.update(
        attributes.merge(
          defendants_attributes:
        )
      )
    end

    def main_defendant
      DefendantDetailsForm.new(
        position: 1,
        main: true,
        application:
      )
    end

    def error_message_name(index)
      return I18n.t('steps.defendant_details.edit.main_defendant') if index.zero?
      I18n.t('steps.defendant_details.edit.defendant', index:)
    end
  end
end
