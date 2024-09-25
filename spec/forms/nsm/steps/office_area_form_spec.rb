require 'rails_helper'

RSpec.describe Nsm::Steps::OfficeAreaForm do
  subject { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      office_in_undesignated_area:,
    }
  end

  let(:application) do
    create(:claim,
           court_in_undesignated_area: false,
           transferred_to_undesignated_area: true,
           office_in_undesignated_area: original_office_in_undesignated_area)
  end

  let(:original_office_in_undesignated_area) { false }

  context 'when chosen value does not change' do
    let(:office_in_undesignated_area) { false }

    before { subject.save! }

    it 'does not wipe values on save' do
      expect(application.reload.attributes).to include(
        'court_in_undesignated_area' => false,
        'transferred_to_undesignated_area' => true
      )
    end
  end

  context 'when chosen value changes' do
    let(:office_in_undesignated_area) { true }

    before { subject.save! }

    it 'wipes values on save' do
      expect(application.reload.attributes).to include(
        'court_in_undesignated_area' => nil,
        'transferred_to_undesignated_area' => nil
      )
    end
  end
end
