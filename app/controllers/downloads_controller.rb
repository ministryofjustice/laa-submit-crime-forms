class DownloadsController < ApplicationController
  def show
    document = SupportingDocument.find(params[:id])
    return head :forbidden unless current_provider.office_codes.include?(parent(document).office_code)

    download_url = LaaCrimeFormsCommon::S3Files.temporary_download_url(
      S3_BUCKET,
      document.file_path,
      document.file_name
    )
    redirect_to download_url, allow_other_host: true
  end

  private

  def parent(document)
    @parent ||= case document.documentable_type
                when 'Quote'
                  document.documentable.prior_authority_application
                when 'FurtherInformation'
                  document.documentable.submission
                else
                  document.documentable
                end
  end
end
