require 'rails_helper'

RSpec.describe Nsm::IncompleteItems do
  subject { described_class.new(claim, type, controller) }

  let(:claim) { build(:claim, work_items:, disbursements:) }
  let(:work_items) do
    [
      build(:work_item, :valid),
      build(:work_item, :valid),
      build(:work_item, :valid, id: incomplete_work_item_id, time_spent: nil)
    ]
  end
  let(:disbursements) do
    [
      build(:disbursement, :valid),
      build(:disbursement, :valid),
      build(:disbursement, :valid, id: incomplete_disbursement_id, disbursement_date: nil)
    ]
  end
  let(:incomplete_work_item_id) { SecureRandom.uuid }
  let(:incomplete_disbursement_id) { SecureRandom.uuid }
  let(:type) { nil }
  let(:controller) { ApplicationController.new }

  before do
    claim
  end

  context 'when the item type is work items' do
    let(:type) { :work_items }

    it 'does not raise error on initialization' do
      expect { subject }.not_to raise_error
    end

    it 'correctly shows incomplete items' do
      expect(subject.incomplete_items.first.id).to eq(incomplete_work_item_id)
      expect(subject.incomplete_items.count).to eq(1)
    end
  end

  context 'when the item type is disbursements' do
    let(:type) { :disbursements }

    it 'does not raise error on initialization' do
      expect { subject }.not_to raise_error
    end

    it 'correctly shows incomplete items' do
      expect(subject.incomplete_items.first.id).to eq(incomplete_disbursement_id)
      expect(subject.incomplete_items.count).to eq(1)
    end
  end

  context 'when the item type is unprocessable' do
    let(:type) { 'garbage' }

    it 'raises error on initialization' do
      expect { subject }.to raise_error("Cannot create items from type: 'garbage'")
    end
  end
end
