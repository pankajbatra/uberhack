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
      if params[:meta][:status]=='in_progress'
        response_str = RestClient.get 'https://sandbox-api.uber.com/v1.2/requests/current',
                                  {:Authorization => user.token}
        response = JSON.parse(response.to_str,:symbolize_names => true)
        # curl -H 'Authorization: Bearer <TOKEN>'
        # client = Uber::Client.new do |config|
        #   config.server_token  = 'axQczhej2NFXxGQkX2JpwcBKRn0mPgOlGsdcsf2w'
        #   config.client_id     = 'JuhHrgX5zqLavT0mhFzUzdycOmZ3xa6d'
        #   config.client_secret = '3bKwkooaAl9-TOOZI_Kbp-1UwHoiBsD_8vRSkB6w'
        #   config.sandbox       = true
        # end
        # response = client.trip_details params[:meta][:resource_id]
        Rails.logger.warn response_str
        # Rails.logger.warn "Driver: #{response.driver.name} - #{response.driver.phone_number}"
        # Rails.logger.warn "Vehicle: #{response.vehicle.make} - #{response.vehicle.model} - #{response.vehicle.license_plate}"
        # Rails.logger.warn "Location: #{response.location.latitude} - #{response.location.longitude}"
      end
    end

    # {"event_id"=>"45729879-1dbc-4ada-98bc-0d03b09676f3", "resource_href"=>"https://sandbox-api.uber.com/v1/requests/b6d01242-265d-4de2-98c1-5c14116fd6ad",
    #  "meta"=>{"status"=>"in_progress", "user_id"=>"86a76e36-df07-4034-bf1b-b96e4afa6509", "resource_id"=>"b6d01242-265d-4de2-98c1-5c14116fd6ad"},
    #  "event_type"=>"all_trips.status_changed", "event_time"=>1486799913,
    #  "webhook"=>{"event_id"=>"45729879-1dbc-4ada-98bc-0d03b09676f3",
    #  "resource_href"=>"https://sandbox-api.uber.com/v1/requests/b6d01242-265d-4de2-98c1-5c14116fd6ad",
    #  "meta"=>{"status"=>"in_progress", "user_id"=>"86a76e36-df07-4034-bf1b-b96e4afa6509", "resource_id"=>"b6d01242-265d-4de2-98c1-5c14116fd6ad"},
    #  "event_type"=>"all_trips.status_changed", "event_time"=>1486799913}
    # }
  end
end
