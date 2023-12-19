module Assess
  module V1
    class YourClaims < Assess::BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :firm_office
      attribute :created_at, :date
      attribute :claim
      attribute :risk

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? main_defendant['full_name'] : ''
      end

      def firm_name
        firm_office['name']
      end

      def date_created_str
        I18n.l(created_at, format: '%-d %b %Y')
      end

      def date_created_sort
        created_at.to_fs(:db)
      end

      def risk_sort
        {
          'high' => 1,
          'medium' => 2,
          'low' => 3,
        }[risk]
      end
    end
  end
end
