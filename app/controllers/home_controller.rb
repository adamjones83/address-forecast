require 'time'

class HomeController < ApplicationController
    def index
        # return render :application, nil, status: :ok
        render 'index'
    end

    def forecast
        address = params[:address]
        location_service = ::GeocodeLocationService.new
        forecast_service = ::ForecastService.new
        
        # get location info using a geocode API
        latitude, longitude, zip_code = location_service.location(address)&.values_at(:latitude, :longitude, :zip_code)
        
        # get the forecast using the weather.gov API
        key = "forecast:#{zip_code}"
        data = Rails.cache.fetch(key, expires_in:30.minutes) do
            @fresh_data = true
            forecast_service.forecast(latitude, longitude)
        end
        @current, @periods, @fetched_at = data.values_at(:current_period, :periods, :fetched_at)
        
        # render with @current and @periods data
        render 'forecast'
    end
end