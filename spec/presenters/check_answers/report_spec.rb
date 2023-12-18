# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CheckAnswers::Report do
  describe '#section_groups' do
    context 'not in a complete state' do
      subject { described_class.new(claim) }

      let(:claim) { build_stubbed(:claim, :complete) }

      context 'section groups' do
        it 'returns multiple groups' do
          expect(subject.section_groups).to be_an_instance_of Array
          expect(subject.section_groups.count).to eq 6
        end
      end

      context 'section group' do
        let(:section_group) { subject.section_group('claim_type', subject.claim_type_section) }

        it 'returns a section object' do
          expect(section_group[:heading]).to eq 'What you are claiming for'
          expect(section_group[:sections].count).to eq 1
        end
      end

      context 'sections' do
        let(:section) { subject.sections(subject.claim_type_section) }

        it 'returns group of cards' do
          expect(section.count).to eq 1
        end

        it 'has option to change' do
          expect(section[0][:card][:actions]).to include(
            "<a class=\"govuk-link\" href=\"/applications/#{claim.id}/steps/claim_type\">Change</a>"
          )
        end
      end

      context 'claim type section' do
        it 'returns multiple elements' do
          expect(subject.claim_type_section.count).to eq 1
        end
      end

      context 'about you section' do
        it 'returns multiple elements' do
          expect(subject.about_you_section.count).to eq 1
        end
      end

      context 'about defendants section' do
        it 'returns multiple elements' do
          expect(subject.about_defendant_section.count).to eq 1
        end
      end

      context 'about case section' do
        it 'returns multiple elements' do
          expect(subject.about_case_section.count).to eq 3
        end
      end

      context 'about claim section' do
        it 'returns multiple elements' do
          expect(subject.about_claim_section.count).to eq 6
        end
      end

      context 'supporting evidence section' do
        it 'returns a single element' do
          expect(subject.supporting_evidence_section.count).to eq 1
        end
      end
    end

    context 'in a complete state' do
      subject { described_class.new(claim, read_only: true) }

      let(:claim) { build(:claim, :complete, :completed_status) }

      context 'section groups' do
        it 'returns multiple groups' do
          expect(subject.section_groups).to be_an_instance_of Array
          expect(subject.section_groups.count).to eq 6
        end
      end

      context 'section group' do
        let(:section_group) { subject.section_group('claim_type', subject.claim_type_section) }

        it 'returns a section object' do
          expect(section_group[:heading]).to eq 'What you are claiming for'
          expect(section_group[:sections].count).to eq 1
        end
      end

      context 'sections' do
        let(:section) { subject.sections(subject.claim_type_section) }

        it 'returns group of cards' do
          expect(section.count).to eq 1
        end

        it 'has option to change' do
          expect(section[0][:card][:actions]).to eq []
        end
      end

      context 'claim type section' do
        it 'returns multiple elements' do
          expect(subject.claim_type_section.count).to eq 1
        end
      end

      context 'about you section' do
        it 'returns multiple elements' do
          expect(subject.about_you_section.count).to eq 1
        end
      end

      context 'about defendants section' do
        it 'returns multiple elements' do
          expect(subject.about_defendant_section.count).to eq 1
        end
      end

      context 'about case section' do
        it 'returns multiple elements' do
          expect(subject.about_case_section.count).to eq 3
        end
      end

      context 'about claim section' do
        it 'returns multiple elements' do
          expect(subject.about_claim_section.count).to eq 6
        end
      end

      context 'supporting evidence section' do
        it 'returns a single element' do
          expect(subject.supporting_evidence_section.count).to eq 1
        end
      end
    end
  end
end
