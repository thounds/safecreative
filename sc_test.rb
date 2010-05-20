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

log = Logger.new(STDOUT)
log.level = Logger::DEBUG

sf = SafeCreative::Base.new(SHARED_KEY, PRIVATE_KEY, log)

log.debug sf.ztime

# log.debug sf.authkey_create

# email = 'potomak84@gmail.com'
# log.debug sf.user_link(email)

# authkey = "f9fy4mjwuavwshvg9qqrdbwy"
# private_key = "3n8zd5hlkasi5c31ny0rtxraz"
# log.debug sf.authkey_state(authkey)

# log.debug sf.work_types

# log.debug sf.user_licenses(authkey, private_key)

# track_url = "http://s3.amazonaws.com/mp3.stage.thounds.com/thounds/1302/tracks/2175.mp3"
# noncekey = "xv5emjg0rql1df5ns7odw8l2"
# work = SafeCreative::Work.new("My test song", SafeCreative::Work::TYPE[:music], track_url, "2175.mp3")
# log.debug sf.work_register(authkey, private_key, noncekey, work)

# log.debug sf.user_profiles(authkey, private_key)