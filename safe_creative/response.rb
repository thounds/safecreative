require 'rexml/document'

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