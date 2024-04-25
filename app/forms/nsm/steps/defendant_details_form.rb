module Nsm
  module Steps
    class DefendantDetailsForm < ::Steps::BaseFormObject
      attribute :first_name, :string
      attribute :last_name, :string
      attribute :maat, :string

      validates :first_name, presence: true
      validates :last_name, presence: true
      with_options if: :maat_required? do
        validates :maat, presence: true, format: /\A\d+\z/
        validates :maat, format: { with: /\d{7}/, message: :wrong_length }
      end

      def maat_required?
        application.claim_type != ClaimType::BREACH_OF_INJUNCTION.to_s
      end

      def label_key
        ".#{'main_' if main_record?}defendant_field_set"
      end

      def index
        application.defendants.index(record)
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

      def main_record?
        # check if it set on the DB record
        return true if record.main

        # DB query to check if any records in DB - ignoring this one which is unsaved
        application.defendants.count.zero?
      end
    end
  end
end
