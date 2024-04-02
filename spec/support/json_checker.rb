# TODO: convert this to a matcher instead - if possible
module JsonChecker
  def check_json(payload)
    Checker.new(self, payload)
  end

  class Checker
    attr_reader :rspec, :payload

    def initialize(rspec, payload)
      @rspec = rspec
      @payload = payload
    end

    def matches(json)
      tester = rspec.double(:tester, process: true)
      tester.process(payload)
      rspec.expect(tester).to rspec.have_received(:process).with(json)
    end
  end
end

RSpec.configuration.include JsonChecker
