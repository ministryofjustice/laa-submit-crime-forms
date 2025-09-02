module Nsm
  module Steps
    class DefendantDetailsForm < ::Steps::BaseFormObject
      include LaaCrimeFormsCommon::Validators

      attribute :first_name, :string
      attribute :last_name, :string
      attribute :maat, :string

      validates :first_name, presence: true
      validates :last_name, presence: true
      with_options if: :maat_required? do
        validates :maat, presence: true, maat: true
      end

      delegate :id, to: :record

      def maat_required?
        application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
      end

      def label_key
        ".#{'main_' if main_record?}defendant_field_set"
      end

      def index
        application.defendants.index(record)
      end

      def full_name_if_valid
        valid?
        "#{first_name} #{last_name}" unless errors[:first_name].any? || errors[:last_name].any?
      end

      def maat_if_valid
        valid?
        maat unless errors[:maat].any?
      end

      def main_record?
        # check if it set on the DB record
        return true if record.main

        # DB query to check if any records in DB - ignoring this one which is unsaved
        !application.defendants.exists?
      end

      def position
        record.position || position_attributes[:position]
      end

      private

      def persist!
        record.id = nil if record.id == StartPage::NEW_RECORD
        record.update!(attributes.merge(position_attributes))
      end

      def position_attributes
        return {} if record.position

        prev_position = application.defendants.maximum(:position)
        if prev_position
          { position: prev_position + 1, main: false }
        else
          { position: 1, main: true }
        end
      end
    end
  end
end
