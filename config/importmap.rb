# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "file-upload", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin_all_from "app/javascript/controllers", under: "controllers"
pin "govuk-frontend", to: "https://ga.jspm.io/npm:govuk-frontend@4.5.0/govuk-esm/all.mjs"
pin "accessible-autocomplete", to: "https://ga.jspm.io/npm:accessible-autocomplete@2.0.4/dist/accessible-autocomplete.min.js"
pin "@ministryofjustice/frontend", to: "https://ga.jspm.io/npm:@ministryofjustice/frontend@1.8.0/moj/all.js"
pin "jquery", to: "https://ga.jspm.io/npm:jquery@3.7.0/dist/jquery.js"
