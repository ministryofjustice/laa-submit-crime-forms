require 'rails_helper'

RSpec.describe Search::Result do
  subject { described_class.new(wrapped_object) }

  describe '#client_name' do
    context 'when wrapping a ListRow' do
      let(:wrapped_object) { ListRow.new('application' => application) }

      context 'when there are defendants' do
        let(:application) do
          {
            'defendants' => [
              { 'first_name' => 'Joe', 'last_name' => 'Bloggs', 'main' => true },
            ]
          }
        end

        it { expect(subject.client_name).to eq 'Joe Bloggs' }
      end

      context 'when there is one defendant' do
        let(:application) do
          {
            'defendant' => { 'first_name' => 'Joe', 'last_name' => 'Bloggs', 'main' => true },
          }
        end

        it { expect(subject.client_name).to eq 'Joe Bloggs' }
      end
    end

    context 'when wrapping a Claim' do
      let(:wrapped_object) { create(:claim, defendants: [build(:defendant, :valid, first_name: 'A', last_name: 'B')]) }

      it { expect(subject.client_name).to eq 'A B' }
    end

    context 'when wrapping a PriorAuthorityApplication' do
      let(:wrapped_object) do
        build(:prior_authority_application, defendant: build(:defendant, :valid, first_name: 'A', last_name: 'B'))
      end

      it { expect(subject.client_name).to eq 'A B' }
    end

    context 'when wrapping something else' do
      let(:wrapped_object) do
        build(:defendant, :valid, first_name: 'A', last_name: 'B')
      end

      it { expect { subject.client_name }.to raise_error "Don't know how to extract client_name from Defendant" }
    end
  end

  describe '#account_number' do
    let(:wrapped_object) { build(:claim, office_code: 'office_code') }

    it { expect(subject.account_number).to eq 'office_code' }
  end

  describe '#status_with_assignment' do
    context 'when autogranted' do
      let(:wrapped_object) { build(:prior_authority_application, state: 'auto_grant') }

      it { expect(subject.status_with_assignment).to eq 'granted' }
    end

    context 'when anything else' do
      let(:wrapped_object) { build(:prior_authority_application, state: 'part_grant') }

      it { expect(subject.status_with_assignment).to eq 'part_grant' }
    end
  end
end
