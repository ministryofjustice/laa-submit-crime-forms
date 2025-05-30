class PdfService
  GROVER_OPTIONS = {
    cache: true,
    format: 'A4',
    margin: {
      top: '2cm',
      bottom: '2cm',
      left: '1cm',
      right: '1cm',
    },
    viewport: {
      width: 1080,
      height: 1920,
    },
    emulate_media: 'print',
    scale: 0.9,
    launch_args: ['--disable-gpu', '--font-render-hinting=medium', '--no-sandbox', '--force-renderer-accessibility'],
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

    def html_to_pdf(html, display_url)
      Grover.new(html, **GROVER_OPTIONS, display_url:, style_tag_options:).to_pdf
    end

    private

    def generate_html(locals, template)
      ApplicationController.new.render_to_string(
        template: template,
        layout: 'pdf',
        locals: locals,
      )
    end

    def style_tag_options
      [
        content: Rails.root.join('app', 'assets', 'builds', 'application.css').read
      ]
    end
  end
end
