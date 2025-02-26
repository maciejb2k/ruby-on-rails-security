class ReportsController < ApplicationController
  REPORTS_DIR = Rails.root.join('downloads', 'reports').freeze

  def index
    @files = Dir.children(REPORTS_DIR).sort
  end

  def unsafe_download
    file = params[:file]
    send_file REPORTS_DIR.join(file)
  end

  def safe_download
    file = params[:file]
    file_path = REPORTS_DIR.join(file)

    is_valid_file = File.exist?(file_path) && File.dirname(file_path) == REPORTS_DIR.to_s

    if is_valid_file
      send_file file_path
    else
      render plain: 'Access Denied', status: :forbidden
    end
  end
end
