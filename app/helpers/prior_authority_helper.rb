module PriorAuthorityHelper
  YES_NO_OPTIONS = [
    [true, I18n.t('prior_authority.generic.yes_choice')],
    [false, I18n.t('prior_authority.generic.no_choice')],
  ].freeze

  def yes_no_options
    YES_NO_OPTIONS
  end
end
