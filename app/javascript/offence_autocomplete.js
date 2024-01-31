import accessibleAutocomplete from 'accessible-autocomplete'
import $ from 'jquery'

window.$ = $

export async function fetchOffences(){
  try{
    const response = await fetch("/non-standard-magistrates/offences")
    const offences = await response.json()
    return offences
  }
  catch{
    return [{type: "", name: "No entries found"}]
  }
}

export async function customSuggest(query, syncResults){
  let results = await fetchOffences();
  syncResults(query
    ? results.filter((result) => {
        var resultContains = result.search_value.indexOf(query.toLowerCase()) !== -1
        return resultContains
      })
    : []
  )
}

export function inputValueTemplate(result){
  return result?.name
}

export function suggestionTemplate(result){
  if(result?.name && result?.type){
    return `${result.name}<br><span class="autocomplete__caption">${result.type}</span>`
  }
  else{
    return ""
  }
}

export function initAutocomplete(elementId){
  let elements = $(`#${elementId}`)
  if(elements.length > 0){
    let element = elements[0]
    let name = element.getAttribute("data-name")
    let autoselect = element.getAttribute('data-autoselect') === "true"

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: element,
      name: name,
      source: customSuggest,
      autoselect: autoselect,
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
  let selectElements = $("*[data-module='offence-autocomplete']")

  selectElements.each((index, element) => {
    let elementId = element.id

    //enhance offence select tags
    initAutocomplete(elementId)

    //clear undefined options in accessible-autocomplete
    $(`#${elementId}`).on("click focus hover", () => {
      clearUndefinedSuggestions()
    })
  })
})
