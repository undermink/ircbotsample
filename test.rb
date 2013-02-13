#!/usr/bin/env ruby

require 'em-irc'
require 'logger'
require 'pp'

$channel=ARGV[1]
$channel2=ARGV[2]
$nick=ARGV[0]
$known=['thoto', 'solo', 'Endres', 'asdf_', 'maniactwister', 'scirocco', 'sn0wdiver', 'nilsarne', 'mettfabrik','nora','underm|nk','godrin', 'godrin_', 'Godrin', 'Godrin_', 'undermink', 'thoto', 'balle', 'bastard', 'maniactwister', 'endres']
class Matcher # klasse zum vergleichen
  def initialize(ar)
    @ar=ar
  end

  def ===(other)
    @ar.each{|word|
      if other=~/#{word}/ # wenn die wörter übereinstimmen
        puts "ok #{other} #{word}"
      return true
      end
    }
    false # wenn sie nicht übereinstimmen
  end
end

$talking=true

client = EventMachine::IRC::Client.new do
  host 'irc.freenode.net'
  port '7000'
  realname $nick
  ssl true
  def say(target,what,sayImmediately=false) # sprechen
    if sayImmediately # sprechen auch wenn er still sein soll
      message(target,what)
    else
      EM.add_timer(2) do # 2 sekunden warten bevor er antwortet
        message(target,what) if $talking # und nur wenn talking = true ist
      end
    end
  end

  on(:connect) do
    nick($nick)
  end

  on(:nick) do # die beiden channels betreten wenn der nick vom server akzeptiert wird
    join($channel)
    join($channel2)
    puts "on nick"
  #  join('#private', 'key')
  end

  on(:join) do |who,channel,names|  # called after joining a channel
    puts "on join"
    pp who,channel,names
    if who == $nick # nur die topic setzen wenn ER den raum betritt
      topic(channel, "owned by a bot:)")
    end
    say_hi=['hallo ','hey ','hi ', 'der gute alte ','ah... hi ','willkommen ', 'na... ', 'guten morgen ', 'nabend ', 'ach... et ', 'tag '].sample
    if $known.member?(who) then # wenn er dich kennt
      send_data("mode "+ channel + " +o "+ who)
      say(channel, say_hi+who)
    else
      say(channel,"hi") # wenn nicht:)
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
    nacht=['gute nacht','gn8','gute n8']
    hi=['hi','hallo','tag','tach','moin','guten morgen']
    say_why=['nun ja...', 'tja '+ source + ' ...', 'warum nicht?', source + ' warum nicht?', 'einfach so ' + source, 'das wuerdest du wohl gerne wissen, ' + source, 'warum auch nicht ' + source + '?', 'gute frage ', 'das kann ich leider nicht beantworten ' + source,'nein','ach quatsch...','ich glaub dir kein wort', 'jetzt uebertreibst du aber...','*hust*','noe...'].sample
    say_nick= ['hmm?','ja?','was?', source +'... was?', 'ja bitte '+ source + '?', 'huch...', 'oehm...', 'inwiefern ' + source + '?','*hust*','*zuck*','hae?'].sample
    say_ruby= ['ruby ist toll:)','ich bin auch in ruby geschrieben...','ich mag objekte:)','ruby? find ich gut:)', 'OOP FTW', 'hab ich da ruby gehoert, ' + source + '?', 'ruby ist doch super:)'].sample
    say_sup=['gut '+ source + ' danke:)', 'super:)', 'sehr gut... danke ' + source, 'bestens:) danke... dir denn auch ' + source + '?', 'wunderbar ' + source + '. danke der nachfrage:)', 'blendend ' + source + '... danke:)', 'hervorragend:)', 'fantastisch ' + source].sample
    say_nacht=['gute nacht ' + source,'nacht ' + source,'schlaf gut ' + source,'tschuss ' + source,'tschoe ' + source,source + ' bis dann...','auf bald ' + source, 'moege die macht mit dir sein ' + source, 'auf wiedersehen ' + source].sample
    say_hi=['hehe...', 'hi ' + source, source + '...', 'hallo ' +  source, 'und...? alles fit ' + source, 'tach ' + source, 'einen wunderschoenen guten morgen ' + source, 'fisch *kicher*', 'moin ' + source].sample
    say_clever=['Die Schwaermerei fuer die Natur kommt von der Unbewohnbarkeit der Staedte.',
      'Der Faschismus sollte Korporatismus heissen, weil er die perfekte Verschmelzung der Macht von Regierung und Konzernen ist.',
      'Wenn die Leute das gegenwaertige Bank- und Geldsystem verstuenden, wuerde es vermutlich eine Revolution noch vor morgen frueh geben.',
      'Das Geld ist fuer den Tausch entstanden, der Zins aber weist ihm die Bestimmung an, sich durch sich selbst zu vermehren. Daher widerstreitet auch diese Erwerbsweise unter allen am weitesten dem Naturrecht.',
      'Keiner weiss so viel wie wir alle zusammen.',
      'Together the ants conquer the elephant.',
      'Wo die Zivilcourage keine Heimat hat, reicht die Freiheit nicht weit.',
      'Ich habe bisweilen den Eindruck, dass sich die meisten Politiker immer noch nicht darueber im Klaren sind, wie sehr sie bereits heute unter der Kontrolle der Finanzmaerkte stehen und sogar von diesen beherrscht werden.',
      'Gebt mir die Kontrolle ueber das Geldsystem und mir ist es egal, wer die Gesetze schreibt.',
      'Aus 100 Dollar 110 Dollar zu machen ist Arbeit. Aus 100 Millionen Dollar 110 Millionen zu machen, ist unvermeidlich.',
      'Die Schaffung eines Geldes, das sich nicht horten laesst, wuerde zur Bildung von Eigentum in wesentlicherer Form fuehren.',
      'Demokratie ist nichts anderes als das Nieder- knueppeln des Volkes durch das Volk fuer das Volk...','*hust*','*schwitz*','...ich muss weg','nein'].sample
    say_noprob=['kein thema '+source,'gerne '+source,'bitte '+source,'kein problem '+source,'null problemo...','ist doch selbstverstaendlich:)','nichts zu danken '+source,'selbstverstaendlich '+source].sample

    def ma(ar) # funktion zum vergleichen von wörtern mit der klasse von oben
      Matcher.new(ar)
    end
    @message = message.downcase
    #pp @message + ' # downcased'
    if target == $nick then
    target = source
    end
    case @message

    when /#{$nick}/i  # nur antworten wenn der nick fällt
      case @message
      when /.*bitte.*([1-9][0-9]*).*(minute|sekunde|stunde).*ruhig/i
        say(source,"is ja schon gut...",true)
        $talking=false
        pp $1 +' '+$2+' schlafen...zzzzzZZZZZZ'
        time=$1.to_i*({"minute"=>60,"sekunde"=>1,"stunde"=>3600}[$2])
        say(source,"dann schlafe ich jetzt #{time} sekunden",true)
        EM.add_timer(time) do
          $talking=true
        end
      when /wie sp\xC3\xA4t/i
        say(target,"wir haben " + Time.now.to_s[11,5] + "uhr und " + Time.now.to_s[17,2] + " sekunden, " + source)
      when ma(zeit)
        say(target,"wir haben " + Time.now.to_s[11,5] + "uhr und " + Time.now.to_s[17,2] + " sekunden, " + source)
      when /datum/i
        say(target, Time.now.strftime("%A, %B the %d. 20%y"))
      when /tag.*heute/i
        say(target, Time.now.strftime("%A..."))
      when /sag.*was.*schlaues/i
        say(target,say_clever)
      when ma(warum)
        say(target,say_why)
      when /wie geht/i && /dir/i
        say(target,say_sup)
      when /wie geht\'s/
        say(target,say_sup)
      when ma(nacht)
        if $known.member?(source) then
          say(target,say_nacht)
        else
          say(target,'nacht...')
        end 
      when ma(hi)
        say(target,say_hi)
      when /danke/i
        say(target,say_noprob)
      else
      say(target,say_nick)
      end # ende der antworten wenn der nick fällt
    when /ruby/i # antworten auch ohne den nick
      say(target,say_ruby)
    when /chaostal/i
      say(target,"www.chaostal.de")
    when /wo bin ich/i
      say(target,"hier: "+target+', '+source)
    when /wer bin ich/i
      say(target, "Du bist " + source)
    when /leck mich/i
      say(target,source + "... benimm Dich!")
    when /\*ruelps\*/i
      say(target, "schulz...")
    when /hoerst du das auch/i
      say(target, "ich hoer nichts " + source)
    when /ich glaub dein gen ist defekt/i
      say(target, "ich hab keine gene " + source)
    when /guten morgen/i
      say(target,"guten morgen "+source)
    when ma(nacht)
      if $known.member?(source) then
        say(target,say_nacht)
      else
        say(target,'nacht...')
      end
    end # ende der antworten ohne nick
  end
  # callback for all messages sent from IRC server
  on(:parsed) do |hash|
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end

client.run!  # start EventMachine loop
