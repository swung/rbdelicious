require 'rubygems'
require 'httparty'
require 'cgi'
require 'digest/md5'

module RBDelicious
  

  class HttpClient
    include HTTParty

    def initialize(options={})
      config = YAML::load(File.read(File.join(ENV['HOME'],'.delicious')))
      options.merge!(config) {|k, v1, v2| v1}
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

      hc = HttpClient.new(:base_uri => "http://del.icio.us/rss")

      if url != ""
        url = "/url/#{Digest::MD5.hexdigest(url)}"
      elsif user != "" && tag != ""
        url = "/#{user}/#{tag}"
      elsif user != "" && tag == ""
        url = "/#{user}"
      elsif popular == 0 && tag == ""
        url = "/" 
      elsif popular == 0 && tag != ""
        url = "/tag/#{tag}"
      elsif popular == 1 && tag == ""
        url = "/popular"
      elsif popular == 1 && tag != ""
        url = "/popular/#{tag}"
      else
        url = "/"
      end

      rss = hc.class.get(url)
      posts = Posts.new(rss)
      posts.all
    end

    class Posts
      
      def initialize(rss)
        @rss = rss
        @posts = []
      end

      class Post
        def initialize(rss_item)
          @href = rss_item['href']
          @time = rss_item['time']
          @hash = rss_item['hash']
          @tag = rss_item['tag']
          @description = rss_item['description']
          @extended = rss_item['extended']
        end

        attr_reader :href, :time, :hash, :tag, :desciption, :extended
      end # class Post

      def all
        @rss[:posts][:post].each {|rss_item| @posts << Post.new(rss_itme)}
        @posts
      end
    end # class Posts
  end # class Delicious
end
