require 'cgi'

class Params
  def initialize(hash)
    @hash = hash
  end
  
  def self.unixtime
    now = Time.now.utc
    now_i = now.to_i * 1000
    now_i += now.usec / 1000
    now_i.to_s
  end
  
  def to_query
    query_string = ""
    size = @hash.size
    index = 0
    @hash.each do |key, value|
      index += 1
      query_string += "#{key}=#{CGI::escape(value)}" + (index < size ? "&" : "")
    end
    
    # append params signature
    unless @signature.nil?
      query_string += "&signature=#{@signature}"
    end
    
    query_string
  end
  
  def sign(private_key)
    @signature = Digest::SHA1.hexdigest(private_key + "&" + sort_to_query)
  end
  
  private
  
  def sort_to_query
    if SafeCreative::DEBUG
      puts "SORT_TO_QUERY INPUT: #{@hash.inspect}"
    end
    
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
    
    if SafeCreative::DEBUG
      puts "SORTED PARAMS: #{query_string}"
    end
    
    query_string
  end
end