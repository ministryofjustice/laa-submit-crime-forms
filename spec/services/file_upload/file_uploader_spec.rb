require 'rails_helper'

RSpec.describe FileUpload::FileUploader do
  subject { described_class.new() }
  describe '#new' do
    context 'development environment' do
      it 'returns local file uploader' do
        expect(described_class.new.instance_values['uploader']).to be_a(FileUpload::LocalFileUploader)
      end
    end

    context 'production environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      end

      it 'returns aws file uploader' do
        expect(described_class.new.instance_values['uploader']).to be_a(FileUpload::AwsFileUploader)
      end
    end
  end

  describe '#upload' do
    context 'development environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(false)
      end

      context 'CLAMBY_ENABLED is set to false' do
        before do
          allow(ENV).to receive(:fetch).with("CLAMBY_ENABLED", nil).and_return('false')
        end

        it 'runs without using clamby to scan the file' do
          expect{ subject.send(:scan_file, fixture_file_upload('test.png', 'image/png')) }.not_to raise_error
        end
      end

      context 'CLAMBY_ENABLED is set to true' do
        before do
          allow(ENV).to receive(:fetch).with("CLAMBY_ENABLED", nil).and_return('true')
          allow(Clamby).to receive(:safe?).and_return(false)
        end

        it 'runs without using clamby to scan the file' do
          expect{ subject.send(:scan_file, fixture_file_upload('test.png', 'image/png')) }.to raise_error(FileUpload::FileUploader::PotentialMalwareError)
        end
      end
    end

    context 'production environment' do
      before do
        allow(Rails).to receive_message_chain(:env, :production?).and_return(true)
      end

      context 'CLAMBY_ENABLED is set to false' do
        before do
          allow(ENV).to receive(:fetch).with("CLAMBY_ENABLED", nil).and_return('false')
        end

        it 'runs without using clamby to scan the file' do
          expect{ subject.send(:scan_file, fixture_file_upload('test.png', 'image/png')) }.to raise_error(FileUpload::FileUploader::PotentialMalwareError)
        end
      end

      context 'CLAMBY_ENABLED is set to true' do
        before do
          allow(ENV).to receive(:fetch).with("CLAMBY_ENABLED", nil).and_return('true')
          allow(Clamby).to receive(:safe?).and_return(false)
        end

        it 'runs without using clamby to scan the file' do
          expect{ subject.send(:scan_file, fixture_file_upload('test.png', 'image/png')) }.to raise_error(FileUpload::FileUploader::PotentialMalwareError)
        end
      end
    end
  end
end
