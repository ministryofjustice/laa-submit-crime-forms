require 'rails_helper'

RSpec.describe Steps::DeleteForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      application:,
      record:,
      id:,
    }
  end

  let(:application) { double(:application) }
  let(:record) { double(record, id:, destroy: true) }
  let(:id) { SecureRandom.uuid }

  describe '#save!' do
    it 'deletes the selected record' do
      expect(record).to receive(:destroy)
      subject.save!
    end
  end
end
