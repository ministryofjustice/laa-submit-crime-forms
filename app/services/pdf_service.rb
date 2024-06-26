class PdfService
  GROVER_OPTIONS = {
    format: 'A4',
    margin: {
      top: '2cm',
      bottom: '2cm',
      left: '1cm',
      right: '1cm',
    },
    viewport: {
      width: 2400,
      height: 4800,
    },
    emulate_media: 'print',

    launch_args: ['--font-render-hinting=medium', '--no-sandbox', '--force-renderer-accessibility'],
  }.freeze

  class << self
    def prior_authority(locals, url)
      html = ApplicationController.new.render_to_string(
        template: 'prior_authority/applications/pdf',
        layout: 'pdf',
        locals: locals,
      )

      html_to_pdf(html, url)
    end

    private

    def html_to_pdf(html, display_url)
      Grover.new(html, **GROVER_OPTIONS.merge(display_url:)).to_pdf
    end
  end
end
