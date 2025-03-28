require 'rails_helper'

RSpec.describe PriorAuthority::Tasks::ClientDetail, type: :presenter do
  subject(:presenter) { described_class.new(application:) }

  let(:application) { create(:prior_authority_application) }

  describe '#path' do
    subject(:path) { presenter.path }

    it { is_expected.to eq("/prior-authority/applications/#{application.id}/steps/client_detail") }
  end

  describe '#not_applicable?' do
    it { is_expected.not_to be_not_applicable }
  end

  describe '#can_start?' do
    context 'when Ufn task has been completed' do
      before do
        application.update!(
          ufn: '111111/111',
          viewed_steps: ['ufn'],
        )
      end

      it { is_expected.to be_can_start }
    end

    context 'when Ufn task has not been completed' do
      before do
        application.update!(
          ufn: nil,
          viewed_steps: []
        )
      end

      it { is_expected.not_to be_can_start }
    end
  end

  describe '#completed?' do
    context 'when the defendant details are valid' do
      before do
        create(:defendant,
               defendable: application,
               first_name: 'Jane',
               last_name: 'Bloggs',
               date_of_birth: 20.years.ago)
      end

      it { is_expected.to be_completed }
    end

    context 'when the defendant details are invalid' do
      before do
        create(:defendant,
               defendable: application,
               first_name: nil,
               last_name: 'Bloggs',
               date_of_birth: 20.years.ago)
      end

      it { is_expected.not_to be_completed }
    end
  end
end
