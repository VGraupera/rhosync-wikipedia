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
    
    http = Net::HTTP.new(@source.url)
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
      
    data = rewrite_urls(data)
    data = [data].pack("m").gsub("\n", "")
    
    ObjectValue.create(:source_id=>@source.id, :object => param, :attrib => "data_length", :value => data.length.to_s)
    ObjectValue.create(:source_id=>@source.id, :object => param, :attrib => "data", :value => data)
  end

#  [{"name"=>"search", "value"=>"diamond"}]
  def create(name_value_list)
    puts "Wikipedia create"
    
    puts name_value_list.inspect.to_s
    @search_query=name_value_list[0]["value"]
    
  end
  
  protected 
    # rewrite URLs of the form:
    # <a href="/wiki/Feudal_System"
    # to
    # <a href="/Wikipedia/WikipediaPage/{Feudal_System}/fetch"
    
    def rewrite_urls(html)
      html = html.gsub('<link href=\'/stylesheets/application.css\'', '<link href=\'http://m.wikipedia.org/stylesheets/application.css\'')
      html.gsub(/href=\"\/wiki\/([\w\(\)]*)\"/i,'href="/Wikipedia/WikipediaPage/{\1}/fetch" target="_top"')
    end

end