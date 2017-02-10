class WebhooksController < ApplicationController
  def uber
    Rails.logger.warn(request.env)
  end
end
