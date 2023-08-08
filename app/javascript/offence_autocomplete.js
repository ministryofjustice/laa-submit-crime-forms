import accessibleAutocomplete from 'accessible-autocomplete'
import $ from 'jquery'

window.$ = $

async function fetchOffences(){
  const response = await fetch("/offences")
  const offences = await response.json()
  return offences
}

function customSuggestion(offence, offenceType){
  return `<span class="govuk-body">${offence}</span><br><span class="govuk-caption-m">${offenceType}</span>`
}

function getOffenceType(offence, offence_list){
  let offence_filter = offence_list.filter((item) => {
    return item.description == offence
  })
  if(offence_filter.length === 0){
    return false
  }
  else{
    let target_offence = offence_filter[0]
    return target_offence.type
  }
}

document.addEventListener("DOMContentLoaded", () => {
  fetchOffences().then((results) => {
    results.forEach((offence) => {
      let offenceType = getOffenceType(offence.description, results)
      let htmlString = customSuggestion(offence.description, offenceType)
      $("body").append(htmlString)
    })
  })
}, false)