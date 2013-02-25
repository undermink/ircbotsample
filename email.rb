#!/usr/bin/env ruby
require 'mail'

def tellundermink(who,where)
  pp 'sending message to undermink'
  mail = Mail.new do
    from    'powerbot@sunnata.de'
    to      'undermink@chaostal.de'
    subject 'IRC'
    body    'Hi undermink

Hier ist powerbot...
Du sollst bitte mal in den irc kommen.
In den Raum '+where+'
Soll ich Dir von '+who+' sagen...'
  end
  mail.delivery_method :sendmail
  mail.deliver
  pp '...done'
end

def tellnora(who,where)
  pp 'sending message to nora'
  mail = Mail.new do
    from    'powerbot@sunnata.de'
    to      'nora@sunnata.de'
    subject 'IRC'
    body    'Hi Nora

Hier ist powerbot...
Du sollst bitte mal ins irc kommen.
In den Raum '+where+'
Soll ich Dir von '+who+' sagen.'
  end
  mail.delivery_method :sendmail
  mail.deliver
  pp '...done'
end

def tellmettfabrik(who,where)
  pp 'sending message to mettfabrik'
  mail = Mail.new do
    from    'powerbot@sunnata.de'
    to      'mettfabrik@sunnata.de'
    subject 'IRC'
    body    'Hi Simon

Hier ist powerbot...
Du sollst bitte mal ins irc kommen.
In den Raum '+where+'
Soll ich Dir von '+who+' sagen.'
  end
  mail.delivery_method :sendmail
  mail.deliver
  pp '...done'
end

def tellgodrin(who,where)
  pp 'sending message to mettfabrik'
  mail = Mail.new do
    from    'powerbot@sunnata.de'
    to      'david.kamphausen76@googlemail.com'
    subject 'IRC'
    body    'Hi David

Hier ist powerbot...
Du sollst bitte mal ins irc kommen.
In den Raum '+where+'
Soll ich Dir von '+who+' sagen.'
  end
  mail.delivery_method :sendmail
  mail.deliver
  pp '...done'
end