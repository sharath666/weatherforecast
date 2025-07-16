class WeatherController < ApplicationController
  require 'net/http'
  require 'json'

  def index
    # landing page 
  end

  # this method will call the weather api
  def fetch_weather

    city = params[:city]
    api_key = ENV['WEATHER_API_KEY']
    base_url = ENV['WEATHER_API_URL']
    url = "#{base_url}?q=#{city}&units=metric&appid=#{api_key}"
    response = HTTParty.get(url)
    
    @weather = response.parsed_response
    respond_to do |format|
      format.js
    end
  end
end
