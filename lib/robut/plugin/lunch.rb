# Where should we go to lunch today?
class Robut::Plugin::Lunch < Robut::Plugin::Base

  def handles?(time, nick, message)
    !!response(time, nick, message)
  end

  def handle(time, nick, message)
    reply(response(time, nick, message, true))
  end
  
  def response(time, nick, message, apply=false)
    words = words(message)    
    phrase = words.join(' ')
    # lunch?
    if phrase =~ /(lunch|food)\?/i
      if places.empty?
        "I don't know about any lunch places"
      else
        places[rand(places.length)] + "!"
      end
    # @robut lunch places
    elsif phrase == "lunch places" && sent_to_me?(message)
      if places.empty?
        "I don't know about any lunch places"
      else
        places.join(', ')
      end
    # @robut new lunch place Green Leaf
    elsif phrase =~ /new lunch place (.*)/i && sent_to_me?(message)
      place = $1
      new_place(place) if apply
      "Ok, I'll add \"#{place}\" to the the list of lunch places"
    # @robut remove luynch place Green Leaf
    elsif phrase =~ /remove lunch place (.*)/i && sent_to_me?(message)
      place = $1
      remove_place(place) if apply
      "I removed \"#{place}\" from the list of lunch places"
    end
  end
  
  def new_place(place)
    store["lunch_places"] ||= []
    store["lunch_places"] = (store["lunch_places"] + Array(place)).uniq
  end
  
  def remove_place(place)
    store["lunch_places"] ||= []
    store["lunch_places"] = store["lunch_places"] - Array(place)
  end
  
  def places
    store["lunch_places"] ||= []
  end
  
  def places=(v)
    store["lunch_places"] = v
  end
  
end
