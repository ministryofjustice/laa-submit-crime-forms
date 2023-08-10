import * as offenceAutocomplete from "../../app/javascript/offence_autocomplete"

describe("fetchOffences", () => {

  test("api call returns nothing", async() => {
    let offences = await offenceAutocomplete.fetchOffences()

    expect(offences[0]).toEqual({name:"No entries found", type: ""})
  })
})

describe("suggestionTemplate", () => {

  test("valid result exists", () => {
    let result = {name: "Offence", type: "Offence Type"}

    let suggestion = offenceAutocomplete.suggestionTemplate(result)
    
    expect(suggestion).toEqual('Offence<br><span class="autocomplete__caption">Offence Type</span>')
  })

  test("invalid result exists", () => {
    let result = {invalid_result: "true"}

    let suggestion = offenceAutocomplete.suggestionTemplate(result)
    
    expect(suggestion).toEqual("")
  })

  test("no result exists", () => {
    let result = null

    let suggestion = offenceAutocomplete.suggestionTemplate(result)
      
    expect(suggestion).toEqual("")
  })
})
