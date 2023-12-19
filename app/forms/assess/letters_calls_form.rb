module Assess
  class LettersCallsForm < BaseAdjustmentForm
    # subclasses required here to give scoping for translations
    class Letters < LettersCallsForm; end
    class Calls < LettersCallsForm; end

    LINKED_CLASS = V1::LetterAndCall
    UPLIFT_PROVIDED = 'no'.freeze
    UPLIFT_RESET = 'yes'.freeze

    attribute :type, :string
    attribute :uplift, :string
    # not set to integer so we can catch errors if non-number values are entered
    attribute :count

    validates :type, inclusion: { in: %w[letters calls] }
    validates :uplift, inclusion: { in: [UPLIFT_PROVIDED, UPLIFT_RESET] }, if: -> { item.uplift? }
    validates :count, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

    # overwrite uplift setter to allow value to be passed as either string (form)
    # or integer (initial setup) value
    def uplift=(val)
      case val
      when String then super
      when nil then nil
      else
        super(val.positive? ? 'no' : 'yes')
      end
    end

    def save
      return false unless valid?

      SubmittedClaim.transaction do
        process_field(value: count.to_i, field: 'count')
        process_field(value: new_uplift, field: 'uplift')

        claim.save
      end

      true
    rescue StandardError
      false
    end

    private

    def selected_record
      @selected_record ||= claim.data['letters_and_calls'].detect do |row|
        row.dig('type', 'value') == type
      end
    end

    def new_uplift
      uplift == 'yes' ? 0 : item.provider_requested_uplift
    end

    def data_has_changed?
      count.to_s.strip != item.count.to_s ||
        (item.uplift? && item.uplift.zero? != (uplift == UPLIFT_RESET))
    end
  end
end
