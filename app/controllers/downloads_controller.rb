class DownloadsController < ApplicationController
  def show
    document = SupportingDocument.find(params[:id])
    download_url = LaaCrimeFormsCommon::S3Files.temporary_download_url(
      S3_BUCKET,
      document.file_path,
      document.file_name
    )
    redirect_to download_url, allow_other_host: true
  end
end
