# This test file is copied from https://github.com/DFE-Digital/govuk-formbuilder/blob/main/spec/govuk_design_system_formbuilder/builder/date_spec.rb
# With shared example disabled. The idea is that this code will eventually be merged
# back into the formbuilder repo, as which time the shared examples can be re-enabled.


require 'rails_helper'

# Can be removed once merged back in (need to add time_spent and time_spent_required to Person)
class Person
  include ActiveModel::Model
  attr_accessor :name, :time_spent, :time_spent_required

  validates :time_spent, presence: true, if: :time_spent_required
end

describe GOVUKDesignSystemFormBuilder::FormBuilder do
  # include_context 'setup builder'
  let(:assigns) { {} }
  let(:controller) { ActionController::Base.new }
  let(:lookup_context) { ActionView::LookupContext.new(nil) }
  let(:helper) { ActionView::Base.new(lookup_context, assigns, controller) }
  let(:object) { Person.new(name: 'Joey') }
  let(:object_name) { :person }
  let(:builder) { described_class.new(object_name, object, helper, {}) }
  let(:parsed_subject) { Nokogiri::HTML::DocumentFragment.parse(subject) }
  let(:arbitrary_html_content) { builder.tag.p("a wild paragraph has appeared") }
  # end replacement of include_context 'setup builder'

  describe '#period_input_group' do
    let(:method) { :govuk_period_field }
    let(:attribute) { :time_spent }

    let(:fieldset_heading) { 'Writing this test' }
    let(:legend_text) { 'Amount of time spent' }
    let(:hint_text) { 'It is in hours and minutes' }

    let(:minutes_multiparam_attribute) { '2i' }
    let(:hour_multiparam_attribute) { '1i' }
    let(:multiparam_attributes) { [hour_multiparam_attribute, minutes_multiparam_attribute] }

    let(:hour_identifier) { "person_time_spent_#{hour_multiparam_attribute}" }
    let(:minute_identifier) { "person_time_spent_#{minutes_multiparam_attribute}" }

    let(:args) { [method, attribute] }
    subject { builder.send(*args) }

    let(:field_type) { 'input' }
    let(:aria_described_by_target) { 'fieldset' }

    # include_examples 'HTML formatting checks'

    # it_behaves_like 'a field that supports hints'

    # it_behaves_like 'a field that supports errors' do
    #   let(:object) { Person.new(time_spent: Date.today.next_year(5)) }

    #   let(:error_message) { /Your date of birth must be in the past/ }
    #   let(:error_class) { 'govuk-input--error' }
    #   let(:error_identifier) { 'person-born-on-error' }
    # end

    # it_behaves_like 'a field that accepts arbitrary blocks of HTML' do
    #   let(:described_element) { 'fieldset' }

    #   # the block content should be before the hint and date inputs
    #   context 'ordering' do
    #     let(:hint_div_selector) { 'div.govuk-hint' }
    #     let(:block_paragraph_selector) { 'p.block-content' }
    #     let(:govuk_date_selector) { 'div.govuk-date-input' }

    #     let(:paragraph) { 'A descriptive paragraph all about dates' }

    #     subject do
    #       builder.send(*args, legend: { text: legend_text }, hint: { text: hint_text }) do
    #         builder.tag.p(paragraph, class: 'block-content')
    #       end
    #     end

    #     specify 'the block content should be before the hint and the date inputs' do
    #       actual = parsed_subject.css([hint_div_selector, block_paragraph_selector, govuk_date_selector].join(",")).flat_map(&:classes)
    #       expected = %w(block-content govuk-hint govuk-date-input)

    #       expect(actual).to eql(expected)
    #     end
    #   end
    # end

    # it_behaves_like 'a field that supports setting the legend via localisation'
    # it_behaves_like 'a field that supports setting the legend caption via localisation'
    # it_behaves_like 'a field that supports setting the hint via localisation'

    # it_behaves_like 'a field that supports custom branding'
    # it_behaves_like 'a field that contains a customisable form group'

    # it_behaves_like 'a field that supports a fieldset with legend'
    # it_behaves_like 'a field that supports captions on the legend'

    # it_behaves_like 'a date field that accepts a plain ruby object' do
    #   let(:described_element) { ['input', { count: 3 }] }
    # end

    specify 'should output a form group with fieldset, period group and 2 inputs and labels' do
      expect(subject).to have_tag('div', with: { class: 'govuk-form-group' }) do
        with_tag('fieldset', with: { class: 'govuk-fieldset' }) do
          with_tag('div', with: { class: 'govuk-period-input' }) do
            with_tag('input', with: { type: 'text' }, count: 2)
            with_tag('label', count: 2)
          end
        end
      end
    end

    context 'separate period part inputs' do
      specify 'inputs should have the correct labels' do
        expect(subject).to have_tag('div', with: { class: 'govuk-period-input' }) do
          %w(Hours Minutes).each do |label_text|
            with_tag('label', text: label_text)
          end
        end
      end

      specify 'inputs should have the correct name' do
        multiparam_attributes.each do |mpa|
          expect(subject).to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{mpa})]" })
        end
      end

      specify 'inputs should have an inputmode of numeric' do
        expect(subject).to have_tag('input', with: { inputmode: 'numeric' })
      end

      specify 'labels should be associated with inputs' do
        [hour_identifier, minute_identifier].each do |identifier|
          expect(subject).to have_tag('label', with: { for: identifier }, count: 1)
          expect(subject).to have_tag('input', with: { id: identifier }, count: 1)
        end
      end

      specify 'inputs should have the correct classes' do
        expect(subject).to have_tag(
          'input',
          count: 2,
          with: { class: %w(govuk-input govuk-period-input__input) }
        )
      end

      specify 'inputs should have the width class' do
        expect(subject).to have_tag(
          'input',
          count: 2,
          with: { class: %w(govuk-input--width-2) }
        )
      end
    end

    context 'not restricting chars with maxlength' do
      subject { builder.send(*args, maxlength_enabled: false) }

      specify 'there should be a hours maxlength attribute' do
        expect(subject).not_to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{hour_multiparam_attribute})]", maxlength: '2' })
      end

      specify 'there should be a minutes maxlength attribute' do
        expect(subject).not_to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{minutes_multiparam_attribute})]", maxlength: '2' })
      end
    end

    context 'restricting chars with maxlength' do
      subject { builder.send(*args, maxlength_enabled: true) }

      specify 'there should be a hours maxlength attribute' do
        expect(subject).to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{hour_multiparam_attribute})]", maxlength: '2' })
      end

      specify 'there should be a minutes maxlength attribute' do
        expect(subject).to have_tag('input', with: { name: "#{object_name}[#{attribute}(#{minutes_multiparam_attribute})]", maxlength: '2' })
      end
    end

    context 'default values' do
      let(:hours) { 3 }
      let(:minutes) { 2 }

      context "when the attribute is a `TimePeriod::Instance` object" do
        let(:object) do
          Person.new(
            name: 'Joey',
            time_spent: Type::TimePeriod::Instance.new(182)
          )
        end

        specify 'should set the hour value correctly' do
          expect(subject).to have_tag('input', with: {
            id: hour_identifier,
            value: hours
          })
        end

        specify 'should set the minutes value correctly' do
          expect(subject).to have_tag('input', with: {
            id: minute_identifier,
            value: minutes
          })
        end
      end

      context "when the attribute is a multiparameter hash object" do
        let(:object) do
          Person.new(
            name: 'Joey',
            time_spent: { 2 => minutes, 1 => hours }
          )
        end

        specify 'should set the hour value correctly' do
          expect(subject).to have_tag('input', with: {
            id: hour_identifier,
            value: hours
          })
        end

        specify 'should set the minutes value correctly' do
          expect(subject).to have_tag('input', with: {
            id: minute_identifier,
            value: minutes
          })
        end
      end

      # can be removed once shared example are available
      context 'when the object is invalid' do
        let(:object) do
          Person.new(
            name: 'Joey',
            time_spent: nil,
            time_spent_required: true,
          ).tap(&:valid?)
        end

        specify 'should set the hour value correctly via the error link id' do
          expect(subject).to have_tag('input', with: {
            id: 'person-time-spent-field-error',
            name: 'person[time_spent(1i)]'
          })
        end

        specify 'should set the minutes value correctly' do
          expect(subject).to have_tag('input', with: {
            id: minute_identifier,
            name: 'person[time_spent(2i)]'
          })
        end
      end
    end

    describe "additional attributes" do
      subject { builder.send(*args, data: { test: "abc" }) }

      specify "should have additional attributes" do
        expect(subject).to have_tag('div', with: { 'data-test': 'abc' })
      end
    end

    describe "hashes without the right keys" do
      let(:wrong_hash) { { h: 20, m: 3 } }
      before { object.time_spent = wrong_hash }
      before { allow(Rails).to receive_message_chain(:logger, :warn) }
      before { subject }

      specify "logs an appropriate warning" do
        expect(Rails.logger).to have_received(:warn).with(/No key '.*' found in MULTIPARAMETER_KEY hash/).exactly(wrong_hash.length).times
      end

      specify "doesn't generate inputs with values" do
        parsed_subject.css('input').each do |element|
          expect(element.attributes.keys).not_to include('value')
        end
      end
    end

    describe "Invalid object" do
      before { object.time_spent = double }

      it 'should raise an error' do
        expect { subject }.to raise_error("invalid TimePeriod-like object: must be a Time Period or Hash in MULTIPARAMETER_KEY format")
      end
    end


  end
end