module TestData
  class NsmBuilder
    NSM_TO_BUILD = 1000

    attr_reader :year, :providers

    def initialize(year, providers)
      @year = year
      @providers = providers
    end

    def build(nsm_to_build: NSM_TO_BUILD)
      nsm_to_build.times do |i|
        data = nsm_data.sample.new(
          date: (Date.new(year, 1, 1) + rand(36)).next_weekday,
          provider: providers.sample
        )

        NsmBuild.new(data).build
      end
    end

    def nsm_data
      [
        Base,
        BreachOfInjunction
      ]
    end
  end
end