class ListRow
  Defendant = Struct.new(:full_name)
  def initialize(app_store_record)
    @app_store_record = app_store_record
  end

  def id
    @app_store_record['application_id']
  end

  alias to_param id

  def ufn
    @app_store_record['application']['ufn']
  end

  def main_defendant
    defendant_record = @app_store_record['application']['defendants']&.detect { _1['main'] }
    return unless defendant_record

    Defendant.new(defendant_record.slice('first_name', 'last_name').values.join(' '))
  end

  def defendant
    defendant_record = @app_store_record['application']['defendant']
    return unless defendant_record

    Defendant.new(defendant_record.slice('first_name', 'last_name').values.join(' '))
  end

  def office_code
    @app_store_record['application']['office_code']
  end

  def updated_at
    DateTime.parse(@app_store_record['application']['updated_at'])
  end

  def state
    @app_store_record['application_state']
  end
end
