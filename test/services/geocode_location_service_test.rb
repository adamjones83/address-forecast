require 'net/http'
require 'test_helper'

class GeocodeLocationServiceTest < ActiveSupport::TestCase
    setup do
        @service = GeocodeLocationService.new
    end

    test 'pulls correct latitude, longitude, and zip code info from geocode response' do
        data = TestHelper::test_json 'geo_response.json'
        response = mock()
        response.expects(:value).returns(nil)
        response.expects(:body).returns(data)
        Net::HTTP.expects(:get_response).returns(response)

        result = @service.location('3079 Whitlow Way, Round Rock, TX 78664')
        assert_equal ({ latitude: '30.53413', longitude: '-97.62642', zip_code: '78664' }), result
    end
end