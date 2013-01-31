#!/usr/bin/env ruby
#
require 'em-irc'
require 'logger'
require 'pp'

$channel=ARGV[1]
$nick=ARGV[0]
$known=['underm|nk','godrin', 'undermink', 'thoto', 'balle', 'bastard', 'maniactwister', 'endres']
class Matcher
  def initialize(ar)
    @ar=ar
  end

  def ===(other)
    @ar.each{|word| 
      if other=~/#{word}/
        puts "ok #{other} #{word}"
        return true
      end
      }
    false
  end
end

client = EventMachine::IRC::Client.new do
  host 'irc.chaostal.de'
  port '9999'
  realname $nick
  ssl true
  def say(what)
    sleep 2
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
    topic($channel, "owned by a bot:)")

    say_hi=['hallo ','hey ','hi ', 'der gute alte ','ah... hi ','willkommen '].sample
    if $known.member?(who) then
      say(say_hi+who)
    else
      say("hi")
    end
  #case who
  #when / #{$known}/i
  #  say("hi "+ who)
  #end
  #EM.add_timer(20,proc {
  #  say Time.now.to_s
  #})
  end

  on(:message) do |source, target, message|  # called when being messaged
    puts "message: <#{source}> -> <#{target}>: #{message}"
    zeit=[' uhrzeit', 'wie spaet', 'wieviel uhr']
    warum=['warum','wieso','\?']
    say_why=['nun ja...', 'tja '+source, 'warum nicht?', source+' warum nicht?', 'einfach so '+source, 'das wuerdest du wohl gerne wissen '+source].sample
    say_nick= ['hmm?','ja?','was?', source+'... was?', 'ja bitte '+source+' ?'].sample
    say_ruby= ['ruby ist toll:)','ich bin auch in ruby geschrieben...','ich mag objekte:)','ruby? find ich gut:)'].sample

    def ma(ar)
      Matcher.new(ar)
    end
    case message.downcase
    when /#{$nick}/i
      case message.downcase
      when ma(zeit)
        say Time.now.to_s
      when ma(warum)
        say(say_why)
      else
      say(say_nick)
      end
    when /ruby/i
      say(say_ruby)
    when /chaostal/i
      say("www.chaostal.de")
    when /wo bin ich/i
      say("hier: "+target)
    when /guten morgen/i
      say("guten morgen "+source)
    end
  end
  # callback for all messages sent from IRC server
  on(:parsed) do |hash|
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end

client.run!  # start EventMachine loop
