require 'rails_helper'

RSpec.describe Search::Service do
  describe '.call' do
    it 'blows up when there is an unknown service' do
      expect { described_class.call(:eoul, {}, {}) }.to raise_error 'Unknown service eoul'
    end
  end

  describe '#unified_sort_by' do
    subject { described_class.new(:nsm, {}, { sort_by: }).unified_sort_by }

    context 'when sorting by defendant' do
      let(:sort_by) { 'defendant' }

      it { expect(subject).to eq('client_name') }
    end

    context 'when sorting by account' do
      let(:sort_by) { 'account' }

      it { expect(subject).to eq('account_number') }
    end

    context 'when sorting by state' do
      let(:sort_by) { 'state' }

      it { expect(subject).to eq('status_with_assignment') }
    end
  end
end
