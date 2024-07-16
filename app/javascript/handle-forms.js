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

    let buttonAction = $(this).attr("name")
    if(buttonAction){
      form.append(`<input type="hidden" name="${buttonAction}" value="" >`)
    }

    form.trigger('submit.rails')
  })
})
