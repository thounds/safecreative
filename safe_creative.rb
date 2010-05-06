# Safe Creative
require 'net/http'
require 'net/https'
require 'open-uri'
require 'digest/sha1'

require 'safe_creative/params'
require 'safe_creative/response'

class SafeCreative
  DEBUG = true
  
  URL = "api.safecreative.org"
  URL_ARENA = "arena.safecreative.org"
  
  API_ENDPOINT = "/v2/"
  
  MANAGEMENT_LEVEL = {
    :manage => "MANAGE",
    :get => "GET",
    :add => "ADD"
  }
  
  def initialize(shared_key, private_key, logger = nil)
    @shared_key  = shared_key
    @private_key = private_key
    @logger      = logger
  end
  
  def ztime
    call(Params.new({"component" => "ztime"}))
  end
  
  def authkey_create
    params = Params.new({
      "component" => "authkey.create",
      "sharedkey" => @shared_key,
      "ztime" => Params.unixtime
    })
    
    params.sign(@private_key)

    call(params)
  end
  
  # NOTE: useless because linked users authkeys are already authorized
  def authkey_edit_url(authkey, management_level = SafeCreative::MANAGEMENT_LEVEL[:add])
    params = Params.new({
      "authkey" => authkey,
      "level" => management_level,
      "sharedkey" => @shared_key,
      "ztime" => Params.unixtime
    })
    
    params.sign(@private_key)
    
    "http://" + (SafeCreative::DEBUG ? SafeCreative::URL_ARENA : SafeCreative::URL) + "/api-ui/authkey.edit?" + params.to_query
  end
  
  def authkey_state(authkey)
    params = Params.new({
      "component" => "authkey.state",
      "authkey" => authkey,
      "sharedkey" => @shared_key,
      "ztime" => Params.unixtime
    })
    
    params.sign(@private_key)

    call(params)
  end
  
  def user_link(mail = nil)
    params = Params.new({
      "component" => "user.link",
      "level" => SafeCreative::MANAGEMENT_LEVEL[:manage],
      "mail" => "potomak84@gmail.com",
      "sharedkey" => @shared_key,
      "ztime" => Params.unixtime
    })
    
    params.sign(@private_key)

    call(params)
  end
  
  def user_licenses(authkey, private_key, page = 1)
    params = Params.new({
      "component" => "user.licenses",
      "page" => page.to_s,
      "authkey" => authkey,
      "ztime" => Params.unixtime
    })
    
    params.sign(private_key)

    call(params)
  end
  
  def user_profiles(authkey, private_key)
    params = Params.new({
      "component" => "user.profiles",
      "authkey" => authkey,
      "ztime" => Params.unixtime
    })
    
    params.sign(private_key)

    call(params)
  end
  
  def work_register(authkey, private_key, noncekey, url)
    #
    # TODO: parse filename from url (or maybe directly from params)
    #
    
    filename = "test_track.mp3"
    size = 0
    checksum = ""
    
    open(url) do |f|
      size = f.meta["content-length"]
      checksum = Digest::SHA1.hexdigest(f.read)
    end
    
    params = Params.new({
      "component" => "work.register",
      "authkey" => authkey,
      "noncekey" => noncekey,
      "title" => "A title",
      "license" => "http://creativecommons.org/licenses/by/2.0/", # see user.licenses
      "worktype" => "music",                                      # see work.types
      "url" => url,
      "filename" => filename,
      "checksum" => checksum,
      "size" => size,
      "ztime" => Params.unixtime
    })
    
    #
    # EXAMPLE FROM SAFECREATIVE API DOCUMENTATION
    #
    # params = Params.new({
    #   "allowdownload" => 1.to_s,
    #   "excerpt" => "An important text about registry philosophy",
    #   "obs" => "More info at ...",
    #   "registrypublic" => 1.to_s,
    #   "tags" => "tag1 tag2",
    #   "text" => "Text to be registered",
    #   #"usealias" => 1.to_s,
    #   #"userauthor" => 1.to_s,
    #   
    #   "component" => "work.register",
    #   "authkey" => authkey,
    #   "noncekey" => noncekey,
    #   "title" => "A title",
    #   "license" => "http://creativecommons.org/licenses/by/2.0/", # see user.licenses
    #   "worktype" => "article",                                    # see work.types
    #   "ztime" => Params.unixtime
    # })

    params.sign(private_key)
    
    call(params)
  end
  
  def work_types
    call(Params.new({"component" => "work.types"}))
  end
  
  private
  
  def call(params)
    url = SafeCreative::DEBUG ? SafeCreative::URL_ARENA : SafeCreative::URL
    
    resp = ''
    http = Net::HTTP.new(url, 443)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.start do |http|
      query = SafeCreative::API_ENDPOINT + "?" + params.to_query
      if SafeCreative::DEBUG
        puts "REQUEST: #{query}"
      end
      req = Net::HTTP::Get.new(query)
      response = http.request(req)
      resp = response.body
    end
    
    Response.new(resp)
  end
end