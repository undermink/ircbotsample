#!/usr/bin/env ruby

require 'em-irc'
require 'logger'
require 'pp'
require 'net/http'
require 'rss'
require 'open-uri'
require 'nokogiri'
require './kalender.rb'
require './email.rb'
require './snowman.rb'

$channel=ARGV[1]
$channel2=ARGV[2]
$nick=ARGV[0]
$known=['bspar','int80','jt','ex','nilsarne','step21','fotojunkie','jenni','jenni_','DFens','rinnegan-drache','marc','thoto_','thhunder','thhunder_','elnino86zockt','theftf', 'abiana', 'solo', 'sansor', 'endres', 'asdf_', 'maniactwister', 'scirocco', 'sn0wdiver', 'nilsarne', 'mettfabrik','nora','underm|nk','godrin', 'godrin_',  'undermink', 'thoto', 'balle', 'bastard', 'isaaac','darkhawk']
$opqueque={}
$notice={}
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

  ytapikey = 'PUT IT IN!!!'
  host 'irc.chaostal.de'
  port '6697'
  realname $nick
  ssl true
  def say(target,what,sayImmediately=false) # sprechen
    log = File.new("log.txt","a")
    now = Time.now.strftime("%d.%m. %H:%M:%S")
    log.puts "[#{now}][powerbot@#{target}]: #{what}"
    log.close
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
    join("#devtal")
    puts "on nick"
  #  join('#private', 'key')
  end

  on(:join) do |who,channel,names|  # called after joining a channel
    puts "on join"
    pp who,channel,names
    if channel=="#snow"
      snow=snowman
      0.upto(snow.length) { |i|
        message(channel, snow[i])
        }
    end
    if who == $nick # nur die topic setzen wenn ER den raum betritt
      topic(channel, "owned by a bot:)")
    end
    say_hi=['huhu ', 'ui... ', '*wink* ', 'hallo ','hey ','hi ', 'et gute alte ','ah... hi ','willkommen ', 'na... ', 'guten morgen ', 'nabend ', 'ach... et ', 'tag '].sample
    if $known.member?(who.downcase) then # wenn er dich kennt
      $opqueque[who] ||= {} # Create a sub-hash unless it already exists
      $opqueque[who][channel] ||= channel
      privmsg("nickserv", "acc "+who) # request identification status
      say(channel, say_hi+who)
    else
      say(channel,"hi") # wenn nicht:)
    end
    if $notice.has_key?(who.downcase) then
      $notice[who].each { |bywho,msg| say(who,msg) }
      $notice[who] = {}
      #say(who,$notice[who])
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
#    log = File.new("log.txt","a")
    now = Time.now.strftime("%d.%m.20%y %H:%M:%S")
#    log.puts "[#{now}][#{source}@#{target}]: #{message}"
#    log.close
    zeit=['uhrzeit', 'wie spaet', 'wieviel uhr']
    warum=['warum','wieso','weshalb']
    nacht=['gute nacht','gn8','gute n8']
    hi=['huhu','hey','hallo','tag','tach','moin','guten morgen','servus']
    say_ok=['na gut...','ok','hmm... soll ich?', source + ' echt jetzt?','ok ' + source, 'nein', 'mach doch selber ' + source,'kein bock...','warum solltest Du ' + source + '?','dafuer gibt es keinen anlass ' + source,'jaja...ok','wenn du meinst ' + source].sample
    say_why=['nun ja...', 'tja '+ source + ' ...', 'warum nicht?', source + ' warum nicht?', 'einfach so ' + source, 'das wuerdest du wohl gerne wissen, ' + source, 'warum auch nicht ' + source + '?', 'gute frage ', 'das kann ich leider nicht beantworten ' + source,'nein','ach quatsch...','ich glaub dir kein wort', 'jetzt uebertreibst du aber...','*hust*','noe...'].sample
    say_nick= ['hmm?','ja?','was?', source +'... was?', 'ja bitte '+ source + '?', 'huch...', 'oehm...', 'inwiefern ' + source + '?','*hust*','*zuck*','hae?','...',':)','oeh...','*zitter*','*zusammenzuck*'].sample
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
      'Demokratie ist nichts anderes als das Niederknueppeln des Volkes durch das Volk fuer das Volk...','*hust*','*schwitz*','...ich muss weg','nein',
      'Der Unternehmer ist ein Arbeiter, der im Unternehmergewinn seinen Arbeitslohn verdient, der ihm vom Gewinn bleibt, nachdem ihm die Banken den Zins abgenommen haben ... Insofern bildet der Unternehmergewinn keinen Gegensatz zur Lohnarbeit, sondern nur zum Zins.',
      'Eine wirklich gute Idee erkennt man daran, dass ihre Verwirklichung von vornherein ausgeschlossen erschien.',
      'Niemand ist so hoffnungslos versklavt, wie diejenigen, die faelschlicherweise glauben frei zu sein.',
      'Freedom ist the right to tell the people what they do not want to hear...',
      'Ein Volk, das seine Freiheit fuer Sicherheit opfert, wird am Ende beides verlieren.',
      'Wer Sicherheit der Freiheit vorzieht, ist zu Recht ein Sklave.',
      'Es ist wichtiger, eine Stunde im Monat ueber Geld nachzudenken, als 30 Tage dafuer zu arbeiten.',
      'Verschuettet unter einem Berg von Gesetzen und Verboten, festgezurrt in unsichtbaren wirtschaftlichen Abhaengigkeiten, in einem Arbeitsleben, das in weiten Teilen der Welt das eines Arbeitstiers ist, fast erstickend in einem Sumpf von billigem Tand und Lastern, so lebt heute ein Grossteil Mensch dieser Erde.',
      'Es gibt keinen Weg, den finalen Kollaps eines Booms durch Kreditexpansion zu vermeiden. Die Frage ist nur ob die Krise frueher durch freiwillige Aufgabe der Kreditexpansion kommen soll, oder spaeter zusammen mit einer finalen und totalen Katastrophe des Waehrungssystems kommen soll...',
      'Die Welt hat genug fuer jedermanns Beduerfnisse, aber nicht fuer jedermanns Gier.',
      'Wer in der Demokratie die Wahrheit sagt, wird von der Masse getoetet.',
      'In der Politik geht es nicht darum, Recht zu haben, sondern Recht zu behalten.',
      'In der Politik ist es wie in der Mathematik: alles, was nicht ganz richtig ist, ist falsch.',
      'Ich bin nicht sicher, mit welchen Waffen der dritte Weltkrieg ausgetragen wird, aber im vierten Weltkrieg werden sie mit Stoecken und Steinen kaempfen.',
      'Moderne Kapitalisten sind freundliche Ausbeuter, moderne Sozialisten unfreundliche Austeiler.',
      'Der Mensch, der gar nichts liest, ist besser informiert als derjenige, der nur Zeitung liest.',
      'Um sicher Recht zu tun, braucht man sehr wenig vom Recht zu wissen. Allein um sicher Unrecht zu tun, muss man die Rechte studiert haben.',
      'Wo der Buerger keine Stimme hat, haben die Waende Ohren.',
      'Ich stehe Statistiken etwas skeptisch gegenueber. Denn laut Statistik haben ein Millionaer und ein armer Kerl jeder eine halbe Million.',
      'Gehen Sie in ein Tierheim und bieten an, regelmaessig Hunde auszufuehren.',
      'Gehen Sie in ein Tierheim und bieten an, regelmaessig mit den Katzen dort zu spielen.'].sample
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
      when /wenn.*(marc|jenni|thhunder|rinnegan-drache|jt|int80|bspar|fotojunkie|darkhawk|nilsarne|ex|solo|balle|undermink|thoto|maniactwister|abiana|godrin|nora|endres|thhunder|step21|theftf|sansor).*wiederkommt.*sag/i
  if $known.member?(source.downcase)
    who = $1
    wwho = $known.member?(message.downcase)
    what = @message.gsub(/(.+)\{\{([^\}]+)\}\}.*/,'\2')
    $notice[who] ||= {}
    if $notice[who][source] != nil
      msg = ' und : ' + what
      $notice[who][source] += msg
    else
      msg = 'Ich soll Dir von '+source+' sagen: '+what
      $notice[who][source] = msg
    end
    pp $notice
    pp wwho
    say(target,'klar.. mach ich')
  else
    say(target,'nein :P')
  end
      when /sag.*(marc|jenni|thhunder|nora|simon|david|solo|twister|balle|thoto).*bescheid/i
        if $known.member?(source.downcase)
          who = $1
          mail = @message.gsub(/(.+)\{\{([^\}]+)\}\}.*/,'\2')
          tellsomebody(source,target,who,mail)
          say(target,'schon passiert:)')
        else
          say(target,'hmm...nein:)')
        end
      when /wie.*deine.*email/i
        say(target, 'powerbot@sunnata.de warum fragst du '+source+'?')
      when /wie sp\xC3\xA4t/i
        say(target,"wir haben " + Time.now.to_s[11,5] + "uhr und " + Time.now.to_s[17,2] + " sekunden, " + source)
      when ma(zeit)
        say(target,"wir haben " + Time.now.to_s[11,5] + "uhr und " + Time.now.to_s[17,2] + " sekunden, " + source)
      when /datum/i
        datum=kal
        0.upto(datum.length) { |i|
        say(target, datum[i])
        }
        #say(target, Time.now.strftime("%A, %B the %d. 20%y"))
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
      when /mach.*(mal|schon)/i
        say(target,say_ok)
      when /tierheim/i
  say(target, 'Gehen Sie in ein Tierheim und bieten an, regelmaessig Hnde auszufuehren.')
      when /gib.*mal.*rat/i
  say(target,'Gehen Sie in ein Tierheim und bieten an, regelmaessig Hunde auszufuehren.')
      when /soll.*ich.*/i
  say(target,'ja')
      when /ist.*devtal.*offen.*?/i
       open('http://devtal.de/~thoto/dtst.txt') do |f|
         f.each do |line|
           say(target,"Es sieht so aus als waere das /dev/tal gerade "+line)
   end
       end
      else
        say(target,say_nick)
      end # ende der antworten wenn der nick fällt
    when /ruby/i # antworten auch ohne den nick
      say(target,say_ruby)
#    when /chaostal/i
#      say(target,"www.chaostal.de")
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
#    when /guten morgen/i
#      say(target,"guten morgen "+source)
     when /schnauze/i
      say(target,"nanana "+source)
#    when ma(nacht)
#      if $known.member?(source) then
#        say(target,say_nacht)
#      else
#        say(target,'nacht...')
#      end
    end # ende der antworten ohne nick

  case message
    when /https?:\/\/(?:youtu\.be\/|(?:[a-z]{2,3}\.)?youtube\.com\/watch(?:\?|#\!)v=)([\w-]{11}).*/i
          uid = $1
          url = "https://www.googleapis.com/youtube/v3/videos?id=#{uid}&key=#{ytapikey}&fields=items%28snippet%28title%29%29&part=snippet"
          begin
            json = JSON.parse(Net::HTTP.get_response(URI.parse(url)).body)
            locked = Net::HTTP.get_response(URI.parse("http://gemafuck.s7t.de/?v=#{uid}&r=1")).body.force_encoding("UTF-8")
      say(target, json['items'][0]['snippet']['title'] + (locked == "1" ? ' (Gema locked)' : ''))
            #say(target, YAML::dump(locked)) ''))
      quiet = true
            #say(target, YAML::dump(locked))
          rescue Exception => e
            puts "There was an error: #{e.message}"
            puts "Invalid video it #{uid}"
          end
    end # ende original case
  begin
    urls = @message.split(/\s+/).find_all { |u| u =~ /^https?:\/\// }
    urls.each do |url|
      html = Nokogiri::HTML(open(url))
      if node = html.at_xpath("html/head/title")
  if quiet != true
          say(target,"Title: #{node.text}")
  else
    quiet == false
  end
      end
    end
  rescue
    pp "error while parsing http-title"
  end
end




  # callback for all messages sent from IRC server
  # Change :raw to :parsed when updating em-irc to > 0.0.2 !
  on(:raw) do |hash|
    # search for NOTICE
    if hash[:command] == "NOTICE" then
      params = hash[:params].last.split(" ")
      # op only if user is identified with services and is known
      if $known.member?(params[0].downcase) && params[1].downcase == "acc" && params[2].to_i == 3 then
        if $opqueque.has_key?(params[0])
          $opqueque[params[0]].each do |index, channel|
            send_data("mode "+ channel + " +o "+ params[0])
            $opqueque[params[0]].delete(index)
          end
          $opqueque.delete(params[0])
        end
      end
    elsif hash[:command] == "PING" then
      begin
     #   lastcheck = File.read("./bastard-rss").to_i
      rescue
     #   lastcheck = 0
      end

=begin
      url = 'http://www.chaostal.de/rss'
      open(url) do |rss|
        feed = RSS::Parser.parse(rss)
        lastdate = feed.channel.lastBuildDate.to_i
        if lastdate > lastcheck then
          File.open("./bastard-rss", 'w+') {|f| f.write(lastdate) }
          feed.items.each do |item|
            say("#chaostal", "[Neuer Artikel] #{item.title} - #{item.link}")
          end
        end
      end
=end      
    end
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end

=begin  on(:parsed) do |hash|
    puts "parsed: #{hash[:prefix]} #{hash[:command]} #{hash[:params].join(' ')}"
  end

end
=end

client.run!  # start EventMachine loop
