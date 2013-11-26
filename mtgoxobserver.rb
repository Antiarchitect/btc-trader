require 'net/http'
require 'json'
require 'uri'
require_relative 'ticker'
require_relative 'log'

class MtGoxObserver
    class UnsuccessfullResult < StandardError; end
    def self.start
        while true do
            begin
              data = JSON.parse(get('http://data.mtgox.com/api/2/BTCUSD/money/ticker_fast'))
              ticker = Ticker.new Ticker::MtGox
              raise UnsuccessfullResult unless data['result'] == 'success'
              ticker.buy = data['data']['buy']['value']
              ticker.sell = data['data']['sell']['value']
              ticker.last = data['data']['last']['value']

              yield ticker

              sleep Consts::TimeInterval
            rescue
              retry
            end
        end
    end

    private
    def self.get(url)
      uri = URI.parse url
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.request_uri)
      response = http.request(request)
      response.body
    end

end

