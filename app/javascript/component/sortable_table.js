import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'

window.$ = $

$(document).on('turbo:load', function () {
  MOJFrontend.initAll()
});
