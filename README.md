# Weekly Weather Widget
A widget for the Dashing framework to display live weather updates using darksky.net / forecast.io. It will display weather for the current day as well as the next 5 days

![Weekly Weather Widget
](http://i.imgur.com/duOvDK7.png "Weekly Weather Widget")


## Installation Steps



1. You will need to add the following gems to your `Gemfile`: `"json`
2. You need an access token to use darksky's weather API. This can be obtained [here](https://darksky.net/dev/) 
3. Copy `weekly_weather.html`, `weekly_weather.coffee`, and `weekly_weather.scss` into the `/widgets/weekly_weather` directory. Put the `weekly_weather.rb` file in your `/jobs` folder.
4. Copy the additional `font/` and `stylesheets/` assets resources into your `/assets` folder
5. You must edit the following variables in `weekly_weather.rb`:
	
    `key` - Your access token from above

    `$latitude` - The latitude of your current location
    
    `$longitude` - The longitude of your current location
    
    `$location` - The name of your current location

	 Note: You can obtain your lat and lng from [here](http://en.mygeoposition.com/).

## Usage

Place the following code into your `.erb` layout file:

```
<li data-row="1" data-col="1" data-sizex="2" data-sizey="1">
    <div data-id="weeklyweather" data-view="WeeklyWeather"></div>
    <i class="fa fa-cloud fa-2x icon-background"></i>
</li>
```