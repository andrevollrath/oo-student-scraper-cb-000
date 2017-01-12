require 'open-uri'
require 'pry'
require 'nokogiri'

class Scraper

  #Our method to scrape the index page for students
  def self.scrape_index_page(index_url)
    student_index_array = []

    doc = Nokogiri::HTML(open(index_url))
    doc.search('.student-card').each do |s|
      hash = {}
      hash[:name] = s.search('.card-text-container .student-name').text
      hash[:location] = s.search('.card-text-container .student-location').text
      hash[:profile_url] = "./fixtures/student-site/" + s.search('a').attr('href').text
      student_index_array << hash
    end
    student_index_array
  end

  #Scraps each profile page and returns results
  def self.scrape_profile_page(profile_url)
    doc = Nokogiri::HTML(open(profile_url))
    hash = self.social_links(doc)

    hash[:profile_quote] = doc.search('.profile-quote').text
    hash[:bio] = doc.search('.description-holder')[0].text.strip

    hash
  end

  private
  #Removes the social links as they were a pain in the butt
  def self.social_links(doc)
    hash = {}
    #First collect the social links
    social = doc.search('.social-icon-container a').collect {|x| x.attr("href")}
    #Then discard any youtube or facebook matches
    social = social.select {|url| !url.match(/youtube/) && !url.match(/facebook/)}

    social.each do |social_url|
      case social_url
      when /twitter/
        hash[:twitter] = social_url
      when /linkedin/
        hash[:linkedin] = social_url
      when /github/
        hash[:github] = social_url
      else
        hash[:blog] = social_url
      end
    end
    hash #return our hash of social links or empty if we haven't added any
  end
end
