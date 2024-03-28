require 'rails_helper'

class Person
  include ActiveModel::Model
  attr_accessor :date_of_birth

  validates :date_of_birth, presence: true
end

describe GOVUKDesignSystemFormBuilder::FormBuilder do
  let(:builder) { described_class.new(object_name, object, helper, {}) }
  let(:object_name) { :person }
  let(:object) { Person.new(date_of_birth:) }

  let(:assigns) { {} }
  let(:controller) { ActionController::Base.new }
  let(:lookup_context) { ActionView::LookupContext.new(nil) }
  let(:helper) { ActionView::Base.new(lookup_context, assigns, controller) }

  # let(:parsed_subject) { Nokogiri::HTML::DocumentFragment.parse(subject) }
  # let(:arbitrary_html_content) { builder.tag.p('a wild paragraph has appeared') }

  before { object.valid? }

  describe '#govuk_fully_validatable_date_feld' do
    subject { builder.send(*args) }

    let(:method) { :govuk_fully_validatable_date_field }
    let(:attribute) { :date_of_birth }
    let(:args) { [method, attribute] }

    context 'when date provided is invalid' do
      let(:date_of_birth) { nil }

      it 'constructs appropriate HTML that does not have an `i` in the name or ID key' do
        expect(subject).to have_tag('fieldset', with: { class: 'govuk-fieldset' }) do
          with_tag('div', with: { class: 'govuk-date-input' }) do
            with_tag('div', with: { class: 'govuk-date-input__item' }) do
              with_tag('div', with: { class: 'govuk-form-group' }) do
                with_tag('input',
                         with: { type: 'text', name: 'person[date_of_birth(3)]',
id: 'person-date-of-birth-field-error' })
              end
            end
          end
        end
      end
    end

    context 'when date provided is valid' do
      let(:date_of_birth) { 20.years.ago }

      it 'constructs appropriate HTML that does not have an `i` in the name or ID key' do
        expect(subject).to have_tag('fieldset', with: { class: 'govuk-fieldset' }) do
          with_tag('div', with: { class: 'govuk-date-input' }) do
            with_tag('div', with: { class: 'govuk-date-input__item' }) do
              with_tag('div', with: { class: 'govuk-form-group' }) do
                with_tag('input',
                         with: { type: 'text', name: 'person[date_of_birth(3)]', id: 'person_date_of_birth_3' })
              end
            end
          end
        end
      end
    end
  end
end
