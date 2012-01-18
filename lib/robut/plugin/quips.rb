# Stores quotes and replies with a random stored quote.
class Robut::Plugin::Quips
  include Robut::Plugin

  desc "add quip <text> - adds a quip to the quip database"
  match /^add quip (.+)/, :sent_to_me => true do |new_quip|
    if add_quip(new_quip)
      reply "I added the quip to the quip database"
    else
      reply "I didn't add the quip, since it was already added"
    end
  end

  desc "remove quip <text> - removes a quip from the quip database"
  match /^remove quip (.+)/, :sent_to_me => true do |quip|
    if remove_quip(quip)
      reply "I removed the quip from the quip database"
    else
      reply "I couldn't remove the quip, since it wasn't in the quip database"
    end
  end

  desc "quip - returns a random quip"
  match /^quip$/, :sent_to_me => true do
    quip = random_quip
    if quip
      reply quip
    else
      reply "I don't know any quips"
    end
  end

  # The list of quips stored in the quip database
  def quips
    # I'd love to use a set here, but it doesn't serialize right to yaml
    store["quips"] ||= []
  end

  # Adds +quip+ to the quip database
  def add_quip(quip)
    quips << quip unless quips.include?(quip)
  end

  # Removes +quip+ from the quip database
  def remove_quip(quip)
    quips.delete(quip)
  end

  # Returns a random quip
  def random_quip
    quips[rand(quips.length)] unless quips.empty?
  end
end
