OutcomeCode = Struct.new(:id) do
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.all
    @all ||= [
      new('CP01'),
      new('CP02'),
      new('CP03'),
      new('CP04'),
      new('CP05'),
      new('CP06'),
      new('CP07'),
      new('CP08'),
      new('CP09'),
      new('CP10'),
      new('CP11'),
      new('CP12'),
      new('CP13'),
      new('CP16'),
      new('CP17'),
      new('CP18'),
      new('CP19'),
      new('CP20'),
      new('CP21'),
      new('CP22'),
      new('CP23'),
      new('CP24'),
    ]
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def description
    I18n.t("laa_crime_forms_common.nsm.hearing_outcome.#{id}")
  end

  def name
    "#{id} - #{description}"
  end
end
