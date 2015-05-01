
require 'json'
require 'scraperwiki'
require 'open-uri'

def json_from(url)
  JSON.parse(open(url).read)
end

data = json_from('https://australia.popit.mysociety.org/api/v0.1/export.json')['persons'].map do |p|
  {
    id: p['ids'].find { |i| i['provider'] == 'aph_id' }['id'],
    name: p['name'],
    party: p['data']['party'][0],
    house: p['data']['house'][0],
    source: (p['links'].find { |l| l['note'] == 'aph_profile_page' } || {})['url'],
    website: (p['links'].find { |l| l['note'] == 'website' } || {})['url'],
    photo: (p['links'].find { |l| l['note'] == 'aph_profile_photo' } || {})['url'],
    email: (p['contact_details'].find { |l| l['type'] == 'email' } || {})['value'],
    facebook: (p['contact_details'].find { |l| l['type'] == 'facebook' } || {})['value'],
    twitter: (p['contact_details'].find { |l| l['type'] == 'twitter' } || {})['value'],
  }
end

data.each_with_index do |r, i|
  puts "Adding #{i+1}. #{r[:id]}: #{r}"
  ScraperWiki.save_sqlite([:id], data)
end
