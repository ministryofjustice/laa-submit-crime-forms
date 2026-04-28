module TestData
  class DataProfile
    Assignment = Struct.new(:provider, :office_code, keyword_init: true)

    DEFAULT_HIGH_VOLUME_OFFICE_RATIO = 0.1
    DEFAULT_HIGH_VOLUME_CLAIM_RATIO = 0.6
    DEFAULT_VERSION_MIX = { 1 => 80, 2 => 15, 3 => 5 }.freeze

    attr_reader :provider_count, :office_code_count, :max_versions

    def self.parse_version_mix(raw_value)
      return if raw_value.blank?

      normalize_version_mix(
        raw_value.split(',').to_h do |pair|
          version, weight = pair.split(':', 2)
          [version, weight]
        end
      )
    end

    def self.normalize_version_mix(version_mix)
      return if version_mix.blank?

      version_mix.to_h.transform_keys { |version| Integer(version) }.transform_values { |weight| Integer(weight) }.tap do |mix|
        if mix.any? { |version, weight| version < 1 || weight < 1 }
          raise ArgumentError, 'VERSION_MIX must use positive integer version:weight pairs, e.g. 1:80,2:15,3:5'
        end
      end
    rescue ArgumentError, TypeError
      raise ArgumentError, 'VERSION_MIX must use positive integer version:weight pairs, e.g. 1:80,2:15,3:5'
    end

    def initialize(provider_count: 1, office_code_count: 1, max_versions: 1, seed: nil,
                   high_volume_office_ratio: DEFAULT_HIGH_VOLUME_OFFICE_RATIO,
                   high_volume_claim_ratio: DEFAULT_HIGH_VOLUME_CLAIM_RATIO, version_mix: nil)
      @provider_count = [provider_count.to_i, 1].max
      @office_code_count = [office_code_count.to_i, 1].max
      @random = seed.present? ? Random.new(seed.to_i) : Random.new
      @high_volume_office_ratio = high_volume_office_ratio.to_f
      @high_volume_claim_ratio = high_volume_claim_ratio.to_f
      @version_mix = self.class.normalize_version_mix(version_mix) || default_version_mix_for(max_versions.to_i)
      @max_versions = @version_mix.present? ? @version_mix.keys.max : [max_versions.to_i, 1].max
    end

    def providers
      @providers ||= build_providers
    end

    def office_codes
      @office_codes ||= Array.new(office_code_count) { |index| format('T%05d', index + 1) }
    end

    def assignment_for(index)
      office_code = office_code_for(index)

      Assignment.new(provider: provider_for_office_code.fetch(office_code), office_code: office_code)
    end

    def versions_for(index)
      return weighted_versions[index % weighted_versions.length] if version_mix.present?

      1 + (index % max_versions)
    end

    private

    attr_reader :random, :high_volume_office_ratio, :high_volume_claim_ratio, :version_mix

    def build_providers
      office_groups = office_codes.each_slice(codes_per_provider).to_a

      Array.new(provider_count) do |index|
        FactoryBot.create(
          :provider,
          :other,
          email: "test-data-provider-#{index + 1}@example.com",
          office_codes: office_groups[index] || [office_codes[index % office_codes.length]]
        )
      end
    end

    def codes_per_provider
      [(office_codes.length.to_f / provider_count).ceil, 1].max
    end

    def office_code_for(index)
      preferred_codes = preferred_office_codes

      preferred_codes[index % preferred_codes.length]
    end

    def preferred_office_codes
      if high_volume_office_codes.any? && (low_volume_office_codes.empty? || random.rand < high_volume_claim_ratio)
        high_volume_office_codes
      else
        low_volume_office_codes.presence || office_codes
      end
    end

    def high_volume_office_codes
      @high_volume_office_codes ||= office_codes.first(high_volume_office_count)
    end

    def low_volume_office_codes
      @low_volume_office_codes ||= office_codes - high_volume_office_codes
    end

    def high_volume_office_count
      [(office_codes.length * high_volume_office_ratio).ceil, 1].max
    end

    def provider_for_office_code
      @provider_for_office_code ||= providers.each_with_object({}) do |provider, mapping|
        provider.office_codes.each { |office_code| mapping[office_code] = provider }
      end
    end

    def default_version_mix_for(max_versions)
      return if max_versions <= 1

      self.class.normalize_version_mix(DEFAULT_VERSION_MIX.select { |version, _weight| version <= max_versions })
    end

    def weighted_versions
      @weighted_versions ||= version_mix.flat_map { |version, weight| [version] * weight }.shuffle(random:)
    end
  end
end
