# Using this allows for easier diff checking as the `have_received` matcher puts individual line diff
# instead of just the entire blob. This greatly speeds up the fixing process when something has been
# changed
module JsonChecker
  # TODO: convert this to a matcher instead - if possible
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
