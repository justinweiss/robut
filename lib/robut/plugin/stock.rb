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
      r << "#{sym}: #{format_number(sd.changePoints)} / #{format_number(sd.changePercent)}%,\tbid: #{pad_number(sd.bid)},\task: #{pad_number(sd.ask)},\tprevious close: #{sd.previousClose}"
    end
    r.join("\n")
  end

  def format_number(n)
    n > 0 ? "+" + pad_number(n) : pad_number(n)
  end

  def pad_number(n)
    sprintf ("%.2f", n)
  end

  def format_stock_symbols(phrase)
    phrase.downcase.split(/[\s,;]+/).join(',')
  end

  def get_stock_data(symbols)
    YahooFinance::get_quotes(YahooFinance::StandardQuote, symbols)
  end


end