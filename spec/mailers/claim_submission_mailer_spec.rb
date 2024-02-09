# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimSubmissionMailer, type: :mailer do
  let(:feedback_template) { '0403454c-47a5-4540-804c-cb614e77dc22' }
  let(:claim) { build(:claim, :case_type_magistrates, :main_defendant, :letters_calls) }

  describe '#notify' do
    subject(:mail) { described_class.notify(claim) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient from config' do
      expect(mail.to).to eq(['provider@example.com'])
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq feedback_template
    end

    context 'defendant with maat id' do
      it 'sets personalisation from args' do
        expect(
          mail.govuk_notify_personalisation
        ).to include(
          LAA_case_reference: 'LAA-n4AohV',
          UFN: '123456/001',
          main_defendant_name: 'bob jim',
          defendant_reference: 'MAAT ID: AA1',
          claim_total: '£20.45',
          date: DateTime.now.to_fs(:stamp),
          feedback_url: 'tbc'
        )
      end
    end

    context 'defendant with cntp id' do
      let(:claim) { build(:claim, :case_type_breach, :breach_defendant, :letters_calls) }

      it 'sets personalisation from args' do
        expect(
          mail.govuk_notify_personalisation
        ).to include(
          LAA_case_reference: 'LAA-n4AohV',
          UFN: '123456/002',
          main_defendant_name: 'bob jim',
          defendant_reference: "Client's CNTP number: CNTP12345",
          claim_total: '£20.45',
          date: DateTime.now.to_fs(:stamp),
          feedback_url: 'tbc'
        )
      end
    end
  end
end
