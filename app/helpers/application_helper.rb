module ApplicationHelper
  # moved here to allow view specs to work
  def current_application
    @current_application ||= Claim.find_by(id: params[:id])
  end

  def current_office_code
    @current_office_code ||= current_provider&.selected_office_code || current_provider&.office_codes&.first
  end

  def maat_required?(form)
    form.application.claim_type != ClaimType::NON_STANDARD_MAGISTRATE
  end

  def suggestion_select(form, field, values, id_field, value_field, *args, data: {}, **kwargs)
    values.unshift(fake_record(id_field, value_field, form.object[field]))
    data[:module] = 'accessible-autocomplete'
    data[:name] = "#{form.object_name}[#{field}_suggestion]"

    form.govuk_collection_select(field, values, id_field, value_field, *args, data:, **kwargs)
  end

  private

  def fake_record(id_field, value_field, value)
    if id_field == value_field
      Struct.new(id_field).new(value)
    else
      Struct.new(id_field, value_field).new(value, value)
    end
  end
end
