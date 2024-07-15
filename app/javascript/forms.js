import $ from 'jquery'

window.$ = $

$(function() {
  $('form').on("submit", function(e) {
    e.preventDefault();
    let submitButtons = $(this).find('button[type="submit"]')
    submitButtons.each(function(){
      $( this ).attr('disabled', true);
    })
    $( this ).trigger('submit.rails');
  })
})
