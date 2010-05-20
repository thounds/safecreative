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
      @@logger     = logger
    end
    
    def self.logger
      @@logger
    end

    def ztime
      call(SafeCreative::Params::Base.new({"component" => "ztime"}))
    end

    def authkey_create
      params = SafeCreative::Params::Signed.new({
        "component" => "authkey.create",
        "sharedkey" => @shared_key}, @private_key)

      call(params)
    end

    # NOTE: useless because linked users authkeys are already authorized
    def authkey_edit_url(authkey, management_level = SafeCreative::MANAGEMENT_LEVEL[:add])
      params = SafeCreative::Params::Signed.new({
        "authkey" => authkey,
        "level" => management_level,
        "sharedkey" => @shared_key}, @private_key)
  
      "http://" + (SafeCreative::DEBUG ? SafeCreative::URL_ARENA : SafeCreative::URL) + "/api-ui/authkey.edit?" + params.to_query
    end

    def authkey_state(authkey)
      params = SafeCreative::Params::Signed.new({
        "component" => "authkey.state",
        "authkey" => authkey,
        "sharedkey" => @shared_key}, @private_key)

      call(params)
    end

    def user_link(mail = nil, management_level = SafeCreative::MANAGEMENT_LEVEL[:manage])
      params = SafeCreative::Params::Signed.new({
        "component" => "user.link",
        "level" => management_level,
        "mail" => mail,
        # don't send notifications
        "sendNotifications" => 0.to_s,
        "sharedkey" => @shared_key}, @private_key)

      call(params)
    end

    def user_licenses(authkey, private_key, page = 1)
      params = SafeCreative::Params::Signed.new({
        "component" => "user.licenses",
        "page" => page.to_s,
        "authkey" => authkey}, private_key)

      call(params)
    end

    def user_profiles(authkey, private_key)
      params = SafeCreative::Params::Signed.new({
        "component" => "user.profiles",
        "authkey" => authkey}, private_key)

      call(params)
    end

    def work_register(authkey, private_key, noncekey, work, license = "http://creativecommons.org/licenses/by/2.0/")
      size = 0
      checksum = ""
  
      open(work.url) do |f|
        size = f.meta["content-length"]
        checksum = Digest::SHA1.hexdigest(f.read)
      end
  
      params = SafeCreative::Params::Signed.new({
        "component" => "work.register",
        "authkey" => authkey,
        "noncekey" => noncekey,
        "title" => work.title,
        "license" => license, # see user.licenses
        "worktype" => work.type, # see work.types
        "url" => work.url,
        "filename" => work.filename,
        "checksum" => checksum,
        "size" => size.to_s}, private_key)
  
      call(params)
    end

    def work_types
      call(SafeCreative::Params::Base.new({"component" => "work.types"}))
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
        
        @@logger.debug "REQUEST: #{query}" unless @@logger.nil?
        
        req = Net::HTTP::Get.new(query)
        response = http.request(req)
        resp = response.body
      end
  
      SafeCreative::Response.new(resp)
    end
  end
end