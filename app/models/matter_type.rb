MatterType = Struct.new(:id) do
  # rubocop:disable Metrics/MethodLength
  def self.all
    @all ||= [
      new('1'),
      new('2'),
      new('3'),
      new('4'),
      new('5'),
      new('6'),
      new('7'),
      new('8'),
      new('9'),
      new('10'),
      new('11'),
      new('12'),
      new('13'),
      new('14'),
      new('15'),
      new('16'),
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def description
    I18n.t("laa_crime_forms_common.nsm.matter_type.#{id}")
  end

  def name
    "#{id} - #{description}"
  end
end
