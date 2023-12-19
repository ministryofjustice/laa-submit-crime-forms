module Assess
  class WorkItemForm < BaseAdjustmentForm
    LINKED_CLASS = V1::WorkItem
    UPLIFT_PROVIDED = 'no'.freeze
    UPLIFT_RESET = 'yes'.freeze

    attribute :id, :string
    attribute :uplift, :string
    attribute :time_spent, :time_period

    validates :uplift, inclusion: { in: [UPLIFT_PROVIDED, UPLIFT_RESET] }, if: -> { item.uplift? }
    validates :time_spent, allow_nil: true, time_period: true

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
        process_field(value: time_spent.to_i, field: 'time_spent') if time_spent.present?
        process_field(value: new_uplift, field: 'uplift')

        claim.save
      end

      true
    end

    private

    def selected_record
      @selected_record ||= claim.data['work_items'].detect do |row|
        row.fetch('id') == item.id
      end
    end

    def new_uplift
      uplift == 'yes' ? 0 : item.provider_requested_uplift
    end

    def data_has_changed?
      time_spent != item.time_spent ||
        (item.uplift? && item.uplift.zero? != (uplift == UPLIFT_RESET))
    end
  end
end
