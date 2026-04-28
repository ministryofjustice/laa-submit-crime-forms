require 'rails_helper'

RSpec.describe TestData::DataProfile do
  describe '.parse_version_mix' do
    it 'returns nil for blank values' do
      expect(described_class.parse_version_mix(nil)).to be_nil
    end

    it 'parses comma-separated version weights' do
      expect(described_class.parse_version_mix('1:80,2:15,3:5')).to eq(
        1 => 80,
        2 => 15,
        3 => 5
      )
    end

    it 'rejects invalid version weights' do
      expect { described_class.parse_version_mix('1:80,2:0') }.to raise_error(
        ArgumentError,
        'VERSION_MIX must use positive integer version:weight pairs, e.g. 1:80,2:15,3:5'
      )
    end

    it 'rejects malformed version weights' do
      expect { described_class.parse_version_mix('1:80,2') }.to raise_error(
        ArgumentError,
        'VERSION_MIX must use positive integer version:weight pairs, e.g. 1:80,2:15,3:5'
      )
    end
  end

  describe '.normalize_version_mix' do
    it 'returns nil for blank values' do
      expect(described_class.normalize_version_mix(nil)).to be_nil
    end
  end

  describe '#providers' do
    it 'creates provider users with generated office codes' do
      profile = described_class.new(provider_count: 2, office_code_count: 4, seed: 1)

      expect { profile.providers }.to change(Provider, :count).by(2)
      expect(profile.providers.flat_map(&:office_codes).uniq.count).to eq 4
      expect(profile.providers).to all(have_attributes(email: /test-data-provider-\d+@example.com/))
    end

    it 'keeps office codes disjoint where there are enough office codes' do
      profile = described_class.new(provider_count: 3, office_code_count: 6, seed: 1)

      provider_office_codes = profile.providers.map(&:office_codes)

      expect(provider_office_codes.combination(2).map { |left, right| left & right }).to all(be_empty)
    end
  end

  describe '#assignment_for' do
    it 'returns a provider and one of that provider office codes' do
      profile = described_class.new(provider_count: 2, office_code_count: 4, seed: 1)

      assignment = profile.assignment_for(0)

      expect(assignment.provider.office_codes).to include(assignment.office_code)
    end

    it 'can route all claims to the configured high-volume office codes' do
      profile = described_class.new(
        provider_count: 2,
        office_code_count: 8,
        high_volume_office_ratio: 0.25,
        high_volume_claim_ratio: 1.0
      )

      expect(Array.new(6) { |index| profile.assignment_for(index).office_code }.uniq).to contain_exactly('T00001', 'T00002')
    end

    it 'can route claims away from high-volume office codes' do
      profile = described_class.new(
        provider_count: 2,
        office_code_count: 8,
        high_volume_office_ratio: 0.25,
        high_volume_claim_ratio: 0.0
      )

      expect(Array.new(6) { |index| profile.assignment_for(index).office_code }).not_to include('T00001', 'T00002')
    end
  end

  describe '#versions_for' do
    it 'uses a single version by default' do
      profile = described_class.new(provider_count: 1, office_code_count: 1)

      expect(Array.new(3) { |index| profile.versions_for(index) }).to eq [1, 1, 1]
    end

    it 'uses a weighted default distribution when multiple versions are requested' do
      profile = described_class.new(provider_count: 1, office_code_count: 1, max_versions: 3, seed: 1)

      expect(Array.new(100) { |index| profile.versions_for(index) }.tally).to eq(
        1 => 80,
        2 => 15,
        3 => 5
      )
    end

    it 'uses a configured weighted version distribution when provided' do
      profile = described_class.new(provider_count: 1, office_code_count: 1, version_mix: { 1 => 2, 4 => 1 }, seed: 1)

      expect(Array.new(3) { |index| profile.versions_for(index) }.tally).to eq(
        1 => 2,
        4 => 1
      )
      expect(profile.max_versions).to eq 4
    end
  end
end
