# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
ProviderSolicitor.create!(
  [
    {
      guid: "A09748C6-551D-4E4A-B980-2F85ACC77592",
      reference_number: "Ref1234",
      email: "Michael.Hunt1@justice.gov.uk",
      first_name: "Michael",
      last_name: "Hunt",
      contact_name: "Mike Hunt",
      contact_tel: "07802 329 853"
    }
  ]
)
ProviderOffice.create!(
  [
    {
      guid: "A09748C6-551D-4E4A-B980-2F85ACC77592",
      firm_name: "MiloMia",
      address_line1: "29 Henry Laver Court",
      address_line2: "Balkern Hill",
      town: "Colchester",
      postcode: "CO3 3DQ"
    }
  ]
)

Claim.create!(
  [
    {
      guid: "A09748C6-551D-4E4A-B980-2F85ACC77592",
      usn: "3142",
      account_no: "1",
      provider_no: "1",
      assigned_counsel: true,
      rep_order: "1"
    }
  ]
)
ProviderSolicitor.create!(
  [
    {
      guid: "B09748C6-551D-4E4A-B980-2F85ACC77592",
      email: "Michael.Hunt@justice.gov.uk",
      reference_number: "Ref1234",
      first_name: "Michael",
      last_name: "Hunt",
      contact_name: "Mike Hunt",
      contact_tel: "07802 329 853"
    }
  ]
)
ProviderOffice.create!(
  [
    {
      guid: "B09748C6-551D-4E4A-B980-2F85ACC77592",
      firm_name: "MiloMia",
      address_line1: "29 Henry Laver Court",
      address_line2: "Balkern Hill",
      town: "Colchester",
      postcode: "CO3 3DQ"
    }
  ]
)

Claim.create!(
  [
    {
      guid: "B09748C6-551D-4E4A-B980-2F85ACC77592",
      account_no: "1",
      provider_no: "1",
      assigned_counsel: true,
      rep_order: "1"
    }
  ]
)
