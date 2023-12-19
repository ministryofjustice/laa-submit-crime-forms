require 'rails_helper'

RSpec.describe Assess::ApplicationHelper, type: :helper do
  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.assess_title(value)
    end

    context 'for a blank value' do
      let(:value) { '' }

      it { expect(title).to eq('Assess a non-standard magistrates’ court payment - GOV.UK') }
    end

    context 'for a provided value' do
      let(:value) { 'Test page' }

      it { expect(title).to eq('Test page - Assess a non-standard magistrates’ court payment - GOV.UK') }
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
      expect(helper).to receive(:assess_title).with('')
      helper.assess_fallback_title
    end

    context 'when consider_all_requests_local is true' do
      it 'raises an exception' do
        allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(true)
        expect { helper.assess_fallback_title }.to raise_error('page title missing: my_controller#an_action')
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

  describe '#format_period' do
    context 'when period is nil' do
      it { expect(helper.format_period(nil)).to be_nil }
    end

    context 'when period is not nil' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62)).to eq('1 Hour 2 Mins')
        expect(helper.format_period(1)).to eq('0 Hours 1 Min')
      end
    end
  end

  describe '#format_in_zone' do
    context 'when date is a string' do
      let(:time) { '2023/10/18 13:08 +0000' }

      context 'when format is passed in' do
        it 'converts string to a DateTime and renders format' do
          expect(helper.format_in_zone(time, format: '%A<br>%d %b %Y<br>%I:%M%P')).to eq(
            'Wednesday<br>18 Oct 2023<br>02:08pm'
          )
        end
      end

      context 'when format is not passed in' do
        it 'converts string to a DateTime and renders as date' do
          expect(helper.format_in_zone(time)).to eq('18 October 2023')
        end
      end
    end

    context 'when date is a time' do
      let(:time) { DateTime.parse('2023/10/17 13:08 +0000') }

      context 'when format is passed in' do
        it 'converts string to a DateTime and renders format' do
          expect(helper.format_in_zone(time, format: '%A<br>%d %b %Y<br>%I:%M%P')).to eq(
            'Tuesday<br>17 Oct 2023<br>02:08pm'
          )
        end
      end

      context 'when format is not passed in' do
        it 'converts string to a DateTime and renders as date' do
          expect(helper.format_in_zone(time)).to eq('17 October 2023')
        end
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
      let(:form_object) { Assess::MakeDecisionForm.new }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object with errors is given' do
      let(:form_object) { Assess::MakeDecisionForm.new }
      let(:title) { helper.content_for(:page_title) }

      before do
        helper.assess_title('A page')
        form_object.errors.add(:base, :blank)
      end

      it 'returns the summary' do
        expect(
          helper.govuk_error_summary(form_object)
        ).to eq(
          '<div class="govuk-error-summary" data-module="govuk-error-summary"><div role="alert">' \
          '<h2 class="govuk-error-summary__title">There is a problem on this page</h2>' \
          '<div class="govuk-error-summary__body"><ul class="govuk-list govuk-error-summary__list">' \
          '<li><a data-turbo="false" href="#assess-make-decision-form-base-field-error">can&#39;t be blank</a></li>' \
          '</ul></div></div></div>'
        )
      end

      it 'prepends the page title with an error hint' do
        helper.govuk_error_summary(form_object)
        expect(title).to start_with('Error: A page')
      end
    end
  end

  describe '#accessed_colour' do
    it 'returns the case based on the state' do
      expect(helper.accessed_colour('granted')).to eq('green')
      expect(helper.accessed_colour('part-grant')).to eq('blue')
      expect(helper.accessed_colour('rejected')).to eq('red')
      expect(helper.accessed_colour('other')).to eq('yellow')
    end
  end
end
