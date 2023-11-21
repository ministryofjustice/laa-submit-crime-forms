OutcomeCode = Struct.new(:id, :description) do
  # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  def self.all
    @all ||= [
      new('CP01', 'Arrest warrant issued/adjourned indefinitely'),
      new('CP02', 'Change of solicitor'),
      new('CP03', 'Representation order withdrawn'),
      new('CP04', 'Trial: acquitted'),
      new('CP05', 'Trial: mixed verdicts'),
      new('CP06', 'Trial: convicted'),
      new('CP07', 'Discontinued (before any pleas entered)'),
      new('CP08', 'Discontinued (after pleas entered)'),
      new('CP09', 'Guilty plea to all charges put – not listed for trial'),
      new('CP10', 'Guilty plea to all charges put after case listed for trial'),
      new('CP11', 'Guilty plea to substitute charges put – after case listed for trial'),
      new('CP12', 'Mix of guilty plea(s) and discontinuance – Not listed for trial'),
      new('CP13', 'Mix of guilty plea(s) and discontinuance – listed for trial'),
      new('CP16', 'Committal: discharged'),
      new('CP17', 'Extradition'),
      new('CP18', 'Case remitted from Crown to magistrates’ court for sentencing'),
      new('CP19', 'Deferred sentence'),
      new('CP20', 'Granted anti-social behaviour order / sexual offences order / other order'),
      new('CP21', 'Part-granted anti-social behaviour order/ sexual offences order / other order'),
      new('CP22', 'Refused anti-social behaviour order/ sexual offences order / other order'),
      new('CP23', 'Varied anti-social behaviour order/ sexual offences order / other order'),
      new('CP24', 'Discharged anti-social behaviour order/ sexual offences order / other order'),
    ]
  end
  # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

  def self.description_by_id(outcome_id)
    @all.find { |item| item.id == outcome_id }.description
  end

  def name
    "#{id} - #{description}"
  end
end
