module Nsm
  module Steps
    class DefendantDeleteForm < ::Steps::BaseFormObject
      attribute :id

      def caption_key
        if record.main
          '.main_defendant'
        else
          '.additional_defendant'
        end
      end

      private

      def persist!
        record.destroy
        application.defendants.order(:position).each_with_index do |defendant, index|
          defendant.update!(position: index + 1)
        end
      end
    end
  end
end
