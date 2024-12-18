require 'rails_helper'

RSpec.describe Nsm::Steps::DefendantDeleteForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      id:,
    }
  end

  let(:application) { instance_double(Claim, defendants: []) }
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

    context 'when there are multiple defendants' do
      let(:application) { create(:claim, defendants:) }
      let(:defendants) { [tom, dick, harry, sally] }
      let(:record) { dick }
      let(:tom) { build(:defendant, :valid, position: 1) }
      let(:dick) { build(:defendant, :additional, position: 2) }
      let(:harry) { build(:defendant, :additional, position: 3) }
      let(:sally) { build(:defendant, :additional, position: 4) }

      it 'renumbers remaining defendants' do
        form.save!
        expect(tom.reload.position).to eq 1
        expect(harry.reload.position).to eq 2
        expect(sally.reload.position).to eq 3
      end
    end
  end
end
