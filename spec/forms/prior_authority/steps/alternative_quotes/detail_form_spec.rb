require 'rails_helper'

RSpec.describe PriorAuthority::Steps::AlternativeQuotes::DetailForm do
  subject(:form) { described_class.new(arguments) }

  let(:arguments) do
    {
      record: record,
      application: application,
      contact_first_name: 'John',
      contact_last_name: 'Smith',
      organisation: 'Acme Ltd',
      postcode: 'SW1 1AA',
      file_upload: file_upload,
      items: '1',
      cost_per_item: '1',
      period: period,
      cost_per_hour: cost_per_hour,
      user_chosen_cost_type: user_chosen_cost_type,
      'travel_time(1)': '',
      'travel_time(2)': '',
      travel_cost_per_hour: travel_cost_per_hour,
      additional_cost_list: additional_cost_list,
      additional_cost_total: '',
    }
  end

  let(:period) { nil }
  let(:cost_per_hour) { nil }
  let(:user_chosen_cost_type) { nil }
  let(:travel_cost_per_hour) { '' }
  let(:additional_cost_list) { '' }
  let(:record) { build(:quote, document: nil) }
  let(:application) { build(:prior_authority_application, service_type: 'photocopying') }

  describe '#save' do
    let(:file_upload) { instance_double(ActionDispatch::Http::UploadedFile, tempfile:, content_type:) }
    let(:tempfile) { instance_double(File, size: 150) }
    let(:uploader) { instance_double(FileUpload::FileUploader, scan_file: nil) }
    let(:content_type) { 'application/pdf' }

    before do
      allow(FileUpload::FileUploader).to receive(:new).and_return(uploader)
    end

    context 'when file for upload is invalid' do
      let(:content_type) { 'application/dodgy-executable' }

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error message' do
        subject.save
        expect(subject.errors[:file_upload]).to include(
          'The selected file must be a DOC, DOCX, XLSX, XLS, RTF, ODT, JPG, BMP, PNG, TIF or PDF'
        )
      end
    end

    context 'when file upload fails' do
      before do
        allow(uploader).to receive(:upload).and_raise StandardError
      end

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error message' do
        subject.save
        expect(subject.errors[:file_upload]).to include(
          'Unable to upload file at this time'
        )
      end
    end

    context 'when only one travel field is filled in' do
      let(:travel_cost_per_hour) { '1' }

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error message' do
        subject.save
        expect(subject.errors[:travel_time]).to include(
          'To add travel costs you must enter both the time and the hourly cost'
        )
      end
    end

    context 'when only one additional cost field is filled in' do
      let(:additional_cost_list) { 'Photocopying' }

      it 'returns false' do
        expect(subject.save).to be false
      end

      it 'adds an appropriate error message' do
        subject.save
        expect(subject.errors[:additional_cost_total]).to include(
          'To add additional costs you must enter both a list of the additional costs and the total cost'
        )
      end
    end

    context 'when redundant fields are entered' do
      let(:period) { 180 }
      let(:cost_per_hour) { '35' }
      let(:items) { '3' }
      let(:cost_per_item) { '20' }
      let(:user_chosen_cost_type) { 'per_hour' }
      let(:application) { create(:prior_authority_application, service_type: 'custom') }
      let(:record) { build(:quote, document: nil, prior_authority_application: application) }
      let(:file_upload) { nil }

      it 'clears them out' do
        subject.save
        expect(record.reload).to have_attributes(
          items: nil,
          cost_per_item: nil
        )
      end
    end
  end

  describe '#travel_cost' do
    let(:arguments) do
      {
        record: record,
        application: application,
        'travel_time(1)': travel_hours,
        'travel_time(2)': travel_minutes,
        travel_cost_per_hour: '1'
      }
    end

    let(:travel_hours) { '1' }
    let(:travel_minutes) { '' }

    it 'returns 0 if travel_time is invalid' do
      expect(form.travel_cost).to eq 0
    end
  end
end
