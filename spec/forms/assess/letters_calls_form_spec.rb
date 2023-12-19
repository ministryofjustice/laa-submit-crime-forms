require 'rails_helper'

RSpec.describe Assess::LettersCallsForm do
  subject { described_class.new(params) }

  let(:claim) { create(:submitted_claim) }
  let(:params) { { claim:, type:, count:, uplift:, item:, explanation:, current_user: } }
  let(:type) { 'letters' }
  let(:count) { 2 }
  let(:uplift) { 'yes' }
  let(:item) do
    instance_double(
      Assess::V1::LetterAndCall,
      count: 12,
      uplift: 95,
      provider_requested_uplift: provider_requested_uplift,
      uplift?: true
    )
  end
  let(:provider_requested_uplift) { 95 }
  let(:explanation) { 'change to letters' }
  let(:current_user) { instance_double(User) }

  describe '#validations' do
    describe '#type' do
      %w[letters calls].each do |type_value|
        context 'when it is letters' do
          let(:type) { type_value }

          it { expect(subject).to be_valid }
        end
      end

      context 'when it is something else' do
        let(:type) { 'other' }

        it 'is not valid' do
          expect(subject).not_to be_valid
          expect(subject.errors.of_kind?(:type, :inclusion)).to be(true)
        end
      end
    end

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
      let(:count) { 12 }
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

  describe '#persistance' do
    let(:current_user) { create(:caseworker) }

    context 'when record is invalid' do
      let(:count) { nil }

      it { expect(subject.save).to be_falsey }
    end

    it { expect(subject.save).to be_truthy }

    context 'when only count has changed' do
      let(:uplift) { 'no' }

      it 'creates a event for the count change' do
        expect { subject.save }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          submitted_claim: claim,
          claim_version: claim.current_version,
          event_type: 'Event::Edit',
          linked_type: 'letters_and_calls',
          linked_id: 'letters',
          details: {
            'field' => 'count',
            'from' => 12,
            'to' => 2,
            'change' => -10,
            'comment' => 'change to letters'
          }
        )
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.reload
                       .data['letters_and_calls']
                       .detect { |row| row.dig('type', 'value') == 'letters' }
        expect(letters).to eq(
          'count' => 2,
          'pricing' => 3.56,
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
          'uplift' => 95,
        )
      end
    end

    context 'when only uplift has changed' do
      let(:count) { 12 }

      it 'creates a event for the uplift change' do
        expect { subject.save }.to change(Event, :count).by(1)
        expect(Event.last).to have_attributes(
          submitted_claim: claim,
          claim_version: claim.current_version,
          event_type: 'Event::Edit',
          linked_type: 'letters_and_calls',
          linked_id: 'letters',
          details: {
            'field' => 'uplift',
            'from' => 95,
            'to' => 0,
            'change' => -95,
            'comment' => 'change to letters'
          }
        )
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.reload
                       .data['letters_and_calls']
                       .detect { |row| row.dig('type', 'value') == 'letters' }
        expect(letters).to eq(
          'count' => 12,
          'pricing' => 3.56,
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
          'uplift' => 0.0,
        )
      end
    end

    context 'when uplift and count have changed' do
      it 'creates an event for each field changed' do
        expect { subject.save }.to change(Event, :count).by(2)
      end

      it 'updates the JSON data' do
        subject.save
        letters = claim.reload
                       .data['letters_and_calls']
                       .detect { |row| row.dig('type', 'value') == 'letters' }
        expect(letters).to eq(
          'count' => 2,
          'pricing' => 3.56,
          'type' => { 'en' => 'Letters', 'value' => 'letters' },
          'uplift' => 0,
        )
      end
    end

    context 'when error during save' do
      before do
        allow(Event::Edit).to receive(:build).and_raise(StandardError)
      end

      it { expect(subject.save).to be_falsey }
    end
  end
end
