require 'rails_helper'

RSpec.describe Nsm::Steps::FirmDetails::SolicitorForm do
  subject(:form) { described_class.new(application:, alternative_contact_details:, **arguments) }

  let(:arguments) do
    {
      first_name:,
      last_name:,
      reference_number:,
      contact_first_name:,
      contact_last_name:,
      contact_email:,
    }
  end

  let(:application) { instance_double(Claim, solicitor:) }
  let(:solicitor) { instance_double(Solicitor, persisted?: false) }

  let(:first_name) { 'James' }
  let(:last_name) { 'Roberts' }
  let(:reference_number) { 'ref1' }
  let(:contact_first_name) { 'Jim' }
  let(:contact_last_name) { 'Bob' }
  let(:contact_email) { 'job@bob.com' }
  let(:alternative_contact_details) { 'no' }

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

    context 'when alternative contact has not been set in any way' do
      let(:contact_first_name) { nil }
      let(:contact_last_name) { nil }
      let(:contact_email) { nil }
      let(:alternative_contact_details) { nil }

      it 'has a validation error on the alternative contact' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:alternative_contact_details, :blank)).to be(true)
      end
    end

    %i[contact_first_name contact_last_name contact_email].each do |field|
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

    context 'when email is invalid' do
      let(:contact_email) { 'job.bob.com' }
      let(:alternative_contact_details) { 'yes' }

      it 'has validation error on email address' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_email, :invalid)).to be(true)
      end
    end

    context 'when email is invalid but contains a valid email address' do
      let(:contact_email) { 'job@bob.com-jim@bob.com' }
      let(:alternative_contact_details) { 'yes' }

      it 'has validation error on email address' do
        expect(form).not_to be_valid
        expect(form.errors.of_kind?(:contact_email, :invalid)).to be(true)
      end
    end
  end

  describe '#alternative_contact_details' do
    let(:solicitor) { instance_double(Solicitor, persisted?: persisted) }
    let(:application) { instance_double(Claim, solicitor:) }
    let(:persisted) { false }

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
      let(:contact_first_name) { nil }
      let(:contact_last_name) { nil }

      it 'determined based on presence of contact email and full anme' do
        expect(form.alternative_contact_details).to be_nil
      end
    end

    context 'when not passed in' do
      let(:alternative_contact_details) { nil }

      context 'when contact_first_name is set' do
        let(:contact_email) { nil }

        it 'return yes value' do
          expect(form.alternative_contact_details).to eq(YesNoAnswer::YES)
        end
      end

      context 'when contact_email is set' do
        let(:contact_first_name) { nil }

        let(:contact_last_name) { nil }

        it 'return yes value' do
          expect(form.alternative_contact_details).to eq(YesNoAnswer::YES)
        end
      end

      context 'when neither contact fields are set' do
        let(:contact_email) { nil }
        let(:contact_first_name) { nil }
        let(:contact_last_name) { nil }

        context 'when the form has previously been completed' do
          let(:persisted) { true }

          it 'return no value' do
            expect(form.alternative_contact_details).to eq(YesNoAnswer::NO)
          end
        end

        context 'when the form has not previously been completed' do
          it 'return nil value' do
            expect(form.alternative_contact_details).to be_nil
          end
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
        let(:solicitor) { Solicitor.new(arguments.merge(first_name: 'Jim', last_name: 'Bob')) }

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
        before { Solicitor.create!(arguments.merge(first_name: 'Jim', last_name: 'Bob')) }

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
          Solicitor.create!(arguments.merge(first_name: 'Jim', last_name: 'Bob', previous: old_solicitor))
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
