# frozen_string_literal: true

module PriorAuthority
  module CheckAnswers
    class ClientDetailCard < Base
      attr_reader :application

      def initialize(application)
        @group = 'about_case'
        @section = 'client_detail'
        @application = application
        super()
      end

      def row_data
        base_rows
      end

      def base_rows
        [
          {
            head_key: 'full_name',
            text: application.defendant.full_name,
          },
          {
            head_key: 'date_of_birth',
            text: application.defendant.date_of_birth.to_fs(:stamp),
          },
        ]
      end
    end
  end
end
