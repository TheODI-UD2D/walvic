require 'json'
require 'open-uri'
require 'pi_piper'

class Walvic

  def initialize(station, direction)
    @station, @direction = station, direction
    hour = Time.now.hour
    minute = Time.now.min
    @datetime = "2015-09-23T#{hour}:#{minute}:00"
  end

  def url
    "http://goingunderground.herokuapp.com/stations/arriving/#{@direction}/#{@station}/#{@datetime}.json"
  end

  def json
    JSON.parse open(url).read
  end

end
