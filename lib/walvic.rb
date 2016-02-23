require 'json'
require 'open-uri'
require 'pi_piper'
require 'dotenv'

Dotenv.load

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
    request = open(url, http_basic_authentication: [
      ENV['SIR_HANDEL_USERNAME'],
      ENV['SIR_HANDEL_PASSWORD']
    ])
    JSON.parse request.read
  end

end
