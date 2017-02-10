class WebhooksController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def uber
    puts request.env
    Rails.logger.warn(request.env)
  end
end
