require_relative 'walvic'
require 'thor'

class CLI < Thor
  desc 'lights', 'Show lights for station and direction'
  method_option :time,
                :type => :string,
                :desc => 'Show lights for time (on 23rd Sept)'

  def lights station, direction
    walvic = Walvic.new station, direction, time: options[:time]
    walvic.illuminate
  end
end
