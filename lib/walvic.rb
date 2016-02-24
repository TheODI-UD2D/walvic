require 'json'
require 'yaml'
require 'open-uri'
require 'pi_piper'
require 'dotenv'

Dotenv.load

class Walvic

  PINS = YAML.load_file 'config/pins.yaml'

  def initialize station, direction, time: nil
    @station, @direction = station, direction
    unless time
      time = Time.now.strftime('%H:%M')
    end
    @datetime = "2015-09-23T#{time}:00"
    puts "Showing #{@station} #{@direction} at #{time}"
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
    loads = json.first.last.values
    loads.inject{ |sum, el| sum + el }.to_f / loads.size
  end

  def setup_lights
    PINS.each_with_index do |v, i|
      instance_variable_set("@pin_#{i}", PiPiper::Pin.new(pin: v, direction: :out))
    end
  end

  def illuminate
    (0..Walvic.num_lights(average_occupancy)).each do |i|
      instance_variable_get("@pin_#{i}").on
      sleep 0.2
    end
    sleep 2
    (Walvic.num_lights(average_occupancy)).downto(0).each do |i|
      instance_variable_get("@pin_#{i}").off
      sleep 0.2
    end
  end

  def self.num_lights average, leds = PINS.count
    return (leds * (average / 100.0)).round
  end
end
