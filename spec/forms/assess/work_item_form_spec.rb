require 'rails_helper'

RSpec.describe Assess::WorkItemForm do
  subject { described_class.new(params) }

  let(:claim) { create(:submitted_claim) }
  let(:params) { { claim:, id:, time_spent:, uplift:, item:, explanation:, current_user: } }
  let(:id) { 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137' }
  let(:time_spent) { 95 }
  let(:uplift) { 'yes' }
  let(:item) do
    instance_double(
      Assess::V1::WorkItem,
      id: id,
      time_spent: 161,
      uplift: 95,
      provider_requested_uplift: provider_requested_uplift,
      uplift?: true
    )
  end
  let(:provider_requested_uplift) { 95 }
  let(:explanation) { 'change to work items' }
  let(:current_user) { instance_double(User) }

  describe '#validations' do
    context 'uplift' do
      ['yes', 'no', 0, 95].each do |uplift_value|
        context 'when it is letters' do
          let(:uplift) { uplift_value }

          it { expect(subject).to be_valid }
        end
      end

      context 'when it is something else' do
        let(:uplift) { 'other' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:uplift, :inclusion)).to be(true)
        end
      end
    end

    context 'explanation' do
      context 'when it is blank' do
        let(:explanation) { '' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(true)
        end
      end
    end

    context 'when data has not changed' do
      let(:time_spent) { 161 }
      let(:uplift) { 'no' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors.of_kind?(:base, :no_change)).to be(true)
      end

      context 'and explanation does not have an error' do
        let(:explanation) { '' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:explanation, :blank)).to be(false)
        end
      end
    end
  end

  describe '#uplift' do
    it 'can be set with a string' do
      expect(described_class.new(uplift: 'yes').uplift).to eq('yes')
      expect(described_class.new(uplift: 'no').uplift).to eq('no')
    end

    it 'can be set with an integer' do
      expect(described_class.new(uplift: 0).uplift).to eq('yes')
      expect(described_class.new(uplift: 95).uplift).to eq('no')
    end

    it 'not set when nil' do
      expect(described_class.new(uplift: nil).uplift).to be_nil
    end
  end

  describe '#save' do
    let(:current_user) { create(:caseworker) }

    context 'when record is invalid' do
      let(:uplift) { nil }

      it { expect(subject.save).to be_falsey }
    end

    context 'when only uplift has changed' do
      let(:uplift) { 'yes' }
      let(:time_spent) { nil }

      it 'creates a event for the time_spent change' do
        expect { subject.save }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          submitted_claim: claim,
          claim_version: claim.current_version,
          event_type: 'Event::Edit',
          linked_type: 'work_items',
          linked_id: id,
          details: {
            'field' => 'uplift',
            'from' => 95,
            'to' => 0,
            'change' => -95,
            'comment' => 'change to work items'
          }
        )
      end

      it 'updates the JSON data' do
        subject.save
        work_item = claim.reload
                         .data['work_items']
                         .detect { |row| row.dig('work_type', 'value') == 'waiting' }
        expect(work_item).to eq(
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'time_spent' => 161,
          'pricing' => 24.0,
          'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
          'uplift' => 0,
          'fee_earner' => 'aaa',
          'completed_on' => '2022-12-12'
        )
      end
    end

    context 'when only time_spent has changed' do
      let(:uplift) { 'no' }

      it 'creates a event for the time_spent change' do
        expect { subject.save }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          submitted_claim: claim,
          claim_version: claim.current_version,
          event_type: 'Event::Edit',
          linked_type: 'work_items',
          linked_id: id,
          details: {
            'field' => 'time_spent',
            'from' => 161,
            'to' => 95,
            'change' => -66,
            'comment' => 'change to work items'
          }
        )
      end

      it 'updates the JSON data' do
        subject.save
        work_item = claim.reload
                         .data['work_items']
                         .detect { |row| row.dig('work_type', 'value') == 'waiting' }
        expect(work_item).to eq(
          'id' => 'cf5e303e-98dd-4b0f-97ea-3560c4c5f137',
          'time_spent' => 95,
          'pricing' => 24.0,
          'work_type' => { 'en' => 'Waiting', 'value' => 'waiting' },
          'uplift' => 95,
          'fee_earner' => 'aaa',
          'completed_on' => '2022-12-12'
        )
      end
    end
  end
end
