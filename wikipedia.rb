require 'net/http'

class Wikipedia < SourceAdapter
  attr_accessor :search_query
  
  
  def initialize(source,credential)
    puts "Wikipedia initialize with #{source.inspect.to_s}"
    
    super(source,credential)
    
    @search_query||="Ruby on Rails"
  end
  
  def query
    puts "Wikipedia query"
  end

  def sync
    puts "Wikipedia sync with #{@search_query}"
    
    param=@search_query.gsub(" ", "_")
    
    # @source.url
    http = Net::HTTP.new('en.m.wikitest.org', 4000)
    path = "/wiki/#{param}"

    headers = {
      'User-Agent' => 'Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1C28'
    }

    response, data = http.get(path, headers)
    
    puts "Code = #{response.code}"
    puts "Message = #{response.message}"
    response.each {|key, val|
      puts key + ' = ' + val
    }
      
    data = [data].pack("m").gsub("\n", "")
    
    packets = data.length / 255
    puts "packets to make #{packets}"

    0.upto(packets) do |packet|
      o=ObjectValue.new
      o.source_id= @source.id
      o.object= param
      o.attrib= "p_#{packet}"
      
      page_data = data[packet*255, 255] # send no more than 255 chars at a time
      
      o.value=page_data
      o.user_id=nil # never user specific
      o.save
    end
    
    ObjectValue.create(:source_id=>@source.id, :object => param, :attrib => "data_length", :value => data.length.to_s)
    ObjectValue.create(:source_id=>@source.id, :object => param, :attrib => "packet_count", :value => (packets+1).to_s)
  end

#  [{"name"=>"search", "value"=>"diamond"}]
  def create(name_value_list)
    puts "Wikipedia create"
    
    puts name_value_list.inspect.to_s
    @search_query=name_value_list[0]["value"]
    
  end

end