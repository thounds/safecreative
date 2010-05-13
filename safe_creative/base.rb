#
# base.rb
# 
# Created by Giovanni Cappellotto on 13/05/2010.
# 
# Copyright (c) 2010 Thounds Inc.
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 
# Neither the name of the project's author nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
# TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
# PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

require 'net/http'
require 'net/https'
require 'open-uri'
require 'digest/sha1'

module SafeCreative
  class Base
    def initialize(shared_key, private_key, logger = nil)
      @shared_key  = shared_key
      @private_key = private_key
      @logger      = logger
    end

    def ztime
      call(SafeCreative::Params.new({"component" => "ztime"}))
    end

    def authkey_create
      params = SafeCreative::Params.new({
        "component" => "authkey.create",
        "sharedkey" => @shared_key,
        "ztime" => SafeCreative::Params.unixtime
      })
  
      params.sign(@private_key)

      call(params)
    end

    # NOTE: useless because linked users authkeys are already authorized
    def authkey_edit_url(authkey, management_level = SafeCreative::MANAGEMENT_LEVEL[:add])
      params = SafeCreative::Params.new({
        "authkey" => authkey,
        "level" => management_level,
        "sharedkey" => @shared_key,
        "ztime" => SafeCreative::Params.unixtime
      })
  
      params.sign(@private_key)
  
      "http://" + (SafeCreative::DEBUG ? SafeCreative::URL_ARENA : SafeCreative::URL) + "/api-ui/authkey.edit?" + params.to_query
    end

    def authkey_state(authkey)
      params = SafeCreative::Params.new({
        "component" => "authkey.state",
        "authkey" => authkey,
        "sharedkey" => @shared_key,
        "ztime" => SafeCreative::Params.unixtime
      })
  
      params.sign(@private_key)

      call(params)
    end

    def user_link(mail = nil)
      params = SafeCreative::Params.new({
        "component" => "user.link",
        "level" => SafeCreative::MANAGEMENT_LEVEL[:manage],
        "mail" => "potomak84@gmail.com",
        "sharedkey" => @shared_key,
        "ztime" => SafeCreative::Params.unixtime
      })
  
      params.sign(@private_key)

      call(params)
    end

    def user_licenses(authkey, private_key, page = 1)
      params = SafeCreative::Params.new({
        "component" => "user.licenses",
        "page" => page.to_s,
        "authkey" => authkey,
        "ztime" => SafeCreative::Params.unixtime
      })
  
      params.sign(private_key)

      call(params)
    end

    def user_profiles(authkey, private_key)
      params = SafeCreative::Params.new({
        "component" => "user.profiles",
        "authkey" => authkey,
        "ztime" => SafeCreative::Params.unixtime
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
  
      params = SafeCreative::Params.new({
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
        "ztime" => SafeCreative::Params.unixtime
      })
  
      #
      # EXAMPLE FROM SAFECREATIVE API DOCUMENTATION
      #
      # params = SafeCreative::Params.new({
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
      #   "ztime" => SafeCreative::Params.unixtime
      # })

      params.sign(private_key)
  
      call(params)
    end

    def work_types
      call(SafeCreative::Params.new({"component" => "work.types"}))
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
  
      SafeCreative::Response.new(resp)
    end
  end
end