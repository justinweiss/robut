#
# A plugin filter that blocks users from making too many requests in a row
# 
class Robut::Plugin::SpamFilter
  include Robut::Plugin

  # Time between requests should be limited to 10 seconds
  TIME_BETWEEN_REQUESTS = 10

  #
  # If the request by a sender is made too quickly after the last request
  # we should throttle that user to prevent them from making too many requests.
  # 
  def handle(time, sender_nick, message)

    request_should_be_honored = true

    if sent_to_me?(message)
      request_should_be_honored = !sender_is_making_another_request_too_quickly?(sender_nick)
      store_request_for(sender_nick)
      
      if not request_should_be_honored
        reply "@#{sender_nick} please allow me to help others. I will honor requests again soon."
      end
      
    end
    
    return request_should_be_honored
    
  end

  #
  # @return [TrueClass,FalseClas] true if the request was made too soon after
  #   their last request. false if the request is outside of the time between
  #   the requests.
  def sender_is_making_another_request_too_quickly?(sender_nick)
    seconds_since_last_request(sender_nick) < TIME_BETWEEN_REQUESTS
  end
  
  def seconds_since_last_request(sender_nick)
    Time.now - last_request_by(sender_nick)
  end
  
  #
  # @return [Time] the time the sender made the last request. When no request has
  #   been made for the user this returns time at 0.
  def last_request_by(sender_nick)
    store["spam::filter::#{sender_nick}"] || Time.at(0)
  end

  #
  # Store the current time for the current sender.
  # 
  def store_request_for(sender_nick)
    store["spam::filter::#{sender_nick}"] = Time.now
  end

end
