require './rbdelicious'

da = RBDelicious::DeliciousAPI.new("swung","min9xu@n")
#puts da.posts_recent
puts
puts da.posts_get(:query => {:tag => 'ruby', :dt => '2007-05-12T08:00:00Z'})
