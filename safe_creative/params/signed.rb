#
# signed.rb
# 
# Created by Giovanni Cappellotto on 19/05/2010.
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

module SafeCreative
  module Params
    class Signed < SafeCreative::Params::Base
      def initialize(hash, private_key)
        super(hash)
        # add ztime parameter
        @hash = @hash.merge({"ztime" => unixtime})
        @private_key = private_key
      end
  
      def to_query
        query_string = super
    
        # append signature parameter
        query_string += "&signature=#{sign}"
    
        query_string
      end
  
      private
      
      def unixtime
        now = Time.now.utc
        now_i = now.to_i * 1000
        now_i += now.usec / 1000
        now_i.to_s
      end
      
      def sign
        Digest::SHA1.hexdigest(@private_key + "&" + sort_to_query)
      end
  
      def sort_to_query
        SafeCreative::Base.logger.debug "SORT_TO_QUERY INPUT: #{@hash.inspect}" unless SafeCreative::Base.logger.nil?
    
        params = @hash.clone
        params.delete("debug-component")
        sorted = params.sort
    
        query_string = ""
        size = sorted.size
        sorted.each_with_index do |item, index|
          item_string = ""
          item.each_with_index do |val, i|
            item_string += "#{val}" + (i == 0 ? "=" : "")
          end
          query_string += item_string + (index + 1 < size ? "&" : "")
        end
    
        SafeCreative::Base.logger.debug "SORTED PARAMS: #{query_string}" unless SafeCreative::Base.logger.nil?
    
        query_string
      end
    end
  end
end