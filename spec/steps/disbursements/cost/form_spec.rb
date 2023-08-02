require 'rails_helper'

RSpec.describe Steps::DisbursementCostForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      miles:,
      total_cost_without_vat:,
      details:,
      prior_authority:,
      apply_vat:,
    }
  end

  let(:application) do
    instance_double(Claim, work_items: disbursements, update!: true, date: Date.yesterday)
  end
  let(:disbursements) { [double(:disbursement), record] }
  let(:record) { double(:record, id: SecureRandom.uuid, disbursement_type: disbursement_type, vat_amount: vat_amount) }
  let(:disbursement_type) { DisbursementTypes.values.reject(&:other?).sample.to_s }
  let(:miles) { 10 }
  let(:total_cost_without_vat) { nil }
  let(:details) { 'Some text' }
  let(:prior_authority) { nil }
  let(:apply_vat) { 'false' }
  let(:vat_amount) { nil }

  describe '#validations' do
    context 'when disbursement_type is not other' do
      %w[miles details].each do |field|
        describe "#when #{field} is blank" do
          let(field) { nil }

          it 'has an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(field, :blank)).to be(true)
          end
        end
      end

      context 'when total without vat is >= £100' do
        let(:miles) { 1000 }

        context 'when prior_authority is not set' do
          it 'has an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:prior_authority, :blank)).to be(true)
          end
        end

        context 'when prior_authority is set' do
          let(:prior_authority) { YesNoAnswer.values.sample.to_s }

          it { expect(subject).to be_valid }
        end
      end
    end

    context 'when disbursement_type is other' do
      let(:disbursement_type) { DisbursementTypes::OTHER.to_s }
      let(:miles) { nil }
      let(:total_cost_without_vat) { 10.0 }

      %w[total_cost_without_vat details].each do |field|
        describe "#when #{field} is blank" do
          let(field) { nil }

          it 'has an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(field, :blank)).to be(true)
          end
        end
      end

      context 'when total without vat is >= £100' do
        let(:total_cost_without_vat) { 100.00 }

        context 'when prior_authority is not set' do
          it 'has an error' do
            expect(subject).not_to be_valid
            expect(subject.errors.of_kind?(:prior_authority, :blank)).to be(true)
          end
        end

        context 'when prior_authority is set' do
          let(:prior_authority) { YesNoAnswer.values.sample.to_s }

          it { expect(subject).to be_valid }
        end
      end
    end
  end

  describe '#apply_vat' do
    context 'when it is passed in' do
      context 'and is the true string' do
        let(:apply_vat) { 'true' }

        it { expect(subject.apply_vat).to be(true) }
      end

      context 'and is the false string' do
        let(:apply_vat) { 'false' }

        it { expect(subject.apply_vat).to be(false) }
      end
    end

    context 'when it is not passed in' do
      let(:apply_vat) { nil }

      context 'and a vat_amount exists on the record' do
        let(:vat_amount) { 10 }

        it { expect(subject.apply_vat).to be(true) }
      end

      context 'and a vat_amount does not exist on the record' do
        let(:vat_amount) { nil }

        it { expect(subject.apply_vat).to be(false) }
      end
    end
  end

  describe '#total_cost' do
    context 'when type is other' do
      let(:disbursement_type) { DisbursementTypes::OTHER.to_s }
      let(:total_cost_without_vat) { 150 }

      it 'is equal to total_cost_witout_vat' do
        expect(subject.total_cost).to eq(150.0)
      end
    end

    context 'when type is not other' do
      let(:disbursement_type) { DisbursementTypes::BIKE.to_s }

      context 'when miles are nil' do
        let(:miles) { nil }

        it { expect(subject.total_cost).to be_nil }
      end

      context 'when miles are not nil' do
        let(:miles) { 100 }

        it 'equal to miles times rate/mile' do
          expect(subject.total_cost).to eq(25.0)
        end
      end
    end
  end

  describe '#vat' do
    context 'when there is not a pre-vat cost' do
      let(:disbursement_type) { DisbursementTypes::OTHER.to_s }
      let(:total_cost_without_vat) { nil }

      it 'returns a nil total cost' do
        expect(subject.send(:vat)).to be_nil
      end
    end
  end

  describe 'save!' do
    let(:application) { Claim.create!(office_code: 'AAA') }
    let(:record) { Disbursement.create!(disbursement_type: disbursement_type, claim: application) }
    let(:disbursement_type) { DisbursementTypes::Car.to_s }

    context 'when disbursement_type is car' do
      let(:disbursement_type) { DisbursementTypes::CAR.to_s }

      it 'calculates and stores the total_cost_without_vat' do
        subject.save!
        expect(record.reload).to have_attributes(
          miles: 10,
          total_cost_without_vat: 4.5,
          vat_amount: 0.0
        )
      end

      context 'when apply_vat is true' do
        let(:apply_vat) { 'true' }

        it 'calculates and stores the total_cost_without_vat and vat_amount' do
          subject.save!
          expect(record.reload).to have_attributes(
            miles: 10,
            total_cost_without_vat: 4.5,
            vat_amount: 0.9
          )
        end

        context 'and vat_amount has a part penny' do
          let(:miles) { 11.5 }

          it 'calculates and stores the total_cost_without_vat and vat_amount rounded to the nearest penny' do
            subject.save!
            expect(record.reload).to have_attributes(
              miles: 11.5,
              total_cost_without_vat: 5.18,
              vat_amount: 1.04
            )
          end
        end
      end
    end

    context 'when disbursement_type is other' do
      let(:disbursement_type) { DisbursementTypes::OTHER.to_s }
      let(:total_cost_without_vat) { 50 }

      it 'stores the total_cost_without_vat' do
        subject.save!
        expect(record.reload).to have_attributes(
          miles: nil,
          total_cost_without_vat: 50.0,
          vat_amount: 0.0
        )
      end

      context 'when apply_vat is true' do
        let(:apply_vat) { 'true' }

        it 'stores the total_cost_without_vat and vat_amount' do
          subject.save!
          expect(record.reload).to have_attributes(
            miles: nil,
            total_cost_without_vat: 50.0,
            vat_amount: 10.0
          )
        end
      end
    end
  end
end
