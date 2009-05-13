require 'rubygems'
require 'httparty'

class HttpClient
  include HTTParty
  http_proxy "www-proxy.us.oracle.com", 80
  base_uri "http://feeds.delicious.com/rss"
end

hc = HttpClient.new
puts hc.class.get("/swung")
