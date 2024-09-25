MatterType = Struct.new(:id) do
  def self.all
    @all ||= (1..16).map { new(_1.to_s) }
  end

  def description
    I18n.t("laa_crime_forms_common.nsm.matter_type.#{id}")
  end

  def name
    "#{id} - #{description}"
  end
end
