class HomeController < ApplicationController
    def index
        # return render :application, nil, status: :ok
        render 'index'
    end

    def forecast
        @current_temp = 4
        @high_temp = 5
        @low_temp = 3
        render 'forecast'
    end
end