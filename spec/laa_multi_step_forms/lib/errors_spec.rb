require 'rails_helper'

RSpec.describe Errors do
  it { expect(Errors::InvalidSession).to be < StandardError }
  it { expect(Errors::ApplicationNotFound).to be < StandardError }
end
