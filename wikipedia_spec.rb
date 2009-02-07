# not currently working

require 'wikipedia'

describe Wikipedia do
  before(:each) do
    @wp = Wikipedia.new
  end

  it "convert feudal system" do
    @wp.rewrite_urls("<a href=\"/wiki/Feudal_System\"").should == "<a href=\"/Wikipedia/WikipediaPage/{Feudal_System}/show\""
  end
  
  it "convert disambiguation" do
    @wp.rewrite_urls("<a href=\"/wiki/Home_(disambiguation)\"").should == "<a href=\"/Wikipedia/WikipediaPage/{Home_(disambiguation)}/show\""
  end

end
