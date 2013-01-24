#!/usr/bin/env ruby
#
require 'em-irc'
require 'logger'
require 'pp'

$channel="#devtaltest"

client = EventMachine::IRC::Client.new do
  host 'irc.freenode.net'
  port '6667'


  def say(what)
    message($channel,what)
  end

  on(:connect) do
    nick('jch')
  end

  on(:nick) do
    join($channel)
    puts "on nick"
  #  join('#private', 'key')
  end

  on(:join) do |who,channel,names|  # called after joining a channel
    puts "on join"
    pp who,channel,names
    message(channel, "howdy all")
  #  send_data("hi again test")
    #
    EM.add_timer(20,proc {
      say Time.now.to_s 
    })
  end

  on(:message) do |source, target, message|  # called when being messaged
    puts "message: <#{source}> -> <#{target}>: #{message}"
    case message
    when /jch/i
      say("Was geht ?")
    when /wetter/i
      say("Das Wetter nervt echt !")
    when /heute/i
      say("Man was ist hier heute los ???")
    end
  end

  # callback for all messages sent from IRC server
  on(:parsed) do |hash|
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end

client.run!  # start EventMachine loop
