RSpec.shared_examples 'safe per-item quote validations' do
  let(:service_type) { 'photocopying' }
  let(:items) { '1' }
  let(:cost_per_item) { '10' }
  let(:period) { nil }
  let(:cost_per_hour) { nil }
  let(:user_chosen_cost_type) { nil }

  def expect_single_validation_error(attribute, expected_error, expected_message)
    expect(form).not_to be_valid
    expect(form.errors.details.fetch(attribute).map { |detail| detail.fetch(:error) }).to eq([expected_error])

    messages = nil
    expect { messages = form.errors.full_messages }.not_to raise_error
    expect(messages.join(' ')).to include(expected_message)
  end

  context 'when items is nil' do
    let(:items) { nil }

    it 'uses an item-aware blank message' do
      expect_single_validation_error(:items, :blank, 'Enter the number of pages')
    end
  end

  context 'when items is blank' do
    let(:items) { '' }

    it 'uses an item-aware blank message' do
      expect_single_validation_error(:items, :blank, 'Enter the number of pages')
    end
  end

  context 'when items is an alpha string' do
    let(:items) { 'abc' }

    it 'uses an item-aware number message only' do
      expect_single_validation_error(:items, :not_a_number, 'The number of pages must be a number, like 25')
    end
  end

  context 'when items is a decimal string' do
    let(:items) { '205.70' }

    it 'uses an item-aware whole-number message only' do
      expect_single_validation_error(:items, :not_a_whole_number,
                                     'The number of pages must be a whole number, like 25')
    end
  end

  context 'when items is zero' do
    let(:items) { '0' }

    it 'uses an item-aware greater-than message only' do
      expect_single_validation_error(:items, :greater_than, 'The number of pages must be more than 0')
    end
  end

  context 'when items is negative' do
    let(:items) { '-1' }

    it 'uses an item-aware greater-than message only' do
      expect_single_validation_error(:items, :greater_than, 'The number of pages must be more than 0')
    end
  end

  context 'when items exceeds the integer limit' do
    let(:items) { (NumericLimits::MAX_INTEGER + 1).to_s }

    it 'uses an item-aware limit message only' do
      expect_single_validation_error(:items, :less_than_or_equal_to,
                                     "The number of pages must be #{NumericLimits::MAX_INTEGER} or less")
    end
  end

  context 'when cost_per_item is nil' do
    let(:cost_per_item) { nil }

    it 'uses an item-aware blank message' do
      expect_single_validation_error(:cost_per_item, :blank, 'Enter the cost per page')
    end
  end

  context 'when cost_per_item is blank' do
    let(:cost_per_item) { '' }

    it 'uses an item-aware blank message' do
      expect_single_validation_error(:cost_per_item, :blank, 'Enter the cost per page')
    end
  end

  context 'when cost_per_item is an alpha string' do
    let(:cost_per_item) { 'abc' }

    it 'uses an item-aware number message only' do
      expect_single_validation_error(:cost_per_item, :not_a_number, 'The cost per page must be a number, like 25')
    end
  end

  context 'when cost_per_item is zero' do
    let(:cost_per_item) { '0' }

    it 'uses an item-aware greater-than message only' do
      expect_single_validation_error(:cost_per_item, :greater_than, 'The cost per page must be more than 0')
    end
  end

  context 'when cost_per_item is negative' do
    let(:cost_per_item) { '-1' }

    it 'uses an item-aware greater-than message only' do
      expect_single_validation_error(:cost_per_item, :greater_than, 'The cost per page must be more than 0')
    end
  end

  context 'when cost_per_item exceeds the float limit' do
    let(:cost_per_item) { (NumericLimits::MAX_FLOAT + 1).to_s }

    it 'uses an item-aware limit message only' do
      expect_single_validation_error(:cost_per_item, :less_than_or_equal_to,
                                     "The cost per page must be #{NumericLimits::MAX_FLOAT} or less")
    end
  end

  context 'when per-item values are valid' do
    let(:items) { '5' }
    let(:cost_per_item) { '10.50' }

    it 'accepts the form' do
      expect(form).to be_valid
    end
  end
end
