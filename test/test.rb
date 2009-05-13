require '../lib/rbdelicious'
require 'pp'
require 'cgi'

#da = RBDelicious::DeliciousAPI.new("swung","min9xu@n")
#puts da.posts_recent
#puts
#puts da.posts_get(:query => {:tag => 'ruby', :dt => '2007-05-12T08:00:00Z'})
posts=RBDelicious::DeliciousRss.get_popular("ruby")
posts.each do |p|
  pp "#{p.link} - #{p.user}"
end
