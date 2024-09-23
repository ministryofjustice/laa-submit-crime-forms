require 'rails_helper'

RSpec.describe Nsm::Steps::CourtAreaForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      court_in_undesignated_area:,
    }
  end

  let(:application) do
    create(:claim,
           transferred_to_undesignated_area: true,
           court_in_undesignated_area: original_court_in_undesignated_area)
  end

  let(:original_court_in_undesignated_area) { false }

  context 'when chosen value does not change' do
    let(:court_in_undesignated_area) { false }

    before { subject.save! }

    it 'does not wipe values on save' do
      expect(application.reload.attributes).to include(
        'transferred_to_undesignated_area' => true
      )
    end
  end

  context 'when chosen value changes' do
    let(:court_in_undesignated_area) { true }

    before { subject.save! }

    it 'wipes values on save' do
      expect(application.reload.attributes).to include(
        'transferred_to_undesignated_area' => nil
      )
    end
  end
end
