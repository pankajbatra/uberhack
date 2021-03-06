class WebhooksController < ApplicationController
  skip_before_filter :verify_authenticity_token
  require 'rest_client'
  def uber
    Rails.logger.warn "Request: #{params.inspect}"
    if params[:meta] && params[:event_type]=='all_trips.status_changed'
      Rails.logger.warn "Trip Status: #{params[:meta][:status]}"
      Rails.logger.warn "User Id: #{params[:meta][:user_id]}"
      Rails.logger.warn "Trip Id: #{params[:meta][:resource_id]}"
      Rails.logger.warn "Time: #{params[:event_time]}"
      user = User.find_by_uid(params[:meta][:user_id])
      Rails.logger.warn "User: #{user.email}"
      if params[:meta][:status]=='in_progress' || params[:meta][:status]=='accepted'
        response_str = RestClient.get 'https://api.uber.com/v1.2/requests/current',
                                  {:Authorization => "Bearer #{user.token}"}
        response = JSON.parse(response_str.to_str,:symbolize_names => true)
        Rails.logger.warn response_str.to_str
        if params[:meta][:status]=='accepted'
          Rails.logger.warn "Driver: #{response[:driver][:name]} - #{response[:driver][:phone_number]}"
          Rails.logger.warn "vehicle: #{response[:vehicle][:make]} - #{response[:vehicle][:model]} - #{response[:vehicle][:license_plate]}"
        end
        Rails.logger.warn "Pickup: #{response[:pickup][:latitude]} - #{response[:pickup][:longitude]}"
        Rails.logger.warn "Destination: #{response[:destination][:latitude]} - #{response[:destination][:longitude]}"
        url = "https://www.zomato.com/index.php?near-me=#{response[:destination][:latitude]},#{response[:destination][:longitude]},1"
        Rails.logger.warn url
        options = {data: {msgType: 'uberUpdate', url: url}, collapse_key: 'misc'}
        send_gcm_notification(options)
      end
    end
  end

  require 'gcm'
  require 'json'
  def send_gcm_notification(options)
    gcm = GCM.new('<GOOGLE_GCM_KEY>')
    response = gcm.send(['661Db4'],
                        options)
    Rails.logger.info "Sent notification with options: #{options}, response: #{response}"
  end
end
