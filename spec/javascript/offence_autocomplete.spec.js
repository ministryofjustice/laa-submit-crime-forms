import { suggestionTemplate } from "../../app/javascript/offence_autocomplete"

describe('suggestionTemplate', () => {

  test('valid result exists', () => {
    let result = {name: "Offence", type: "Offence Type"}

    let suggestion = suggestionTemplate(result)
    
    expect(suggestion).toEqual('Offence<br><span class="autocomplete__caption">Offence Type</span>')
  })

  test('invalid result exists', () => {
    let result = {invalid_result: "true"}

    let suggestion = suggestionTemplate(result)
    
    expect(suggestion).toEqual("")
  })

  test('no result exists', () => {
    let result = null

    let suggestion = suggestionTemplate(result)
      
    expect(suggestion).toEqual("")
  })
})
