require 'net/http'

class ForecastService
    
    # use weather.gov API to fetch forecast data for a given lat/long
    def forecast(latitude, longitude)
        grid = grid_info(latitude, longitude)
        Rails.logger.debug "Grid: #{grid}"
        office, x, y = grid.values_at(:office, :x, :y)
        Rails.logger.debug "Office: #{office}, X: #{x}, Y: #{y}"
        grid_forecast(office, x, y)
    end

    # find the grid info - the office/x/y required by the forecast endpoint
    def grid_info(latitude, longitude)
        # normalize latitude & longitude values
        # - strings with up to 4 decimal digits and no trailing 0s
        lat = /^\-?\d+(?:\.\d{0,3}[1-9])?/.match(latitude.to_s)[0] 
        long = /^\-?\d+(?:\.\d{0,3}[1-9])?/.match(longitude.to_s)[0] 

        # basic validation of the normalized values
        raise 'invalid latitude' if lat.nil? || lat.to_f < -90 || lat.to_f > 90
        raise 'invalid longitude' if long.nil? || long.to_f < -180 || long.to_f > 180

        # eg. 'https://api.weather.gov/points/30.5337,-97.6176' - limited to 4 decimal digits by weather.gov API
        uri = URI("https://api.weather.gov/points/#{lat},#{long}")
        Rails.logger.info "Fetching grid info from '#{uri}'"
        response = Net::HTTP.get_response(uri)
        response.value # raise if unsuccessful
        response_data = JSON.parse(response.body)
        office, x, y = response_data['properties']&.values_at('gridId', 'gridX', 'gridY')

        { office:, x:, y: }
    end

    # get the forecast data and extract the data we care about
    def grid_forecast(office, x, y)
        # eg. 'https://api.weather.gov/gridpoints/EWX/161,102/forecast'
        uri = URI("https://api.weather.gov/gridpoints/#{office}/#{x},#{y}/forecast")
        Rails.logger.info "Fetching forecast data from '#{uri}'"
        response = Net::HTTP.get_response(uri)
        response.value # raise if unsuccessful
        response_data = JSON.parse(response.body)
        
        # convert raw forecast data into an array of { start_time, end_time, temp, desc }
        periods = response_data.dig('properties', 'periods').map do |period|
            start_time, end_time, temp, unit, desc = period.values_at('startTime', 'endTime', 'temperature', 'temperatureUnit', 'shortForecast')
            start_time = Time.zone.iso8601(start_time)
            end_time = Time.zone.iso8601(end_time)
            { start_time:, end_time:, temp: "#{temp} #{unit}", desc: }
        end
        
        now = Time.current # TimeWithZone instance of "now"
        current_period = periods.find { |period| now.between?(period[:start_time], period[:end_time]) }
        
        { current_period:, periods:, fetched_at: now }
    end
end