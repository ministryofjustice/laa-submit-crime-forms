require 'rails_helper'

RSpec.describe Auditor do
  subject { described_class.new(disabled_office_codes, since) }

  let(:since) { 3.days.ago }
  let(:disabled_office_codes) { %w[AAAAA BBBBB] }

  context 'when there has been some activity' do
    let(:preexisting_claim) { create(:claim, updated_at: since - 1.day, submitter: disabled_provider) }
    let(:new_claim) { create(:claim, updated_at: since + 1.day, submitter: disabled_provider) }
    let(:disabled_provider) { create(:provider, office_codes: %w[BBBBB CCCCC]) }

    let(:application) { create(:prior_authority_application, office_code: 'AAAAA', updated_at: since + 2.days) }

    let(:quote) { create(:quote, prior_authority_application: application, document: nil) }
    let(:supporting_document) do
      create(:supporting_document, documentable: quote, updated_at: since + 1.day, file_name: 'bing.png')
    end

    before do
      preexisting_claim
      new_claim
      application
      supporting_document
    end

    it 'outputs a pretty list of changes' do
      expect(subject.call.split("\n").map(&:strip).join("\n")).to eq(
        <<~OUTPUT.strip
          ===============================
          | Provider accounts affected: |
          ===============================
          EMAIL
          --------------------
          provider@example.com


          =======================
          | NSM claims updated: |
          =======================
          ID                                   | STATUS
          -------------------------------------|-------
          #{new_claim.id} | draft


          ============================
          | PA applications updated: |
          ============================
          ID                                   | STATUS
          -------------------------------------|----------
          #{application.id} | pre_draft


          ====================
          | Documents added: |
          ====================
          FILE_NAME | DOCUMENTABLE_ID                      | DOCUMENTABLE_TYPE
          ----------|--------------------------------------|------------------
          bing.png  | #{quote.id} | Quote
        OUTPUT
      )
    end
  end
end
