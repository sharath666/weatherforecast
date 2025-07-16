require 'test_helper'

class WeatherControllerTest < ActionDispatch::IntegrationTest
  def setup
    @city = "Bangalore"
    @api_key = ENV["WEATHER_API_KEY"]
    @base_url = ENV["WEATHER_API_URL"]
    @url = "#{@base_url}?q=#{@city}&units=metric&appid=#{@api_key}"

    # Mock weather API response
    @mock_response = {
      "weather" => [{ "description" => "clear sky", "icon" => "01d" }],
      "main" => { "temp" => 28.0 },
      "name" => "Bangalore"
    }.to_json

    stub_request(:get, @url)
      .to_return(status: 200, body: @mock_response, headers: { 'Content-Type' => 'application/json' })
  end

  test "should get weather data and render js" do
    get fetch_weather_url, params: { city: @city }, xhr: true

    assert_response :success
    assert_match "Bangalore", @response.body if @response.body.present?
  end

  test "should load index page" do
    get weather_index_url
    assert_response :success
  end
end
