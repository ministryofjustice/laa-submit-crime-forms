require 'rails_helper'

RSpec.describe Nsm::Steps::FirmDetails::SolicitorForm do
  subject(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      first_name:,
      last_name:,
      reference_number:,
    }
  end

  let(:application) { instance_double(Claim, solicitor:) }
  let(:solicitor) { instance_double(Solicitor, persisted?: false) }

  let(:first_name) { 'James' }
  let(:last_name) { 'Roberts' }
  let(:reference_number) { 'ref1' }

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    %i[first_name last_name reference_number].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end
  end

  describe 'save!' do
    let!(:application) { create(:claim, solicitor:) }
    let(:solicitor) { nil }

    context 'when application has an existing solicitor' do
      context 'and solicitor detail have not changed' do
        let(:solicitor) { Solicitor.create(arguments) }

        it 'does nothing' do
          expect { subject.save! }.not_to change(Solicitor, :count)
        end
      end
    end

    context 'when application has no solictor' do
      it 'creates a new solicitor record' do
        expect { subject.save! }.to change(Solicitor, :count).by(1)
                                                             .and(change { application.reload.solicitor_id })
      end
    end
  end
end
