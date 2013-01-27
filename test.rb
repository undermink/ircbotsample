#!/usr/bin/env ruby
#
require 'em-irc'
require 'logger'
require 'pp'

$channel=ARGV[1]
$nick=ARGV[0]


client = EventMachine::IRC::Client.new do
  host 'irc.chaostal.de'
  port '6667'



  def say(what)
    message($channel,what)
  end

  on(:connect) do
    nick($nick)
  end

  on(:nick) do
    join($channel)
    puts "on nick"
  #  join('#private', 'key')
  end

  on(:join) do |who,channel,names|  # called after joining a channel
    puts "on join"
    pp who,channel,names
    #message(channel, "hi")
    $names=['godrin', 'undermink', 'thoto', 'balle', 'bastard', 'maniactwister', 'endres']
    case who
    when /#{$names}/i
      say("hi "+ who)
    end
    #EM.add_timer(20,proc {
    #  say Time.now.to_s 
    #})
  end

  on(:message) do |source, target, message|  # called when being messaged
    puts "message: <#{source}> -> <#{target}>: #{message}"
    case message
    when /#{$nick}/i
      $say_nick= ['hmm?','ja?','was?', source+'... was?', 'ja bitte '+source+' ?'].sample
      say($say_nick)
    when /ruby/i
      $say_ruby= ['ruby ist toll:)','ich bin auch in ruby geschrieben...','ich mag objekte:)','ruby? find ich gut:)'].sample
      say($say_ruby)
    when /chaostal/i
      say("www.chaostal.de")
    when /uhrzeit/i
      say Time.now.to_s
    when /datum/i
      say Time.now.to_s
    when /wo bin ich/i
      say(target)
    end
  end

  # callback for all messages sent from IRC server
  on(:parsed) do |hash|
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end

client.run!  # start EventMachine loop
