# address-forecast
Address Forecast is a simple rails app to demonstrate the use of APIs to fetch and display a localized weather forecast for a given address.

## Run Locally
`rails s`

By default the port is 3000 and when running the main page is viewable at `http://localhost:3000`.  The port can be overriden by setting the PORT environment variable.

The geocode API has an auth parameter defined in the documentation.  Set the value sent for this auth parameter using the GEOCODE_AUTH environment variable, however the API calls appear to be succeeding at the moment even without the auth parameter supplied.

## Running Tests
`rails test`

## Project Status
Given the scope of this project, little work was done in the areas of input validation or error handling.  The API calls were written in a way to reduce possible modes of failure, but with the current design errors will just result in an error page.

## Components

### Home Controller
This controller has an index action that serves the address form, and a forecast action that handles the posted form and displays a generated forecast page

### Geocode Location Service
The geocode location service uses `geocode.xyz` to find a location given an address.  It returns a latitude, longitude, and zip code or will raise an exception.  Repeat requests for the same address are cached for 30 minutes.  The free version of this API has considerable latency - several seconds was typical during development.  For further development I would recommend a paid subscription or possibly an alternate means of finding a location from an address

### Forecast Service
The forecast service uses the `weather.gov` API to get a forecast for a given latitude & longitude.  It does this in 2 stages
1. Find the weather forecast office and grid x & y for a given latitude and longitude.  These values are required to fetch the forecast data
2. Use the grid office, x, and y values to fetch forecast data

NOTE: Forecast data is for a given geographic "grid".  The HomeController is caching this data by zip code for 30 minutes per the spec but this can introduce some variance or inaccuracies where multiple grids exist for a given zip code.