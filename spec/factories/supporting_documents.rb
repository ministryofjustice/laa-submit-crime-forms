FactoryBot.define do
  factory :supporting_document do
    file_name { 'test.png' }
    file_type { 'image/png' }
    file_size { '1234' }
    file_path { 'test_path' }
    documentable_type { 'PriorAuthorityApplication' }
    document_type { 'supporting_document' }

    factory :supporting_evidence do
      documentable_type { 'Claim' }
      document_type { 'supporting_evidence' }
    end

    factory :further_information_document do
      documentable_type { 'FurtherInformation' }
      document_type { 'supporting_document' }
    end

    factory :quote_document do
      document_type { 'quote_document' }
    end
  end
end
