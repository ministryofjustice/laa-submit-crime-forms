class AddFakeTowns < ActiveRecord::Migration[7.1]
  def change
    # As we are not live yet, this will simply update all our existing test data that's
    # already in a valid state to keep it in a valid state per the new requirements
    # rubocop:disable Rails/SkipsModelValidations
    Quote.where(primary: true).where.not(postcode: nil).update_all(town: 'Faketown')
    # rubocop:enable Rails/SkipsModelValidations
  end
end
