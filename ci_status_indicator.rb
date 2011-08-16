#!/usr/bin/env ruby

##
# Really simple interface for talking to arduino through usb.
# Setup usb as a serial interface (FTDI driver).
#
# Currently understands the following states:
# 0x01 - PASSING
# 0x02 - FAILING
# 0x03 - RUNNING
##

require 'rubygems'
require 'serialport'
require 'rss/1.0'
require 'rss/2.0'
require 'open-uri'
require 'net/http'
require 'net/https'
require 'highline'
require 'json'

class CIIndicator

  PASSING = 1.chr
  FAILING = 2.chr
  RUNNING = 3.chr

  DEFAULT_JENKINS_URL = 'http://ci.coshx.com'

  def initialize(username, password, jenkins_url)
    @jenkins_url = jenkins_url
    @username = username
    @password = password
    @sp = SerialPort.new(usb_serial_interface, 9600)
  end

  def usb_serial_interface
    "/dev/" + `ls /dev |grep tty |grep usb`.strip
  end

  def send_status(status)
    @sp.write status
  end

  def passing
    send_status PASSING
  end
  
  def failing
    send_status FAILING
  end

  def running
    send_status RUNNING
  end

  def update_indicator
    json = JSON.parse(`curl -s -H 'Content-Type: application/json' -u #{@username}:#{@password} #{@jenkins_url}/api/json`.strip)
    is_failing = false
    is_running = false

    puts "\nChecking Jenkins Status:"

    json["jobs"].each do |job|
      print job['name'] + ': '
      if job['color'] == 'red'
        puts "FAILING"
        is_failing = true
      elsif job['color'] == 'blue_anime'
        puts "RUNNING"
        is_running = true
      else
        puts "PASSING"
      end
    end

    if is_failing
      failing
    elsif is_running
      running
    else
      passing
    end
  end
end

hl = HighLine.new
url = hl.ask("Jenkins URL: ") { |q| q.default = CIIndicator::DEFAULT_JENKINS_URL }
username = hl.ask("Jenkins Username: ")
password = hl.ask("Jenkins Password: ") { |q| q.echo = false }

ci = CIIndicator.new(username, password, url)
while true
  ci.update_indicator

  sleep 15
end
