require 'rubygems'
require 'httparty'
require 'cgi'

module RBDelicious
  

  class HttpClient
    include HTTParty

    def initialize(options={})
      config = YAML::load(File.read(File.join(ENV['HOME'],'.delicious')))
      options.merge!(config)
      self.class.base_uri options['base_uri'] unless options['base_uri'].nil?
      if !options['proxy_host'].nil?
        port = options['proxy_proxy'].nil? ? 80 : options['proxy_port'].to_i
        self.class.http_proxy options['proxy_host'], port
      end
    end
  end

  class DeliciousAPI

    def initialize(u, p, options={})
      @auth = {:username => u, :password => p}
      @hc = HttpClient.new options
    end

    def posts_get(options={})
      # options :query => {...}
      # :tag
      # :dt
      # :url
      mauth(options, @auth)
      @hc.class.get('/posts/get',options)
    end

    def posts_recent(options={})
      # :tag
      # :count
      mauth(options, @auth)
      @hc.class.get('/posts/recent',options)
    end

    private
    def mauth(opts, auth)
      opts.merge!({:basic_auth => auth})
    end
  end

  class DeliciousRss

    def self.dlcs_rss_request(tag = "", popular = 0, user = "", url = "")
      tag = CGI::escape(tag)
      user = CGI::escape(user)
    end
  end
end
