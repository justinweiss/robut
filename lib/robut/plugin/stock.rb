begin
  require 'yahoofinance' # require yahoofinance gem
rescue LoadError
  puts "You must install the yahoofinance gem in order to use the Stock plugin"
  raise $!
end

class Robut::Plugin::Stock
  include Robut::Plugin

  desc "stock <symbol> - Returns a stock data from Yahoo Finance"
  match /^stock (.*)/, :sent_to_me => true do |phrase|
    stock_data = get_stock_data(format_stock_symbols(phrase))
    reply format_reply(stock_data)
  end

  private

  def format_reply(stock_data)
    r = []
    stock_data.keys.sort.each do |sym|
      sd = stock_data[sym]
      # "AAPL: -5.502 / -0.9%, bid: 604.37, ask: 604.5, close: 610.0 "

      r << "#{sym}: #{format_number(sd.changePoints)} / #{format_number(sd.changePercent)}%,\tbid: #{sd.bid},\task: #{sd.ask},\tprevious close: #{sd.previousClose}"
    end
    r.join("\n")
  end

  def format_number(n)
    n > 0 ? "+" + n.to_s : n.to_s
  end

  def format_stock_symbols(phrase)
    phrase.downcase.split(/[\s,;]+/).join(',')
  end

  def get_stock_data(symbols)
    YahooFinance::get_quotes(YahooFinance::StandardQuote, symbols)
  end


end