#!/usr/bin/env ruby
require 'mail'

def tellsomebody(fromwho,where,nick,mail)
  pp 'sending message to '+nick
  mail = Mail.new do
    from    'powerbot@sunnata.de'
    case nick
    when /nora/i
      to 'nora@sunnata.de'
    when /david/i
      to 'david.kamphausen76@googlemail.com'
    when /simon/i
      to 'mettfabrik@sunnata.de'
    when /marc/i
      to 'undermink@chaostal.de'
     when /maniactwister/i
      to 'maniactwister@chaostal.de'
    when /balle/i
      to 'balle@chaostal.de'
    when /thoto/i
      to 'thoto@devtal.de'
    end
    subject 'IRC'
    if mail.length > 1
      body "Hi "+nick+"
      
      Hier ist powerbot...
      Ich sollt Dir von "+fromwho+" ausrichten:
      #{mail}
      Den hab ich in "+where+" getroffen:)"
      puts body
    else
    body    'Hi '+nick+'

Hier ist powerbot...
Du sollst bitte mal ins irc kommen.
In den Raum '+where+'
Soll ich Dir von '+fromwho+' sagen.'
    end
  end
  mail.delivery_method :sendmail
  mail.deliver
  pp '...done'
end
