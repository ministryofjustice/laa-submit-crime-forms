import accessibleAutocomplete from 'accessible-autocomplete'
import $ from 'jquery'

window.$ = $
const offenceSelect = "steps-case-details-form-main-offence-field"
const offenceSelectError = "steps-case-details-form-main-offence-field-error"
const offenceElementIds = [offenceSelect, offenceSelectError]

async function fetchOffences(){
  const response = await fetch("/offences")
  const offences = await response.json()
  return offences
}

async function customSuggest(query, syncResults, results){
  var results = await fetchOffences()
  if(results){
    syncResults(query
      ? results.filter((result) => {
          var resultContains = result.description.toLowerCase().indexOf(query.toLowerCase()) !== -1
          return resultContains
        })
      : []
    )
  }
}

function inputValueTemplate(result){
  return result && result.description
}

function suggestionTemplate(result){
  return result && `<span class="govuk-body">${result.description}</span><br><span class="govuk-caption-m">${result.type}</span>`
}

function initAutocomplete(elementId){
  let elements = $(`#${elementId}`)
  if(elements.length > 0){
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: elements[0],
      source: customSuggest,
      templates: { 
        inputValue: inputValueTemplate,
        suggestion: suggestionTemplate 
      }
    })
  }
}

$("document").ready(() => {
  offenceElementIds.forEach((elementId) => {
    initAutocomplete(elementId)
  })
})

