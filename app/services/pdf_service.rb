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
    scale: 0.9,
    launch_args: ['--font-render-hinting=medium', '--no-sandbox', '--force-renderer-accessibility'],
  }.freeze

  class << self
    def prior_authority(locals, url)
      html = generate_html(locals, 'prior_authority/applications/pdf')

      html_to_pdf(html, url)
    end

    def nsm(locals, url)
      html = generate_html(locals, 'nsm/steps/view_claim/pdf')

      html_to_pdf(html, url)
    end

    private

    def generate_html(locals, template)
      ApplicationController.new.render_to_string(
        template: template,
        layout: 'pdf',
        locals: locals,
      )
    end

    def html_to_pdf(html, display_url)
      Grover.new(html, **GROVER_OPTIONS.merge(display_url:)).to_pdf
    end
  end
end
