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

async function customSuggest(query, syncResults){
  let results = await fetchOffences()

  syncResults(query
    ? results.filter((result) => {
        var resultContains = result.description.toLowerCase().indexOf(query.toLowerCase()) !== -1
        return resultContains
      })
    : []
  )
}

function inputValueTemplate(result){
  return result?.description
}

function suggestionTemplate(result){
  return result && `${result.description}<br><span class="autocomplete__caption">${result.type}</span>`
}

function initAutocomplete(elementId){
  let elements = $(`#${elementId}`)
  
  if(elements.length > 0){
    let element = elements[0]
    let name = element.getAttribute("data-name")
   
    accessibleAutocomplete.enhanceSelectElement({
      selectElement: element,
      name: name,
      source: customSuggest,
      templates: { 
        inputValue: inputValueTemplate,
        suggestion: suggestionTemplate 
      }
    })
  }
}

function clearUndefinedSuggestions(){
  let autocompleteElement = $(".autocomplete__wrapper")
  if(autocompleteElement){
    let undefinedListItem = autocompleteElement.find("li:contains(undefined)")
    undefinedListItem.remove()
  }
}

$("document").ready(() => {
  offenceElementIds.forEach((elementId) => {
    //enhance offence select tags
    initAutocomplete(elementId)

    //clear undefined options in accessible-autocomplete
    $(`#${elementId}`).on("click focus hover", () => {
      clearUndefinedSuggestions()
    })
  })
})
