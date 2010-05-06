#
# TESTING SAFECREATIVE LIBRARY
#
require 'logger'
require File.dirname(__FILE__) + '/safe_creative'

# require 'base64'
# 
# str = "a string"
# authStr = Base64.encode64(str)

PRIVATE_KEY = "42eicz8tp2gfy6vvqzz7l1jhe"
SHARED_KEY  = "2qbzy8y4jmfrzztv7b9h405hi"

logger = Logger.new(STDOUT)

sf = SafeCreative.new(SHARED_KEY, PRIVATE_KEY)

ztime = sf.ztime
puts ztime

# authkey_create = sf.authkey_create
# puts authkey_create

# user_link = sf.user_link
# puts user_link

authkey = "5vg3a515cu5vw9vfqt9csn35j"
private_key = "1vm7you8xqs5wwepyd4qy1kz0"
authkey_state = sf.authkey_state(authkey)
puts authkey_state

# work_types = sf.work_types
# puts work_types

# user_licenses = sf.user_licenses(authkey, private_key)
# puts user_licenses

# track_url = "http://s3.amazonaws.com/mp3.stage.thounds.com/thounds/1302/tracks/2175.mp3"
# noncekey = "2u0zt65q6tvvsp3lxgez6mdb7"
# work_register = sf.work_register(authkey, private_key, noncekey, track_url)
# puts work_register

# user_profiles = sf.user_profiles(authkey, private_key)
# puts user_profiles


#
# NOTES
#
# This is a list of registrered works...
# 1. 1005040146823 (my first text registration)
# 2. 1005040146830 (my first track registration)
# 3. 1005040146847 (second text registration test)