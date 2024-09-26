OutcomeCode = Struct.new(:id) do
  # rubocop:disable Metrics/MethodLength
  def self.all
    @all ||= %w[
      CP01
      CP02
      CP03
      CP04
      CP05
      CP06
      CP07
      CP08
      CP09
      CP10
      CP11
      CP12
      CP13
      CP16
      CP17
      CP18
      CP19
      CP20
      CP21
      CP22
      CP23
      CP24
    ].map { new(_1) }
  end
  # rubocop:enable Metrics/MethodLength

  def description
    I18n.t("laa_crime_forms_common.nsm.hearing_outcome.#{id}")
  end

  def name
    "#{id} - #{description}"
  end
end
