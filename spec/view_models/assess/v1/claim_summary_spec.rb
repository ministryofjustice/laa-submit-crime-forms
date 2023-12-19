require 'rails_helper'

RSpec.describe Assess::V1::ClaimSummary do
  describe 'main_defendant_name' do
    it 'returns the name attibute from the main defendant' do
      defendants = [
        { 'main' => false, 'full_name' => 'jimbob' },
        { 'main' => true, 'full_name' => 'bobjim' },
      ]
      summary = described_class.new('defendants' => defendants)
      expect(summary.main_defendant_name).to eq('bobjim')
    end

    context 'when no main defendant record - shouold not be possible' do
      it 'returns an empty string' do
        defendants = [
          { 'main' => false, 'full_name' => 'jimbob' },
        ]
        summary = described_class.new('defendants' => defendants)
        expect(summary.main_defendant_name).to eq('')
      end
    end
  end

  describe 'send_by_post' do
    it 'returns the attribute send by post as bool' do
      send_by_post = true
      summary = described_class.new('send_by_post' => send_by_post)
      expect(summary.send_by_post).to be(true)
    end
  end

  describe 'total' do
    context 'there is an adjusted total' do
      it 'returns the correct total' do
        summary = described_class.new('adjusted_total' => 100.20, 'submitted_total' => 50.00)
        expect(summary.total).to eq('£100.20')
      end
    end

    context 'there is no adjusted total' do
      it 'returns the correct total' do
        summary = described_class.new('submitted_total' => 70.20)
        expect(summary.total).to eq('£70.20')
      end
    end

    context 'no total' do
      it 'returns nil' do
        summary = described_class.new
        expect(summary.total).to be_nil
      end
    end
  end

  describe '#assiged_to' do
    it 'returns the first assignment' do
      assignment1 = double(:one)
      assignment2 = double(:two)
      assignments = [assignment1, assignment2]
      claim = instance_double(SubmittedClaim, assignments:)

      summary = described_class.new('claim' => claim)
      expect(summary.assigned_to).to eq(assignment1)
    end
  end

  describe '#accessed_on' do
    context 'when a decision has been made' do
      it 'returns the date from the last Decision event' do
        decision = create(:event, :decision)

        summary = described_class.new('claim' => decision.submitted_claim)
        expect(summary.assessed_on).to eq(decision.created_at)
      end
    end

    context 'when no decision has been made' do
      it 'returns nil' do
        summary = described_class.new('claim' => SubmittedClaim.new)
        expect(summary.assessed_on).to be_nil
      end
    end
  end
end
