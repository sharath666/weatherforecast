require 'test_helper'

class WeatherControllerTest < ActionDispatch::IntegrationTest
  setup do
    @city = "Bangalore"
    @api_key = ENV['WEATHER_API_KEY']
    @base_url = ENV['WEATHER_API_URL']
    @url = "#{@base_url}?q=#{@city}&units=metric&appid=#{@api_key}"

    @mock_response = {
      "weather" => [{ "description" => "clear sky", "icon" => "01d" }],
      "main" => { "temp" => 28.0 },
      "name" => "Bangalore"
    }.to_json

    # WebMock stub for GET request
    stub_request(:get, @url)
      .to_return(status: 200, body: @mock_response, headers: { 'Content-Type' => 'application/json' })
  end

  test "should fetch weather via JS with GET request" do
    get fetch_weather_url, params: { city: @city }, xhr: true

    assert_response :success
    assert_includes @response.body, "Bangalore" if @response.body.present?
  end

  test "should get index page" do
    get weather_index_url
    assert_response :success
  end
end
