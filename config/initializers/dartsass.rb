Rails.application.config.dartsass.build_options << " --quiet-deps"

Rails.application.config.dartsass.builds = {
  'application.scss' => 'application.css',
  'print.scss'       => 'print.css',
  'assess-application.scss' => 'assess-application.css',
  'assess-print.scss'       => 'assess-print.css',
}
