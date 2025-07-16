require 'test_helper'

class WeatherControllerTest < ActionDispatch::IntegrationTest
  def setup
    @city = "Bangalore"
    @zip = "560001"
    @api_key = ENV["WEATHER_API_KEY"]
    @base_url = ENV["WEATHER_API_URL"]
    @url = "#{@base_url}?q=#{@city}&units=metric&appid=#{@api_key}"
    @zip_url = "#{@base_url}?q=#{@zip}&units=metric&appid=#{@api_key}"

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

  test "should fetch weather and not be cached initially" do
    Rails.cache.clear
    stub_request(:get, @zip_url)
      .to_return(status: 200, body: @mock_response, headers: { 'Content-Type' => 'application/json' })

    get fetch_weather_url, params: { city: @zip }, xhr: true
    assert_response :success
    assert_match "Bangalore", @response.body
    assert_match "Live data from API", @response.body
  end

  test "should fetch weather from cache on second request" do
    Rails.cache.clear

    # First API call - not cached
    stub_request(:get, @zip_url)
      .to_return(status: 200, body: @mock_response, headers: { 'Content-Type' => 'application/json' })

    get fetch_weather_url, params: { city: @zip }, xhr: true
    assert_response :success
    assert_match "Live data from API", @response.body

    # Second call should use cache - no new API stub required
    get fetch_weather_url, params: { city: @zip }, xhr: true
    assert_response :success
    assert_match "Cached data", @response.body
  end

  test "should alert on missing zip input" do
    get fetch_weather_url, params: { city: "" }, xhr: true
    assert_response :success
    assert_match "Please enter a ZIP code", @response.body
  end
end
