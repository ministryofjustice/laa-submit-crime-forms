require 'rails_helper'

RSpec.describe Steps::FirmDetailsForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  describe '#save' do
    it 'is always valid' do
      expect(form).to be_valid
    end

    it 'does nothing' do
      expect(form.save).to be_truthy
    end
  end
end
