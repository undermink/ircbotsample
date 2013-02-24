#!/usr/bin/env ruby
require 'mail'
require 'pony'

def tellundermink(who)
  pp 'sending message to undermink'
  Pony.mail(:to => 'undermink@chaostal.de', :via => :sendmail, :body => 'powerbot hier\nkomm mal in den irc.\n#{who}')
  #mail = Mail.new do
  #  from    'powerbot@sunnata.de'
  #  to      'undermink@chaostal.de'
  #  subject 'IRC'
  #  body    'Hi\nHier ist powerbot...\nDu sollst bitte mal ins irc kommen.\nSagt #{who}'
  #end
  #mail.delivery_method :sendmail
  #mail.deliver
  pp '...done'
end

def tellnora(who)
  pp 'sending message to nora'
  Mail.deliver do
    from    'powerbot@sunnata.de'
    to      'nora@sunnata.de'
    subject 'IRC'
    body    'Hi\nHier ist powerbot...\nDu sollst bitte mal ins irc kommen.\nSagt #{who}'
  end
  pp '...done'
end

def tellmettfabrik(who)
  pp 'sending message to mettfabrik'
  Mail.deliver do
    from    'powerbot@sunnata.de'
    to      'mettfabrik@sunnata.de'
    subject 'IRC'
    body    'Hi\nHier ist powerbot...\nDu sollst bitte mal ins irc kommen.\nSagt #{who}'
  end
  pp '...done'
end