require 'rest-client'
require 'json'
require 'pry'

$api_base = 'https://api.cinelist.co.uk/'

def get_cinemas_by_postcode(postcode)
    response = RestClient.get($api_base + 'search/cinemas/postcode/' + postcode.upcase){|response, request, result| response }
end

def get_cinema_listings(cinema)
    response = RestClient.get($api_base + 'get/times/cinema/' + cinema)
    JSON.parse(response)
end

def get_cinema_info(cinema)
    response = RestClient.get($api_base + 'get/cinema/' + cinema)
    JSON.parse(response)
end