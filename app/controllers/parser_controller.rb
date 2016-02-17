require 'open-uri'
class ParserController < ApplicationController
  def view
    # Get a Nokogiri::HTML::Document for the page we’re interested in...
    @season = params[:season]
    @episodes = get_season_data @season
  end

  def get_season_data(season)
    template = /#/
    url = 'https://en.wikipedia.org/wiki/The_Big_Bang_Theory_(season_#)'
    url.gsub!(template, season)

    doc = Nokogiri::HTML(open(url))

    # Do funky things with it using Nokogiri::XML::Node methods...

    ####
    # Search for nodes by css
    css = doc.xpath("//tr/th[starts-with(@id, 'ep')]/../..")
    titles = css.xpath("tr[@class='vevent']/td[2]")
    epnumbers = css.xpath("tr[@class='vevent']/td[1]")
    descriptions = css.xpath("tr/td[@class='description']")

    result = Array.new
    epnumbers.each_with_index { | ep, key |
      result.push({
        :title => titles[key].content,
        :epnum => "S" + season.rjust(2, '0') + "E" + ep.content.rjust(2, '0'),
        :description => descriptions[key]
      })
    }

    return result

  end

  def random
    num_seasons = 9
    season = 1 + rand(num_seasons)
    episodes = get_season_data season.to_s
    @episode = episodes[rand(episodes.length) + 1]
  end
end
