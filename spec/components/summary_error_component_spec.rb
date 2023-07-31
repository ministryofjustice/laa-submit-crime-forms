require 'rails_helper'

RSpec.describe SummaryErrorComponent, type: :component do
  let(:component) { described_class.new(records:, form:) }
  let(:records) { [double(:record)] }
  let(:form) { double(:form_class, build: form_instance) }
  let(:form_instance) { double(:form, valid?: valid) }
  let(:error_content) do
    <<~CONTENT
      <div class="moj-banner moj-banner--warning" role="region" aria-label="Warning">

        <svg class="moj-banner__icon" fill="currentColor" role="presentation" focusable="false" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 25 25" height="25" width="25">
          <path d="M13.6,15.4h-2.3v-4.5h2.3V15.4z M13.6,19.8h-2.3v-2.2h2.3V19.8z M0,23.2h25L12.5,2L0,23.2z" />
        </svg>

        <div class="moj-banner__message">
          <h2 class="govuk-error-summary__title">
            More info needed
          </h2>
          <div class="govuk-error-summary__body">
            <p>We need more informationto help us review your report.</p>
            <p>We've highlighted the sections you need to look at.</p>
          </div>
        </div>
      </div>
    CONTENT
  end

  context 'when all records are valid' do
    let(:valid) { true }

    it 'does not render anything' do
      render_inline(component)

      expect(rendered_content).to eq('')
    end
  end

  context 'when any records are valid' do
    let(:valid) { false }

    it 'renders the warning banner' do
      render_inline(component)

      expect(rendered_content).to eq(error_content)
    end
  end

  context 'when multiple form need to be validated per record' do
    let(:form) { [form_class_one, form_class_two] }
    let(:form_class_one) { double(:form_class, build: form_instance_one) }
    let(:form_class_two) { double(:form_class, build: form_instance_two) }
    let(:form_instance_one) { double(:form, valid?: true) }
    let(:form_instance_two) { double(:form, valid?: valid) }

    context 'both are valid' do
      let(:valid) { true }

      it 'does not render anything' do
        render_inline(component)

        expect(rendered_content).to eq('')
      end
    end

    context 'any are invalid' do
      let(:valid) { false }

      it 'renders the warning banner' do
        render_inline(component)

        expect(rendered_content).to eq(error_content)
      end
    end
  end
end
