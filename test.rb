#!/usr/bin/env ruby
#
require 'em-irc'
require 'logger'
require 'pp'

$channel=ARGV[1]
$channel2=ARGV[2]
$nick=ARGV[0]
$known=['thoto', 'solo', 'endres', 'asdf_', 'maniactwister', 'scirocco', 'sn0wdiver', 'nilsarne', 'mettfabrik','nora','underm|nk','godrin', 'undermink', 'thoto', 'balle', 'bastard', 'maniactwister', 'endres']
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

$talking=true

client = EventMachine::IRC::Client.new do
  host 'irc.freenode.net'
  port '7000'
  realname $nick
  ssl true
  def say(target,what,sayImmediately=false)
    if sayImmediately
      message(target,what)
    else
      EM.add_timer(2) do
        message(target,what) if $talking
      end
    end
  end

  on(:connect) do
    nick($nick)
  end

  on(:nick) do
    join($channel)
    join($channel2)
    puts "on nick"
  #  join('#private', 'key')
  end

  on(:join) do |who,channel,names|  # called after joining a channel
    puts "on join"
    pp who,channel,names
    if who == $nick
      topic(channel, "owned by a bot:)")
    end
    say_hi=['hallo ','hey ','hi ', 'der gute alte ','ah... hi ','willkommen ', 'na... ', 'guten morgen ', 'nabend ', 'ach... et ', 'tag '].sample
    if $known.member?(who) then
      send_data("mode "+ channel + " +o "+ who)
      say(channel, say_hi+who)
    else
      say(channel,"hi")
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
    zeit=['uhrzeit', 'wie spaet', 'wieviel uhr']
    warum=['warum','wieso','weshalb']
    say_why=['nun ja...', 'tja '+ source + ' ...', 'warum nicht?', source + ' warum nicht?', 'einfach so ' + source, 'das wuerdest du wohl gerne wissen, ' + source, 'warum auch nicht ' + source + '?', 'gute frage ', 'das kann ich leider nicht beantworten ' + source].sample
    say_nick= ['hmm?','ja?','was?', source +'... was?', 'ja bitte '+ source + '?', 'huch...', 'oehm...', 'inwiefern ' + source + '?'].sample
    say_ruby= ['ruby ist toll:)','ich bin auch in ruby geschrieben...','ich mag objekte:)','ruby? find ich gut:)', 'OOP FTW', 'hab ich da ruby gehoert, ' + source + '?', 'ruby ist doch super:)'].sample
    say_sup=['gut '+ source + ' danke:)', 'super:)', 'sehr gut... danke ' + source, 'bestens:) danke... dir denn auch ' + source + '?', 'wunderbar ' + source + '. danke der nachfrage:)', 'blendend ' + source + '... danke:)', 'hervorragend:)', 'fantastisch ' + source].sample

    def ma(ar)
      Matcher.new(ar)
    end
    @message = message.downcase
    #pp @message + ' # downcased'
    if target == $nick 
      target = source
    end
    case @message
    when /#{$nick}.*bitte.*([1-9][0-9]*).*(minute|sekunde|stunde).*ruhig/i
      say(source,"ja, is gut",true)
      $talking=false
      time=$1.to_i*({"minuten"=>60,"sekunden"=>1,"stunden"=>3600}[$2])
      say(source,"ich schlafe jetzt #{time} sekunden",true)
      EM.add_timer(time) do
        $talking=true
    end
    when /#{$nick}/i
      case @message
      when /wie sp\xC3\xA4t/i
        say(target,"wir haben " + Time.now.to_s[11,5] + "uhr und " + Time.now.to_s[17,2] + " sekunden, " + source)
      when ma(zeit)
        say(target,"wir haben " + Time.now.to_s[11,5] + "uhr und " + Time.now.to_s[17,2] + " sekunden, " + source)
      when /datum/i
        say(target, Time.now.strftime("%A, %B the %d."))
      when /tag.*heute/i
        say(target, Time.now.strftime("%A..."))
      when ma(warum)
        say(target,say_why)
      when /wie geht/i && /dir/i
        say(target,say_sup)
      when /wie geht\'s/
        say(target,say_sup)
      else
      say(target,say_nick)
      end
    when /ruby/i
      say(target,say_ruby)
    when /chaostal/i
      say(target,"www.chaostal.de")
    when /wo bin ich/i
      say(target,"hier: "+target)
    when /guten morgen/i
      say(target,"guten morgen "+source)
    end
  end
  # callback for all messages sent from IRC server
  on(:parsed) do |hash|
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end

client.run!  # start EventMachine loop
