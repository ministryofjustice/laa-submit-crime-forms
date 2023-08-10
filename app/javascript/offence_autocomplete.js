import accessibleAutocomplete from 'accessible-autocomplete'
import $ from 'jquery'

window.$ = $

async function fetchOffences(){
  try{
    const response = await fetch("/offences")
    const offences = await response.json()
    return offences
  }
  catch{
    return [{type: "", name: "No entries found"}]
  }
}

async function customSuggest(query, syncResults){
  let results = await fetchOffences();
  syncResults(query
    ? results.filter((result) => {
        var resultContains = result.search_value.indexOf(query.toLowerCase()) !== -1
        return resultContains
      })
    : []
  )
}

function inputValueTemplate(result){
  return result?.name
}

function suggestionTemplate(result){
  if(result){
    return `${result.name}<br><span class="autocomplete__caption">${result.type}</span>`
  }
  else{
    return ""
  }
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
