require 'json'
require 'yaml'
require 'open-uri'
require 'pi_piper'
require 'dotenv'

Dotenv.load

class Walvic

  PINS = YAML.load_file 'config/pins.yaml'
  CONFIG = YAML.load_file 'config/config.yaml'

  def initialize station, direction, time: nil
    @station, @direction = station, direction
    unless time
      time = Time.now.strftime('%H:%M')
    end
    @datetime = "2015-09-23T#{time}:00"
    print "Showing #{@station} #{@direction} at #{time}: "
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
    ave = loads.inject{ |sum, el| sum + el }.to_f / loads.size
    puts "%d%%" % ave
    ave
  end

  def setup_lights
    PINS.each_with_index do |v, i|
      instance_variable_set("@pin_#{i}", PiPiper::Pin.new(pin: v, direction: :out))
    end
  end

  def illuminate
    ave = average_occupancy
    (0...Walvic.num_lights(ave)).each do |i|
      instance_variable_get("@pin_#{i}").on
      sleep CONFIG['interval']
    end
    sleep CONFIG['pause']
    (Walvic.num_lights(ave)).downto(0).each do |i|
      instance_variable_get("@pin_#{i}").off
      sleep CONFIG['interval']
    end
  end

  def self.num_lights average, leds = PINS.count
    return (leds * (average / 100.0)).round
  end
end
