require 'rails_helper'

RSpec.describe Steps::FirmDetails::SolicitorForm do
  subject(:form) { described_class.new(application:, **arguments) }

  let(:arguments) do
    {
      first_name:,
      surname:,
      reference_number:,
      contact_full_name:,
      telephone_number:,
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  let(:first_name) { 'James' }
  let(:surname) { 'Robert' }
  let(:reference_number) { 'ref1' }
  let(:contact_full_name) { 'JimBob' }
  let(:telephone_number) { '111' }

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    %i[first_name surname reference_number contact_full_name telephone_number].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'has is a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end
  end

  describe 'save!' do
    let!(:application) { Claim.create!(office_code: 'AAA', solicitor: solicitor) }
    let(:solicitor) { nil }

    context 'when application has an existing solicitor' do
      context 'and solicitor details have changed' do
        let(:solicitor) { Solicitor.new(arguments.merge(first_name: 'Jim')) }

        it 'creates a new solicitor record' do
          expect { subject.save! }.to change(Solicitor, :count).by(1)
                                                               .and(change { application.reload.solicitor_id })
        end
      end

      context 'and solicitor detail have not changed' do
        let(:solicitor) { Solicitor.new(arguments) }

        it 'does nothing' do
          expect { subject.save! }.not_to change(Solicitor, :count)
        end
      end
    end

    context 'when application has no solictor but one exists for the the reference code' do
      context 'and solicitor details have changed' do
        before { Solicitor.create!(arguments.merge(first_name: 'Jim')) }

        it 'creates a new solicitor record' do
          expect { subject.save! }.to change(Solicitor, :count).by(1)
                                                               .and(change { application.reload.solicitor_id })
        end
      end

      context 'and solicitor detail have not changed' do
        before { Solicitor.create!(arguments) }

        it 'does nothing' do
          expect { subject.save! }.not_to change(Solicitor, :count)
        end
      end

      context 'it matches a historic solicitor details' do
        before do
          old_solicitor = travel_to(1.day.ago) { Solicitor.create!(arguments) }
          Solicitor.create!(arguments.merge(first_name: 'Jim', previous: old_solicitor))
        end

        it 'create a new solicitor record' do
          expect { subject.save! }.to change(Solicitor, :count).by(1)
                                                               .and(change { application.reload.solicitor_id })
        end
      end
    end

    context 'when application has no solictor and non exist for the the reference code' do
      it 'creates a new solicitor record' do
        expect { subject.save! }.to change(Solicitor, :count).by(1)
                                                             .and(change { application.reload.solicitor_id })
      end
    end
  end
end
