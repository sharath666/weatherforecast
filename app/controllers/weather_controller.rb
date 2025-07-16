class WeatherController < ApplicationController
  require 'net/http'
  require 'json'

  def index
    # landing page 
  end

  # this method will call the weather api
  

  def fetch_weather
    city = params[:city]
    return render js: "alert('Please enter a ZIP code');" if city.blank?
    api_key = ENV['WEATHER_API_KEY']
    base_url = ENV['WEATHER_API_URL']
    url = "#{base_url}?q=#{city}&units=metric&appid=#{api_key}"
    cache_key = "weather_forecast_#{city}"
    @cached = true
    @weather = Rails.cache.fetch(cache_key, expires_in: 30.minutes) do
      @cached = false
      response = HTTParty.get(url)
      JSON.parse(response.body)
    end
    respond_to do |format|
      format.js
    end
  end
end
