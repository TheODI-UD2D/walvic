require 'json'
require 'open-uri'
require 'pi_piper'
require 'dotenv'

Dotenv.load

class Walvic

  PINS = [15, 18, 23, 24, 25, 8]

  def initialize(station, direction)
    @station, @direction = station, direction
    hour = Time.now.hour
    minute = Time.now.min
    @datetime = "2015-09-23T#{hour}:#{minute}:00"
    setup_lights
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

  def average_occupancy
    loads = json.first.last
    average = loads.values.inject{ |sum, el| sum + el }.to_f / loads.size
    average.floor
  end

  def num_lights
    ((average_occupancy / 10).floor.to_f / 2).floor
  end

  def setup_lights
    PINS.each_with_index do |v, i|
      instance_variable_set("@pin_#{i}", PiPiper::Pin.new(pin: v, direction: :out))
    end
  end

end
