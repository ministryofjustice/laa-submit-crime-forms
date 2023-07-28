require 'rails_helper'

RSpec.describe LaaMultiStepForms::ApplicationHelper, type: :helper do
  describe '#current_application' do
    it 'raises an error' do
      expect { helper.current_application }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context 'for a blank value' do
      let(:value) { '' }

      it { expect(title).to eq('Claim a non-standard magistrates&#39; court payment - GOV.UK') }
    end

    context 'for a provided value' do
      let(:value) { 'Test page' }

      it { expect(title).to eq('Test page - Claim a non-standard magistrates&#39; court payment - GOV.UK') }
    end
  end

  describe '#fallback_title' do
    before do
      allow(helper).to receive(:controller_name).and_return('my_controller')
      allow(helper).to receive(:action_name).and_return('an_action')

      # So we can simulate what would happen on production
      allow(
        Rails.application.config
      ).to receive(:consider_all_requests_local).and_return(false)
    end

    it 'calls #title with a blank value' do
      expect(helper).to receive(:title).with('')
      helper.fallback_title
    end

    context 'when consider_all_requests_local is true' do
      it 'raises an exception' do
        allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(true)
        expect { helper.fallback_title }.to raise_error('page title missing: my_controller#an_action')
      end
    end
  end

  describe '#app_environment' do
    context 'when ENV is set' do
      around do |spec|
        env = ENV.fetch('ENV', nil)
        ENV['ENV'] = 'test'
        spec.run
        ENV['ENV'] = env
      end

      it 'returns based on ENV variable' do
        expect(helper.app_environment).to eq('app-environment-test')
      end
    end

    context 'when ENV is not set' do
      it 'returns based with local' do
        expect(helper.app_environment).to eq('app-environment-local')
      end
    end
  end

  describe '#check_missing' do
    context 'when value is false' do
      it 'renders the missing tag' do
        expect(helper.check_missing(false)).to eq('<strong class="govuk-tag govuk-tag--red">Incomplete</strong>')
      end
    end

    context 'when value is truthy' do
      context 'and no block is passed in' do
        it 'renders the value' do
          expect(helper.check_missing('apples')).to eq('apples')
        end
      end
      context 'and ablock is passed in' do
        it 'renders block' do
          response = helper.check_missing('apples') do
            'pears'
          end
          expect(response).to eq('pears')
        end
      end
    end
  end

  describe '#format_period' do
    context 'when period is nil' do
      it { expect(helper.format_period(nil)).to eq('*required') }
    end

    context 'when period is not nil' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62)).to eq('1 Hr 2 Mins')
        expect(helper.format_period(1)).to eq('0 Hrs 1 Min')
      end
    end
  end

  describe '#suggestion_select' do
    let(:form) { double(:form, object: object, object_name: 'fruit_container_form', govuk_collection_select: true) }
    let(:object) { double(:object, '[]': value) }
    let(:field) { :fruit }
    let(:value_field) { :name }

    context 'when id_field matches the value_field' do
      let(:id_field) { value_field }
      let(:data_class) { Struct.new(id_field) }
      let(:values) { [data_class.new('Apples'), data_class.new('Pears')] }
      let(:value) { 'Apples' }

      it 'sets the data variables' do
        helper.suggestion_select(form, field, values, id_field, value_field)

        expect(form).to have_received(:govuk_collection_select) do |f, _vals, id_f, value_f, data:|
          expect(f).to eq(field)
          expect(id_f).to eq(id_field)
          expect(value_f).to eq(value_field)
          expect(data).to eq(
            module: 'accessible-autocomplete',
            name: 'fruit_container_form[fruit_suggestion]',
          )
        end
      end

      context 'when value is not already in the array of options' do
        let(:value) { 'Bananas' }

        it 'adds the value to the array of options' do
          helper.suggestion_select(form, field, values, id_field, value_field)

          expect(form).to have_received(:govuk_collection_select) do |_f, vals, _id_f, _value_f, **_kwargs|
            expect(vals.map(&:to_h)).to eq(
              [
                { name: 'Bananas' },
                { name: 'Apples' },
                { name: 'Pears' },
              ]
            )
          end
        end
      end

      context 'when value is already in the array of options' do
        it 'does not update the array of options' do
          helper.suggestion_select(form, field, values, id_field, value_field)

          expect(form).to have_received(:govuk_collection_select) do |_f, vals, _id_f, _value_f, **_kwargs|
            expect(vals.map(&:to_h)).to eq(
              [
                { name: 'Apples' },
                { name: 'Pears' },
              ]
            )
          end
        end
      end
    end

    context 'when id_field does not match the value_field' do
      let(:id_field) { :id }
      let(:data_class) { Struct.new(id_field, value_field) }
      let(:values) { [data_class.new('app', 'Apples'), data_class.new('pea', 'Pears')] }
      let(:value) { 'app' }

      it 'sets the data variables' do
        helper.suggestion_select(form, field, values, id_field, value_field)

        expect(form).to have_received(:govuk_collection_select) do |f, _vals, id_f, value_f, data:|
          expect(f).to eq(field)
          expect(id_f).to eq(id_field)
          expect(value_f).to eq(value_field)
          expect(data).to eq(
            module: 'accessible-autocomplete',
            name: 'fruit_container_form[fruit_suggestion]',
          )
        end
      end

      context 'when value is not already in the array of options' do
        let(:value) { 'Bananas' }

        it 'adds the value to the array of options' do
          helper.suggestion_select(form, field, values, id_field, value_field)

          expect(form).to have_received(:govuk_collection_select) do |_f, vals, _id_f, _value_f, **_kwargs|
            expect(vals.map(&:to_h)).to eq(
              [
                { id: 'Bananas', name: 'Bananas' },
                { id: 'app', name: 'Apples' },
                { id: 'pea', name: 'Pears' },
              ]
            )
          end
        end
      end

      context 'when value is already in the array of options' do
        it 'does not update the array of options' do
          helper.suggestion_select(form, field, values, id_field, value_field)

          expect(form).to have_received(:govuk_collection_select) do |_f, vals, _id_f, _value_f, **_kwargs|
            expect(vals.map(&:to_h)).to eq(
              [
                { id: 'app', name: 'Apples' },
                { id: 'pea', name: 'Pears' },
              ]
            )
          end
        end
      end
    end
  end
end
