# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
Claim.create!(
  [
    {
      full_name: "Michael Hunt",
      reference: "Mike1234",
      tel_number: "07802 329 853",
      email: "michael.hunt@justice.gov.uk",
      address_line1: "29 Henry Laver Court",
      town: "Colchester",
      post_code: "CO3 3DQ"
    }
  ]
)