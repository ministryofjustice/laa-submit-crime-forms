require 'rails_helper'

RSpec.describe ListRow do
  describe '#main_defendant' do
    subject(:main_defendant) { described_class.new(app_store_record).main_defendant }

    context "when there isn't one" do
      let(:app_store_record) { { 'application' => {} } }

      it 'does not blow up' do
        expect(main_defendant).to be_nil
      end
    end
  end

  describe '#defendant' do
    subject(:defendant) { described_class.new(app_store_record).defendant }

    context "when there isn't one" do
      let(:app_store_record) { { 'application' => {} } }

      it 'does not blow up' do
        expect(defendant).to be_nil
      end
    end
  end
end
