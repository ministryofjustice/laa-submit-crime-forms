module FurtherInformationPresentable
  extend ActiveSupport::Concern

  included do
    attr_reader :further_information, :skip_links, :claim
  end

  def title
    super(date: further_information.requested_at.to_fs(:stamp))
  end

  def row_data
    [
      {
        head_key: 'information_request',
        text: simple_format(further_information.information_requested),
      },
      {
        head_key: 'your_response',
        text: supporting_documents,
      },
    ]
  end

  private

  def supporting_documents
    return render_partial('nsm/steps/view_claim/gdpr_uploaded_files_deleted') if claim.gdpr_documents_deleted

    links = further_information.supporting_documents.map do |document|
      if skip_links
        document.file_name
      else
        govuk_link_to(document.file_name, url_helper.download_path(document))
      end
    end
    response = simple_format(further_information.information_supplied)
    parts = [response] + links.flat_map { [tag.br, _1] }
    safe_join(parts)
  end

  def render_partial(partial_path)
    ApplicationController.render(partial: partial_path)
  end
end
