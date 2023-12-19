require 'rails_helper'

RSpec.describe Assess::V1::ClaimJustification do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim justification')
    end
  end

  describe '#rows' do
    it 'has correct structure' do
      subject = described_class.new(
        'reasons_for_claim' => [
          {
            'value' => 'enhanced_rates_claimed',
            'en' => 'Enhanced rates claimed',
          },
          {
            'value' => 'councel_or_agent_assigned',
            'en' => 'Counsel or agent assigned',
          },
        ]
      )

      expect(subject.rows).to have_key(:title)
      expect(subject.rows).to have_key(:data)
    end
  end

  describe '#data' do
    subject = described_class.new(
      'reasons_for_claim' => [
        {
          'value' => 'enhanced_rates_claimed',
          'en' => 'Enhanced rates claimed',
        },
        {
          'value' => 'councel_or_agent_assigned',
          'en' => 'Counsel or agent assigned',
        },
      ]
    )

    it 'shows correct table data' do
      expect(subject.data).to eq(
        [
          {
            title: "Why are you claiming a non-standard magistrates' payment?",
            value: 'Enhanced rates claimed<br>Counsel or agent assigned'
          }
        ]
      )
    end
  end
end
