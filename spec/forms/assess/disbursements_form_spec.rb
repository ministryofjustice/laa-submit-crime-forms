require 'rails_helper'

RSpec.describe Assess::DisbursementsForm do
  let(:claim) { create(:submitted_claim) }
  let(:item) do
    instance_double(
      Assess::V1::Disbursement,
      id: '1c0f36fd-fd39-498a-823b-0a3837454563', # Getting from the factory
      provider_requested_total_cost_without_vat: provider_requested_total_cost_without_vat,
      total_cost_without_vat: current_total_cost_without_vat,
      vat_amount: 20.0,
      provider_requested_vat_amount: provider_requested_vat_amount,
    )
  end
  let(:current_total_cost_without_vat) { 100.0 }
  let(:total_cost_without_vat) { 'yes' }
  let(:provider_requested_vat_amount) { 20.0 }
  let(:provider_requested_total_cost_without_vat) { 100.0 }
  let(:form) { described_class.new(claim:, total_cost_without_vat:, item:, explanation:, current_user:) }
  let(:explanation) { 'change to disbursements' }
  let(:current_user) { instance_double(User) }

  describe '#total_cost_without_vat=' do
    context 'when value is a string' do
      it 'sets the total_cost_without_vat attribute' do
        form.total_cost_without_vat = 'yes'
        expect(form.total_cost_without_vat).to eq('yes')
      end
    end

    context 'when value is nil' do
      let(:total_cost_without_vat) { nil }

      it 'sets the total_cost_without_vat attribute to nil' do
        form.total_cost_without_vat = nil
        expect(form.total_cost_without_vat).to be_nil
      end
    end

    context 'when value is a positive number' do
      it 'sets the total_cost_without_vat attribute to "no"' do
        form.total_cost_without_vat = 1
        expect(form.total_cost_without_vat).to eq('no')
      end
    end

    context 'when value is zero' do
      it 'sets the total_cost_without_vat attribute to "yes"' do
        form.total_cost_without_vat = 0
        expect(form.total_cost_without_vat).to eq('yes')
      end
    end
  end

  describe '#save' do
    context 'when the form is valid' do
      let(:current_user) { create(:caseworker) }

      it 'processes the fields and saves the claim' do
        expect(claim).to receive(:save)
        expect(form.save).to be(true)
      end
    end

    context 'when the form is not valid' do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it 'does not process the fields or save the claim' do
        expect(form).not_to receive(:process_field)
        expect(claim).not_to receive(:save)

        expect(form.save).to be(false)
      end
    end

    context 'when an error occurs' do
      let(:current_user) { create(:caseworker) }

      before do
        allow(claim).to receive(:save).and_raise('testing error')
      end

      it 'returns false' do
        expect { form.save }.to raise_error('testing error')
      end
    end
  end

  describe '#new_total_cost_without_vat' do
    context 'when total_cost_without_vat is "yes"' do
      let(:total_cost_without_vat) { 'yes' }

      it 'returns 0' do
        expect(form.send(:new_total_cost_without_vat)).to eq(0)
      end
    end

    context 'when total_cost_without_vat is not "yes"' do
      let(:total_cost_without_vat) { 'no' }

      it 'returns the provider_requested_total_cost_without_vat of the item' do
        expect(form.send(:new_total_cost_without_vat)).to eq(item.provider_requested_total_cost_without_vat)
      end
    end
  end

  describe '#new_vat_amount' do
    context 'when total_cost_without_vat is "yes"' do
      let(:total_cost_without_vat) { 'yes' }

      it 'returns 0' do
        expect(form.send(:new_vat_amount)).to eq(0)
      end
    end

    context 'when total_cost_without_vat is not "yes"' do
      let(:total_cost_without_vat) { 'no' }

      it 'returns the vat_amount of the item' do
        expect(form.send(:new_vat_amount)).to eq(item.vat_amount)
      end
    end
  end
end
