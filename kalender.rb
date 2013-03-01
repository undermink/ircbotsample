#!/usr/bin/env ruby
require 'time'

def kal
# Datum ermitteln
jetzt = Time.new
d = jetzt.day
m = jetzt.month
y = jetzt.year

# Laengen aller Monate
monate = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
# Schaltjahr?
if ((y % 4 == 0) && (y % 100 != 0)) || (y % 400 == 0)
monate[1] = 29
end

# Laenge des aktuellen Monats
mlaenge = monate[m - 1]

# Wochentag des Monatsersten
erster = Time.parse("#{y}/#{m}/01")
wt = erster.wday
# Sonntag => 7 (europ. Woche)
wt = 7 if wt == 0
puts
answer = "--------#{jetzt.strftime("%B")}--------\n"
puts
puts " MO  DI  MI  DO  FR  SA  SO"
answer += " MO  DI  MI  DO  FR  SA  SO\n"
# Leerzeichen von Montag bis Wochentag des Ersten
leer = (wt - 1) * 4
print " " * leer
answer += " " * leer
1.upto(mlaenge) { |tag|
# Wochenwechsel?
  if wt > 7
    wt = 1
    print "\n"
    answer += "\n"
  end
  # Aktueller Tag?
  if tag == d
    printf "[%2d]", tag
    if tag.to_s.length < 2
      t = '[ '+tag.to_s+']'
    else
      t='['+tag.to_s+']'
    end
    answer += t
  else
    printf "%3d ", tag
    if tag.to_s.length < 2
      t= ' '+tag.to_s
    else
    t = tag.to_s
    end
    answer += ' '+t+' '
  end
  wt += 1
}
puts
return answer.split("\n")
end
