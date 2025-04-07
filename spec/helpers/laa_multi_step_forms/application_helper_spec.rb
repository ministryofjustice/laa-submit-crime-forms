require 'rails_helper'

RSpec.describe LaaMultiStepForms::ApplicationHelper, type: :helper do
  describe '#current_application' do
    it 'raises an error' do
      expect { helper.current_application }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    context 'ignoring layout' do
      before do
        helper.title(value)
      end

      context 'for a blank value' do
        let(:value) { '' }

        it { expect(title).to eq('Submit a crime form - GOV.UK') }
      end

      context 'for a provided value' do
        let(:value) { 'Test page' }

        it { expect(title).to eq('Test page - Submit a crime form - GOV.UK') }
      end
    end

    context 'layout-based titles' do
      let(:lookup_context) { 'context' }
      let(:value) { 'Test page' }

      before do
        allow(helper).to receive(:lookup_context).and_return(lookup_context)
      end

      context 'when current_layout cannot be determined' do
        before do
          allow(helper).to receive_message_chain(:controller, :send).with(:_layout, lookup_context, [], [])
                                                                    .and_raise(NoMethodError)
          helper.title(value)
        end

        it { expect(title).to eq('Test page - Submit a crime form - GOV.UK') }
      end

      context 'when current_layout is nsm' do
        before do
          allow(helper).to receive_message_chain(:controller, :send).with(:_layout, lookup_context, [], [])
                                                                    .and_return('nsm')
          helper.title(value)
        end

        it { expect(title).to eq('Test page - Claim a non-standard magistrates&#39; court payment - GOV.UK') }
      end

      context 'when current_layout is oa' do
        before do
          allow(helper).to receive_message_chain(:controller, :send).with(:_layout, lookup_context, [], [])
                                                                    .and_return('prior_authority')
          helper.title(value)
        end

        it { expect(title).to eq('Test page - Apply for prior authority to incur disbursements - GOV.UK') }
      end
    end
  end

  describe '#fallback_title' do
    before do
      allow(helper).to receive_messages(controller_name: 'my_controller', action_name: 'an_action')

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
    context 'when ENV var "ENV" is set' do
      before do
        allow(ENV).to receive(:fetch).with('ENV', 'local').and_return 'test'
      end

      it 'returns based on ENV var "ENV" variable' do
        expect(helper.app_environment).to eq('app-environment-test')
      end
    end

    context 'when ENV var "ENV" is not set' do
      it 'returns based on local' do
        expect(helper.app_environment).to eq('app-environment-local')
      end
    end
  end

  describe '#phase_name' do
    subject(:phase_name) { helper.phase_name }

    context 'when ENV var "ENV" is production' do
      before do
        allow(ENV).to receive(:fetch).with('ENV', 'local').and_return 'production'
      end

      it 'returns Beta' do
        expect(phase_name).to eql 'Beta'
      end
    end

    context 'when ENV var "ENV" returns something other than production' do
      before do
        allow(ENV).to receive(:fetch).with('ENV', 'local').and_return 'uat'
      end

      it 'returns the ENV var value' do
        expect(phase_name).to eql 'Uat'
      end
    end

    context 'when ENV var "ENV" is not set' do
      it 'returns "local"' do
        expect(phase_name).to eql 'Local'
      end
    end
  end

  describe '#format_period' do
    context 'when period is nil' do
      it { expect(helper.format_period(nil)).to be_nil }
    end

    context 'when period is not nil and short style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62)).to eq('1 hour 2 minutes')
        expect(helper.format_period(1)).to eq('0 hours 1 minute')
        expect(helper.format_period(120)).to eq('2 hours 0 minutes')
      end
    end

    context 'when period is not nil and long style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62, style: :long_html)).to eq('1 hour<br><nobr>2 minutes</nobr>')
        expect(helper.format_period(1, style: :long_html)).to eq('0 hours<br><nobr>1 minute</nobr>')
        expect(helper.format_period(120, style: :long_html)).to eq('2 hours<br><nobr>0 minutes</nobr>')
      end
    end

    context 'when period is not nil and line style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62, style: :line_html)).to eq('<nobr>1 hour 2 minutes</nobr>')
        expect(helper.format_period(1, style: :line_html)).to eq('<nobr>0 hours 1 minute</nobr>')
        expect(helper.format_period(120, style: :line_html)).to eq('<nobr>2 hours 0 minutes</nobr>')
      end
    end

    context 'when period is not nil and minimal style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62, style: :minimal_html)).to eq(
          '1<span class="govuk-visually-hidden"> hour</span>:02<span class="govuk-visually-hidden"> minutes</span>'
        )
        expect(helper.format_period(1, style: :minimal_html)).to eq(
          '0<span class="govuk-visually-hidden"> hours</span>:01<span class="govuk-visually-hidden"> minute</span>'
        )
        expect(helper.format_period(120, style: :minimal_html)).to eq(
          '2<span class="govuk-visually-hidden"> hours</span>:00<span class="govuk-visually-hidden"> minutes</span>'
        )
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

        context 'when the key is a symbol' do
          let(:values) { [data_class.new(:apples, 'Apples'), data_class.new(:pears, 'Pears')] }
          let(:value) { :apples }

          it 'does not update the array of options' do
            helper.suggestion_select(form, field, values, id_field, value_field)

            expect(form).to have_received(:govuk_collection_select) do |_f, vals, _id_f, _value_f, **_kwargs|
              expect(vals.map(&:to_h)).to eq(
                [
                  { id: :apples, name: 'Apples' },
                  { id: :pears, name: 'Pears' },
                ]
              )
            end
          end
        end
      end

      context 'when the value is nil' do
        let(:value) { nil }

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

  describe '#gbp_field_value' do
    context 'when it is given a string' do
      let(:value) { 'invalid value' }

      it 'returns the string' do
        expect(helper.gbp_field_value(value)).to eq(value)
      end
    end

    context 'when it is given a number' do
      let(:value) { 1234.5 }

      it 'returns a nice representation of that number as a monetary value' do
        expect(helper.gbp_field_value(value)).to eq('1,234.50')
      end
    end
  end
end
