require 'net/http'

class GeocodeLocationService
    def location(address)
        key = "address:#{address.gsub(/[^A-Za-z0-9]/, '')}"
        Rails.cache.fetch(key, expires_in: 30.minutes) do
            auth = Rails.configuration.GEOCODE_AUTH
            uri = URI('https://geocode.xyz')
            params = {
                'auth' => auth,
                'region' => 'US',
                'locate' => address,
                'geoit' => 'json'
            }
            uri.query = URI.encode_www_form(params)
            Rails.logger.debug "Fetching location data from '#{uri}'"
            response = Net::HTTP.get_response(uri)
            response.value # raise error if unsuccessful
            data = JSON.parse(response.body)
            latitude, longitude = data.values_at('latt', 'longt')
            zip_code = data.dig('standard', 'postal')
            
            { latitude:, longitude:, zip_code: }
        end
    end

    
end