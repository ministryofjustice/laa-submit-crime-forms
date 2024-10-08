class AddSearchFields < ActiveRecord::Migration[7.2]
  def change
    defendant_vector = <<~VECTOR
      to_tsvector('simple', coalesce(("defendants"."first_name")::text, '')) || \
      to_tsvector('simple', coalesce(("defendants"."last_name")::text, ''))
    VECTOR

    reference_vector = <<~VECTOR
      to_tsvector('simple', coalesce(("laa_reference")::text, '')) || \
      to_tsvector('simple', coalesce(("ufn")::text, ''))
    VECTOR

    add_column(
      :defendants,
      :search_fields,
      :virtual,
      as: defendant_vector,
      type: :tsvector,
      stored: true
    )

    add_column(
      :claims,
      :core_search_fields,
      :virtual,
      as: reference_vector,
      type: :tsvector,
      stored: true
    )

    add_column(
      :prior_authority_applications,
      :core_search_fields,
      :virtual,
      as: reference_vector,
      type: :tsvector,
      stored: true
    )

    add_index(:defendants, :search_fields, using: 'gin')
    add_index(:claims, :core_search_fields, using: 'gin')
    add_index(:prior_authority_applications, :core_search_fields, using: 'gin')
  end
end
