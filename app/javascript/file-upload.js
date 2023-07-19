import MOJFrontend from '@ministryofjustice/frontend'
import $ from 'jquery'
window.$ = $

if (typeof MOJFrontend.MultiFileUpload !== "undefined") {
    new MOJFrontend.MultiFileUpload({
        container: $(".moj-multi-file-upload"),
        uploadUrl: window.location.href,
        deleteUrl: window.location.href
    })
}