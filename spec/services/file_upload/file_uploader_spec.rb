require 'rails_helper'

RSpec.describe FileUpload::FileUploader do
  subject(:file_uploader) { described_class.new }

  let(:dummy_file) { fixture_file_upload('test.png', 'image/png') }

  describe '#new' do
    context 'development environment' do
      it 'returns local file uploader' do
        expect(described_class.new.instance_values['uploader']).to be_a(FileUpload::LocalFileUploader)
      end
    end

    context 'when production environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      end

      it 'returns aws file uploader' do
        expect(described_class.new.instance_values['uploader']).to be_a(FileUpload::AwsFileUploader)
      end
    end
  end

  describe '#scan_file' do
    subject(:scan_file) { file_uploader.scan_file(dummy_file) }

    context 'when development environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(false)
        allow(Clamby).to receive(:safe?).and_return(false)
      end

      context 'when CLAMBY_ENABLED is set to false' do
        before do
          allow(ENV).to receive(:fetch).with('CLAMBY_ENABLED', nil).and_return('false')
        end

        it 'does not scan the file' do
          expect { scan_file }.not_to raise_error
        end
      end

      context 'when CLAMBY_ENABLED is set to true' do
        before do
          allow(ENV).to receive(:fetch).with('CLAMBY_ENABLED', nil).and_return('true')
          allow(Clamby).to receive(:safe?).and_return(false)
        end

        it 'scans the file, raising errors when not safe' do
          expect { scan_file }.to raise_error(FileUpload::FileUploader::PotentialMalwareError)
        end
      end
    end

    context 'when production environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
        allow(Clamby).to receive(:safe?).and_return(false)
      end

      context 'when CLAMBY_ENABLED is set to false' do
        before do
          allow(ENV).to receive(:fetch).with('CLAMBY_ENABLED', nil).and_return('false')
        end

        it 'scans the file, raising errors when not safe' do
          expect { scan_file }.to raise_error(FileUpload::FileUploader::PotentialMalwareError)
        end
      end

      context 'when CLAMBY_ENABLED is set to true' do
        before do
          allow(ENV).to receive(:fetch).with('CLAMBY_ENABLED', nil).and_return('true')
          allow(Clamby).to receive(:safe?).and_return(false)
        end

        it 'scans the file, raising errors when not safe' do
          expect { scan_file }.to raise_error(FileUpload::FileUploader::PotentialMalwareError)
        end
      end
    end
  end
end
