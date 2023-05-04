require 'net/http'
require 'test_helper'

class ForecastServiceTest < ActiveSupport::TestCase
    setup do
        @service = ForecastService.new
    end
    
    test 'pulls correct grid info from grid response body' do
        # fake the API call with a hardcoded response
        data = TestHelper::test_json('grid_response.json')
        response = mock()
        response.expects(:value).returns(nil)
        response.expects(:body).returns(data)
        Net::HTTP.expects(:get_response).returns(response)

        # verify the correct data & structure of the returned hash
        result = @service.grid_info(7, 7)
        assert_equal ({ office: 'EWX', x:160, y:103 }), result
    end

    test 'pulls correct forecast data from forecast response body' do
        # fake the API call with a hardcoded response
        data = TestHelper::test_json('forecast_response.json')
        response = mock()
        response.expects(:value).returns(nil)
        response.expects(:body).returns(data)
        Net::HTTP.expects(:get_response).returns(response)

        # fake Time.current since it is used to pick the 'current' period from the forecast periods
        fake_now = Time.iso8601('2023-05-02T16:12:00.000Z')
        Time.expects(:current).returns(fake_now)
        result = @service.grid_forecast('EWX', 160, 103)
        
        # verify the structure of the returned hash
        assert_equal ({ start_time: Time.iso8601("2023-05-02T16:00:00.000Z"), end_time: Time.iso8601("2023-05-02T23:00:00.000Z"), temp: "81 F", desc: "Mostly Cloudy" }), result[:current_period]
        assert_equal 14, result[:periods].length
        assert_equal fake_now, result[:fetched_at]
    end
end
