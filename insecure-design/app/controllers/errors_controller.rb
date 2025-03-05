class ErrorsController < ApplicationController
  def rate_limited
    render :rate_limited, status: :too_many_requests
  end
end
