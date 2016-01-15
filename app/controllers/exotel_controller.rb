class ExotelController < ApplicationController
  def book
    mobile = params[:From].split(//).last(10).join
    user = User.find_by(mobile: mobile)


    client = Uber::Client.new do |config|
      config.server_token  = 'AJZ6ZOnp9TnNQuftD6xKM8LhCTahQAlVXDVT-WL-'
      config.client_id     = 'JMNMaGMIvN0kSGGrL3fOf_gOQ8Pvv-Vq'
      config.client_secret = 'TwTkG9a320xk5bzH3IybuucNaB7Vs1sLUt-qC6yc'
      config.bearer_token  = user.token
    end
    request =  client.trip_request ({:start_place_id=>'home'})
    puts request.request_id
    # puts client.products(latitude: 77, longitude: 122)

    # end_point = 'https://api.uber.com/v1/requests'
    # response =  RestClient.post(end_point, {:start_place_id => 'home'},  {'Authorization' => "Token #{user.token}"})
    # puts response

  end
end
