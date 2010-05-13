#
# response.rb
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

require 'rexml/document'

module SafeCreative
  class Response
    def initialize(response)
      if SafeCreative::DEBUG
        puts "RESPONSE: #{response}"
      end
    
      @response = response
      @response_hash = parse_elements(REXML::Document.new(@response).elements)
    end

    def parse_elements(elements)
      parse_hash = {}

      elements.each do |element|
        if "error" == element.name
          raise "#{element.elements['errorId'].text} #{"(" + element.elements['errorMessage'].text + ")" unless element.elements['errorMessage'].nil?}"
        end

        if "exception" == element.name
          raise "#{element.elements['exceptionId'].text} #{"(" + element.elements['exceptionMessage'].text + ")" unless element.elements['exceptionMessage'].nil?}"
        end

        unless element.has_elements?
          parse_hash[element.name] = element.text
        else
          if parse_hash[element.name].nil?
            parse_hash[element.name] = parse_elements(element.elements)
          else
            if "Array" != parse_hash[element.name].class.to_s
              temp = parse_hash[element.name]
              parse_hash[element.name] = [temp]
            end
            parse_hash[element.name] << parse_elements(element.elements)
          end
        end
      end

      parse_hash
    end
  
    def to_s
      @response_hash.inspect
    end
  end
end