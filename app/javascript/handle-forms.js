import $ from 'jquery'

window.$ = $

$(function() {
  $('button[type="submit"]').on("click", function(e) {
    e.preventDefault()
    let form = $(this).closest("form")
    let formButtons = form.find('button[type="submit"]')
    formButtons.each(function(){
      $(this).attr("disabled", true)
    })

    /*
      this code ensures the button's submission type is appended to params
      so that the BaseStepController still has this available to know
      whether the form should commit_draft/save_and_refresh/reload
    */
    let buttonAction = $(this).attr("name")
    if(buttonAction){
      form.append(`<input type="hidden" name="${buttonAction}" value="" >`)
    }

    form.trigger('submit.rails')
  })
})
