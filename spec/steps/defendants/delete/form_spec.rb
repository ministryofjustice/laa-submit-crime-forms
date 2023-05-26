require 'rails_helper'

RSpec.describe Steps::DefendantDeleteForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      id:,
    }
  end

  let(:application) { instance_double(Claim, ) }
  let(:record) { instance_double(Defendant, id:, main:) }
  let(:id) { SecureRandom.uuid }
  let(:main) { false }

  describe '#caption_key' do
    context 'when main is true' do
      let(:main) { true }

      it { expect(subject.caption_key).to eq('.main_defendant') }
    end

    context 'when main is false' do
      it { expect(subject.caption_key).to eq('.additional_defendant') }
    end
  end

  describe '#save!' do
    it 'deletes the selected record' do
      expect(record).to receive(:destroy)
      subject.save!
    end
  end
end
