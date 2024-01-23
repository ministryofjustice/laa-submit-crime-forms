require 'rails_helper'

RSpec.describe StepsHelper, type: :helper do
  let(:application_klass) do
    Class.new(ApplicationRecord) do
      def self.load_schema! = @columns_hash = {}
      def self.name = 'Application'

      def navigation_stack
        @navigation_stack ||= []
      end
    end
  end

  describe '#step_form' do
    let(:foo_bar_record) do
      Class.new(ApplicationRecord) do
        def self.load_schema! = @columns_hash = {}
      end
    end
    let(:expected_defaults) do
      {
        url: {
          controller: 'steps',
          action: :update
        },
      html: {
        class: 'edit_foo_bar_record'
      },
      method: :put
      }
    end
    let(:form_block) { proc {} }
    let(:record) { foo_bar_record.new }

    before do
      stub_const('FooBarRecord', foo_bar_record)
    end

    it 'acts like FormHelper#form_for with additional defaults' do
      expect(helper).to receive(:form_for).with(record, expected_defaults) do |*_args, &block|
        expect(block).to eq(form_block)
      end
      helper.step_form(record, &form_block)
    end

    it 'accepts additional options like FormHelper#form_for would' do
      expect(helper).to receive(:form_for).with(record, expected_defaults.merge(foo: 'bar'))
      helper.step_form(record, { foo: 'bar' })
    end

    it 'appends optional css classes if provided' do
      expect(helper).to receive(:form_for).with(record,
                                                expected_defaults.merge(html: { class: %w[test edit_foo_bar_record] }))
      helper.step_form(record, html: { class: 'test' })
    end
  end

  describe '#step_header' do
    let(:current_application) { instance_double(application_klass, navigation_stack:) }
    let(:navigation_stack) { %w[/step1 /step2 /step3] }

    before do
      allow(view).to receive(:current_application).and_return(current_application)
      allow(view.request).to receive(:fullpath).and_return('/step3')
    end

    context 'there is a previous path in the stack' do
      it 'renders the back link to the previous path' do
        helper.step_header
        expect(view.content_for(:back_link)).to match(%r{<a class="govuk-back-link" href="/step2">Back</a>})
      end
    end

    context 'there is no previous path in the stack' do
      let(:navigation_stack) { nil }

      it 'renders the back link to the root path as fallback' do
        helper.step_header
        expect(view.content_for(:back_link)).to match(%r{<a class="govuk-back-link" href="/">Back</a>})
      end
    end

    context 'a specific path is provided' do
      it 'renders the back link with the provided path' do
        helper.step_header(path: '/another/step')
        expect(view.content_for(:back_link)).to match(%r{<a class="govuk-back-link" href="/another/step">Back</a>})
      end
    end
  end

  describe '#previous_step_path' do
    let(:current_application) { instance_double(application_klass, navigation_stack:) }

    before do
      allow(view).to receive(:current_application).and_return(current_application)
      allow(view.request).to receive(:fullpath).and_return('/rainbow')
    end

    context 'when the stack is empty' do
      let(:navigation_stack) { [] }

      it 'returns the root path' do
        expect(helper.previous_step_path).to eq('/')
      end
    end

    context 'when the stack has elements' do
      let(:navigation_stack) { %w[/somewhere /over /the /rainbow] }

      it 'returns the element before the last page' do
        expect(helper.previous_step_path).to eq('/the')
      end

      context 'and current path is in the middle' do
        let(:navigation_stack) { %w[/somewhere /rainbow /over /the] }

        it 'returns the element before the last page' do
          expect(helper.previous_step_path).to eq('/somewhere')
        end
      end

      # TODO: this is most likley wrong but is the best option at the moment
      # there is a ticket to rethink this and work out the correct approach
      context 'and current path is not in the list' do
        let(:navigation_stack) { %w[/somewhere /over /the] }

        it 'returns the element before the last page' do
          expect(helper.previous_step_path).to eq(root_path)
        end
      end
    end

    context 'no current_application' do
      let(:navigation_stack) { nil }

      it 'returns the root path' do
        allow(view).to receive(:current_application).and_return(nil)
        expect(helper.previous_step_path).to eq('/')
      end
    end
  end

  describe '#govuk_error_summary' do
    context 'when no form object is given' do
      let(:form_object) { nil }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object without errors is given' do
      let(:form_object) { Nsm::Steps::BaseFormObject.new }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object with errors is given' do
      let(:form_object) { Nsm::Steps::BaseFormObject.new }
      let(:title) { helper.content_for(:page_title) }

      before do
        helper.title('A page')
        form_object.errors.add(:base, :blank)
      end

      it 'returns the summary' do
        expect(
          helper.govuk_error_summary(form_object)
        ).to eq(
          '<div class="govuk-error-summary" data-module="govuk-error-summary">' \
          '<div role="alert"><h2 class="govuk-error-summary__title">There is a problem on this page</h2>' \
          '<div class="govuk-error-summary__body"><ul class="govuk-list govuk-error-summary__list">' \
          '<li><a data-turbo="false" href="#steps-base-form-object-base-field-error">can&#39;t be blank</a></li>' \
          '</ul></div></div></div>'
        )
      end

      it 'prepends the page title with an error hint' do
        helper.govuk_error_summary(form_object)
        expect(title).to start_with('Error: A page')
      end
    end
  end

  describe '#link_button' do
    it 'builds the link markup styled as a button' do
      expect(
        helper.link_button('Continue', root_path)
      ).to eq(
        '<a class="govuk-button" role="button" draggable="false" data-module="govuk-button" href="/">Continue</a>'
      )
    end

    it 'appends to the default attributes where possible, otherwise overwrite them' do
      expect(
        helper.link_button('Continue', root_path, class: 'ga-pageLink', draggable: true,
data: { module: 'govuk-button', ga_category: 'category', ga_label: 'label' })
      ).to eq(
        '<a class="govuk-button ga-pageLink" role="button" draggable="true" data-module="govuk-button" ' \
        'data-ga-category="category" data-ga-label="label" href="/">Continue</a>'
      )
    end

    it 'supports block for content' do
      expect(
        helper.link_button(nil, root_path, draggable: true) { 'Drag this' }
      ).to eq(
        '<a class="govuk-button" role="button" draggable="true" data-module="govuk-button" href="/">Drag this</a>'
      )
    end
  end
end
