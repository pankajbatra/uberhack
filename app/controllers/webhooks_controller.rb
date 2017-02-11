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
        response_str = RestClient.get 'https://sandbox-api.uber.com/v1.2/requests/current',
                                  {:Authorization => "Bearer #{user.token}"}
        response = JSON.parse(response_str.to_str,:symbolize_names => true)
        # curl -H 'Authorization: Bearer <TOKEN>'
        # client = Uber::Client.new do |config|
        #   config.server_token  = 'axQczhej2NFXxGQkX2JpwcBKRn0mPgOlGsdcsf2w'
        #   config.client_id     = 'JuhHrgX5zqLavT0mhFzUzdycOmZ3xa6d'
        #   config.client_secret = '3bKwkooaAl9-TOOZI_Kbp-1UwHoiBsD_8vRSkB6w'
        #   config.sandbox       = true
        # end
        # response = client.trip_details params[:meta][:resource_id]
        Rails.logger.warn response_str.to_str
        Rails.logger.warn "Driver: #{response[:driver][:name]} - #{response[:driver][:phone_number]}"
        Rails.logger.warn "Pickup: #{response[:pickup][:latitude]} - #{response[:pickup][:longitude]}"
        Rails.logger.warn "Destination: #{response[:destination][:latitude]} - #{response[:destination][:longitude]}"
        Rails.logger.warn "vehicle: #{response[:vehicle][:make]} - #{response[:vehicle][:model]} - #{response[:vehicle][:license_plate]}"
        bounds = Geokit::Bounds.from_point_and_radius([response[:destination][:latitude], response[:destination][:longitude]], 5)
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
    gcm = GCM.new('AIzaSyA3Tgz7ndYtDc5GW8JOO9F-Yiuws445CLI')
    response = gcm.send(['APA91bFZlqjbQebOxmMbWgtPY7Q_Y01YbXwaAesYj3KfUJWIqe6_8pbiBRYaBZtn3FUh-abX_ZMWf0zCf2A1Gd7St3b2I1qlAE3Ey9I0kzCY5S1vjoXQAKmzlMgXIRzV0pjNeh661Db4'],
                        options)
    Rails.logger.info "Sent notification with options: #{options}, response: #{response}"
  end
end
