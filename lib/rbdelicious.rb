require 'rubygems'
require 'httparty'
require 'cgi'
require 'digest/md5'
require 'pp'
require 'rexml/document'

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

    def self.get_userposts(user)
      dlcs_rss_request("",0,user)
    end

    def self.get_tagposts(tag)
      dlcs_rss_request(tag)
    end

    def self.get_urlposts(url)
      dlcs_rss_request("", 0, "", url)
    end

    def self.get_popular(tag = "")
      dlcs_rss_request(tag,1)
    end

    def self.dlcs_rss_request(tag = "", popular = 0, user = "", url = "")
      tag = CGI::escape(tag)
      user = CGI::escape(user)

      #hc = HttpClient.new(:base_uri => "http://del.icio.us/rss")
      hc = HttpClient.new("base_uri" => "http://feeds.delicious.com/rss")

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
    end # self.dlcs_rss_request

    class Posts
      def initialize(rss)
        @rss = rss
        @posts = []
      end

      class Post
        def initialize(content={})
          post = {"title" => "", "link" => "", "tag" => "", "time" => "", "user" => ""}
          post.merge! content
          @title = post["title"]
          @link = post["link"]
          @tag = post["subject"]
          @time = post["date"]
          @user = post["creator"]
        end

        attr_reader :title, :time, :link, :tag, :user
      end # class Post

      def all
        #@rss[:posts][:post].each {|rss_item| @posts << Post.new(rss_itme)}
        doc = REXML::Document.new @rss
        REXML::XPath.each(doc, '//rdf:RDF/item') do |el|
          content = {}
          el.each_element do |e|
            content[e.name]= e.text
          end
          @posts << Post.new(content)
        end
        @posts
      end
    end # class Posts
  end # class Delicious
end
