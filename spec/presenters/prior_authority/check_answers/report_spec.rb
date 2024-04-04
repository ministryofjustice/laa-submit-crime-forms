require 'rails_helper'

RSpec.describe PriorAuthority::CheckAnswers::Report do
  subject(:report) { described_class.new(application) }

  describe '#section_groups' do
    subject(:section_groups) { report.section_groups }

    context 'with non prison law application' do
      let(:application) { build_stubbed(:prior_authority_application, :with_complete_non_prison_law) }

      it 'contains expected section headings' do
        expect(section_groups.pluck(:heading))
          .to contain_exactly(
            '',
            'Contact details',
            'About the case',
            'About the request',
          )
      end

      it 'contains expected card titles' do
        card_titles = section_groups.flat_map { |group| group[:sections].map(&:title) }

        expect(card_titles)
          .to contain_exactly(
            'Application details',
            'Case contact',
            'Client details',
            'Case details',
            'Hearing details',
            'Primary quote',
            'Alternative quotes',
            'Reason for prior authority',
          )
      end
    end

    context 'with prison law application' do
      let(:application) { build_stubbed(:prior_authority_application, :with_complete_prison_law) }

      it 'contains expected section headings' do
        expect(section_groups.pluck(:heading))
          .to contain_exactly(
            '',
            'Contact details',
            'About the case',
            'About the request',
          )
      end

      it 'contains expected card titles' do
        card_titles = section_groups.flat_map { |group| group[:sections].map(&:title) }

        expect(card_titles)
          .to contain_exactly(
            'Application details',
            'Case contact',
            'Client details',
            'Case and hearing details',
            'Primary quote',
            'Alternative quotes',
            'Reason for prior authority',
          )
      end
    end

    context 'with further informations present' do
      let(:application) do
        build(:prior_authority_application,
              :with_complete_non_prison_law,
              :with_further_information_request)
      end

      it 'contains expected section headings' do
        expect(section_groups.pluck(:heading))
          .to contain_exactly(
            '',
            'Contact details',
            'About the case',
            'About the request',
          )
      end

      it 'contains expected card titles' do
        card_titles = section_groups.flat_map { |group| group[:sections].map(&:title) }

        expect(card_titles)
          .to contain_exactly(
            'Application details',
            'Case contact',
            'Client details',
            'Case details',
            'Hearing details',
            'Primary quote',
            'Alternative quotes',
            'Reason for prior authority',
            'Further information requested',
          )
      end
    end
  end
end
