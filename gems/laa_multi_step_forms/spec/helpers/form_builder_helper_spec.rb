require 'rails_helper'

RSpec.describe LaaMultiStepForms::FormBuilderHelper, type: :helper do
  let(:form_object) { double('FormObject') }

  let(:builder) do
    GOVUKDesignSystemFormBuilder::FormBuilder.new(
      :object_name,
      form_object,
      self,
      {}
    )
  end

  describe '#refresh_button' do
    context 'standard button' do
      let(:expected_markup) do
        '<button type="submit" formnovalidate="formnovalidate" class="govuk-button govuk-button--secondary" ' \
          'data-module="govuk-button" data-prevent-double-click="true" name="save_and_refresh">' \
          'Update the calculation</button>'
      end

      it 'outputs only the continue button' do
        expect(
          builder.refresh_button
        ).to eq(expected_markup)
      end
    end

    context 'button text can be customised' do
      before do
        # Ensure we don't rely on specific locales, so we have predictable tests
        allow(I18n).to receive(:t).with('helpers.submit.refresh').and_return('Refresh')
      end

      it 'outputs the buttons with specific text' do
        html = builder.refresh_button(button: :refresh)
        doc = Nokogiri::HTML.fragment(html)

        assert_select(doc, 'button', attributes: { name: 'save_and_refresh' }, text: 'Refresh')
      end
    end

    context 'custom attributes' do
      it 'outputs the buttons with additional attributes' do
        html = builder.refresh_button(
          opts: { class: 'custom-class-secondary', foo: 'bar' }
        )
        doc = Nokogiri::HTML.fragment(html)

        assert_select(
          doc, 'button', attributes: { class: 'govuk-button govuk-button--secondary custom-class-secondary',
foo: 'bar' }
        )
      end
    end
  end

  describe '#reload_button' do
    context 'standard button' do
      let(:expected_markup) do
        '<button type="submit" formnovalidate="formnovalidate" class="govuk-button govuk-button--secondary" ' \
          'data-module="govuk-button" data-prevent-double-click="true" name="reload">' \
          'Update the calculation</button>'
      end

      it 'outputs only the continue button' do
        expect(
          builder.reload_button
        ).to eq(expected_markup)
      end
    end

    context 'button text can be customised' do
      before do
        # Ensure we don't rely on specific locales, so we have predictable tests
        allow(I18n).to receive(:t).with('helpers.submit.refresh').and_return('Refresh')
      end

      it 'outputs the buttons with specific text' do
        html = builder.reload_button(button: :refresh)
        doc = Nokogiri::HTML.fragment(html)

        assert_select(doc, 'button', attributes: { name: 'save_and_refresh' }, text: 'Refresh')
      end
    end

    context 'custom attributes' do
      it 'outputs the buttons with additional attributes' do
        html = builder.reload_button(
          opts: { class: 'custom-class-secondary', foo: 'bar' }
        )
        doc = Nokogiri::HTML.fragment(html)

        assert_select(
          doc, 'button', attributes: { class: 'govuk-button govuk-button--secondary custom-class-secondary',
foo: 'bar' }
        )
      end
    end
  end

  describe '#continue_button' do
    context 'when there is no secondary action' do
      let(:expected_markup) do
        '<button type="submit" formnovalidate="formnovalidate" class="govuk-button" ' \
          'data-module="govuk-button" data-prevent-double-click="true">Save and continue</button>'
      end

      it 'outputs only the continue button' do
        expect(
          builder.continue_button(secondary: false)
        ).to eq(expected_markup)
      end
    end

    context 'when there is a secondary action' do
      let(:expected_markup) do
        '<div class="govuk-button-group">' \
          '<button type="submit" formnovalidate="formnovalidate" class="govuk-button" ' \
          'data-module="govuk-button" data-prevent-double-click="true">Save and continue</button>' \
          '<button type="submit" formnovalidate="formnovalidate" class="govuk-button govuk-button--secondary" ' \
          'data-module="govuk-button" data-prevent-double-click="true" name="commit_draft">' \
          'Save and come back later</button></div>'
      end

      it 'outputs the continue button together with a save draft button' do
        expect(
          builder.continue_button
        ).to eq(expected_markup)
      end
    end

    context 'button text can be customised' do
      before do
        # Ensure we don't rely on specific locales, so we have predictable tests
        allow(I18n).to receive(:t).with('helpers.submit.find_address').and_return('Find address')
        allow(I18n).to receive(:t).with('helpers.submit.enter_manually').and_return('Enter address manually')
      end

      it 'outputs the buttons with specific text' do
        html = builder.continue_button(primary: :find_address, secondary: :enter_manually)
        doc = Nokogiri::HTML.fragment(html)

        assert_select(doc, 'button', attributes: { name: nil }, text: 'Find address')
        assert_select(doc, 'button', attributes: { name: 'commit_draft' }, text: 'Enter address manually')
      end
    end

    context 'custom attributes' do
      it 'outputs the buttons with additional attributes' do
        html = builder.continue_button(
          primary_opts: { class: 'custom-class-primary', foo: 'bar' },
          secondary_opts: { class: 'custom-class-secondary' }
        )
        doc = Nokogiri::HTML.fragment(html)

        assert_select(
          doc, 'button', attributes: { class: 'govuk-button custom-class-primary', foo: 'bar' }
        )
        assert_select(
          doc, 'button', attributes: { class: 'govuk-button govuk-button--secondary custom-class-secondary' }
        )
      end
    end
  end
end
