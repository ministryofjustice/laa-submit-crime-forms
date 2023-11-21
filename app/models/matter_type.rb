MatterType = Struct.new(:id, :description) do
  # rubocop:disable Metrics/MethodLength
  def self.all
    @all ||= [
      new('1', 'Offences against the person'),
      new('2', 'Homicide and related grave offences'),
      new('3', 'Sexual offences and associated offences against children'),
      new('4', 'Robbery'),
      new('5', 'Burglary'),
      new('6', 'Criminal damage'),
      new('7', 'Theft (including taking vehicle without consent)'),
      new('8', 'Fraud and forgery and other offences of dishonesty not otherwise categorised'),
      new('9', 'Public order offences'),
      new('10', 'Drug offences'),
      new('11', 'Driving and motor vehicle offences (other than those covered by codes 1, 6 & 7)'),
      new('12', 'Other offences'),
      new('13', 'Terrorism'),
      new('14', 'Anti-social behaviour orders (for applications made prior to 23rd March 2015)'),
      new('15', 'Sexual offender orders'),
      new('16', 'Other prescribed proceedings'),
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def self.description_by_id(matter_id)
    @all.find { |item| item.id == matter_id }.description
  end

  def name
    "#{id} - #{description}"
  end
end
