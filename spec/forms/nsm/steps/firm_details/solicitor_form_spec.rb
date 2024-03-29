require 'rails_helper'

RSpec.describe Nsm::Steps::FirmDetails::SolicitorForm do
  subject(:form) { described_class.new(application:, alternative_contact_details:, **arguments) }

  let(:arguments) do
    {
      full_name:,
      reference_number:,
      contact_full_name:,
      contact_email:,
    }
  end

  let(:application) do
    instance_double(Claim)
  end

  let(:full_name) { 'Jame Roberts' }
  let(:reference_number) { 'ref1' }
  let(:contact_full_name) { 'JimBob' }
  let(:contact_email) { 'job@bob.com' }
  let(:alternative_contact_details) { 'no' }

  describe '#valid?' do
    context 'when all fields are set' do
      it 'is valid' do
        expect(form).to be_valid
      end
    end

    %i[full_name reference_number].each do |field|
      context "when #{field} is missing" do
        let(field) { nil }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end

    %i[contact_full_name contact_email].each do |field|
      context "when #{field} is missing and alternative_contact_details is NO" do
        let(field) { nil }

        it 'is not required to be set' do
          expect(form).to be_valid
        end
      end

      context "when #{field} is missing and alternative_contact_details is YES" do
        let(field) { nil }
        let(:alternative_contact_details) { 'yes' }

        it 'has a validation error on the field' do
          expect(form).not_to be_valid
          expect(form.errors.of_kind?(field, :blank)).to be(true)
        end
      end
    end
  end

  describe '#alternative_contact_details' do
    context 'when passed in as yes' do
      let(:alternative_contact_details) { 'yes' }

      it 'return yes value' do
        expect(form.alternative_contact_details).to eq(YesNoAnswer::YES)
      end
    end

    context 'when passed in as no' do
      let(:alternative_contact_details) { 'no' }

      it 'return no value' do
        expect(form.alternative_contact_details).to eq(YesNoAnswer::NO)
      end
    end

    context 'when passed in as other' do
      let(:alternative_contact_details) { 'other' }
      let(:contact_email) { nil }
      let(:contact_full_name) { nil }

      it 'determined based on presence of contact email and full anme' do
        expect(form.alternative_contact_details).to eq(YesNoAnswer::NO)
      end
    end

    context 'when not passed in' do
      let(:alternative_contact_details) { nil }

      context 'when contact_full_name is set' do
        let(:contact_email) { nil }

        it 'return yes value' do
          expect(form.alternative_contact_details).to eq(YesNoAnswer::YES)
        end
      end

      context 'when contact_email is set' do
        let(:contact_full_name) { nil }

        it 'return yes value' do
          expect(form.alternative_contact_details).to eq(YesNoAnswer::YES)
        end
      end

      context 'when neither contact fields are set' do
        let(:contact_email) { nil }
        let(:contact_full_name) { nil }

        it 'return no value' do
          expect(form.alternative_contact_details).to eq(YesNoAnswer::NO)
        end
      end
    end
  end

  describe '#alternative_contact_details?' do
    context 'when alternative_contact_details is YesNoAnswer::YES' do
      let(:alternative_contact_details) { 'yes' }

      it { expect(form).to be_alternative_contact_details }
    end

    context 'when alternative_contact_details is YesNoAnswer::NO' do
      let(:alternative_contact_details) { 'no' }

      it { expect(form).not_to be_alternative_contact_details }
    end
  end

  describe 'save!' do
    let!(:application) { create(:claim, solicitor:) }
    let(:alternative_contact_details) { 'yes' }
    let(:solicitor) { nil }

    context 'when application has an existing solicitor' do
      context 'and solicitor details have changed' do
        let(:solicitor) { Solicitor.new(arguments.merge(full_name: 'Jim Bob')) }

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
        before { Solicitor.create!(arguments.merge(full_name: 'Jim Bob')) }

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
          Solicitor.create!(arguments.merge(full_name: 'Jim Bob', previous: old_solicitor))
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

    context 'when alternative_contact_details is NO' do
      let(:alternative_contact_details) { 'no' }

      context 'and solicitor detail had contact details' do
        let(:solicitor) { Solicitor.new(arguments) }

        it 'creates a new solicitor record' do
          expect { subject.save! }.to change(Solicitor, :count).by(1)
                                                               .and(change { application.reload.solicitor_id })
        end
      end
    end
  end
end
