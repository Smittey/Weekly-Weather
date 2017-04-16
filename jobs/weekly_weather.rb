require "net/http"
require "json"
require "open-uri"
require "geocoder"


# If these are left blank, the script will try to locate you using your IP address
$latitude = ""  # Optional
$longitude = "" # Optional
$location = ""  # Optional

units = "uk"
symbol = "C"    
key = ""        # Required

def ftoc (f)
    c = (f-32)*5/9
end

def setLocationInfo()
    # Get your current public IP address. If this fails for whatever reason (i.e. the site has gone down), manually fill in the variables above or select another service from here http://stackoverflow.com/a/13270734/1295906
    remote_ip = open('http://whatismyip.akamai.com').read
        
    $location = "#{Geocoder.search(remote_ip).first.city},<br>#{Geocoder.search(remote_ip).first.state}"
    $latitude = Geocoder.search(remote_ip).first.latitude
    $longitude = Geocoder.search(remote_ip).first.longitude    
end

if($latitude == "" || $longitude == "" || $location == "")
    setLocationInfo()
end
    
SCHEDULER.every "15m", :first_in => 0 do |job|

    uri = URI("https://api.darksky.net/forecast/#{key}/#{$latitude},#{$longitude}?units=#{units}")
    req = Net::HTTP::Get.new(uri.path)

    # Make request
    res = Net::HTTP.start(
            uri.host, uri.port, 
            :use_ssl => uri.scheme == 'https', 
            :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |https|
      https.request(req)
    end

    response = JSON.parse res.body
    
    currentResults = response["currently"]
    dailyResults  = response["daily"]["data"]
        
    forecasts = []
    
    #Today
    today = {}
    
    if currentResults
        
        currentTemp = symbol == "C" ? "#{ftoc(currentResults["temperature"]).round}°#{symbol}" : "#{currentResults["temperature"].round}°#{symbol}"
        currentlyIcon = currentResults["icon"]
        currentHigh = ftoc(dailyResults[0]["temperatureMax"]).round
        currentLow = ftoc(dailyResults[0]["temperatureMin"]).round
        currentSummary = response["hourly"]["summary"]
        todaysSummary = "High of #{currentHigh} with a low of #{currentLow}. #{currentSummary}"
            
        # Create object for this current day
        today = {
                temp: currentTemp,
                summary:  todaysSummary,
                code: currentlyIcon,
                element: 'currentWeatherIcon',
                location: $location
            }

    end
    
    #Future Days

    if dailyResults

        # Create weather object for the next 5 days
        for day in (1..5) 
        
            day = dailyResults[day]
        
            # Format date as a qualified day i.e. Monday
            time = Time.at(day["time"]).strftime("%A")
            summary = day["summary"]
            
            # Should it be displayed in Celsius? If not, display in Fahrenheit
            if(symbol == "C")
                min = ftoc(day["temperatureMin"])
                max = ftoc(day["temperatureMax"])
            else
                min = day["temperatureMin"]
                max = day["temperatureMax"]
            end
                
            # Create object for the day to send back to the widget
            this_day = {
                high: max.round,
                low:  min.round,
                date: time,
                code: day["icon"],
                text: day["text"], 
                
                element: 'weather-icon'
            }
            forecasts.push(this_day)
        end

        send_event "weeklyweather", { forecasts: forecasts, today: today }
    end


end