require_relative "../lib/api.rb"
require "colorize"
require "date"

$prompt = TTY::Prompt.new

$state = {
    postcode: '',
    cinema: 0,
    day: 0
}


def title
    system('clear')
    puts ''
    puts '███████╗██╗██╗     ███╗   ███╗    ██╗     ██╗███████╗████████╗██╗███╗   ██╗ ██████╗ ███████╗'.colorize(:yellow)
    puts '██╔════╝██║██║     ████╗ ████║    ██║     ██║██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝ ██╔════╝'.colorize(:yellow)
    puts '█████╗  ██║██║     ██╔████╔██║    ██║     ██║███████╗   ██║   ██║██╔██╗ ██║██║  ███╗███████╗'.colorize(:yellow)
    puts '██╔══╝  ██║██║     ██║╚██╔╝██║    ██║     ██║╚════██║   ██║   ██║██║╚██╗██║██║   ██║╚════██║'.colorize(:yellow)
    puts '██║     ██║███████╗██║ ╚═╝ ██║    ███████╗██║███████║   ██║   ██║██║ ╚████║╚██████╔╝███████║'.colorize(:yellow)
    puts '╚═╝     ╚═╝╚══════╝╚═╝     ╚═╝    ╚══════╝╚═╝╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝'.colorize(:yellow)
    puts '' 
end

def welcome(message = nil)
    title
    puts "Welcome!"
    puts ''
    if message
        puts message.colorize(:red)
    end
    $state['postcode'] = $prompt.ask("Please enter your postcode to get started:")
    menu
end

def menu
    title
    response = get_cinemas_by_postcode($state['postcode'])
    if response.code === 200
        cinemas = JSON.parse(response)
        choose_a_cinema(cinemas)
    else
        welcome('Postcode not found, try again.')
    end
end

def choose_a_cinema(cinema_hash)
    cinemas = cinema_hash['cinemas'].map{|cinema| {name: cinema['name'], value: cinema['id']}}.slice(0..9)
    cinemas << {name: 'Quit', value: 0}
    $state['cinema'] = $prompt.select('Pick a cinema...', cinemas, per_page: 11)
    if $state['cinema'] === 0 
        system('clear')
        puts 'Good night, and good luck.'
        puts ''
        exit
    else 
        cinema_menu
    end
end

def cinema_menu
    puts ''
    $state['day'] = 0
    $prompt.select('Choose an option') do |m|
        m.choice 'Cinema Info', -> {cinema_info}
        m.choice 'Today\'s Listings', -> {cinema_listings}
        m.choice 'Future Listings', -> {future_listings}
        m.choice 'Main Menu', -> {menu}
    end
    cinema_menu
end

def cinema_info
    cinema = get_cinema_info($state['cinema'])
    puts ''
    puts '--------------------------------------------------------------------------------------------'
    puts 'CINEMA: '.colorize(:blue) + cinema['name']
    puts 'ADDRESS: '.colorize(:blue) + cinema['address1'] + ', ' + cinema['postcode']
    puts 'WEBSITE: '.colorize(:blue) + cinema['website']
    puts 'PHONE: '.colorize(:blue) 
    + cinema['phone']
end

def cinema_listings
    system('clear')
    puts ''
    puts '############################################################################################'.colorize(:yellow)
    puts '########################################  LISTINGS  ########################################'.colorize(:yellow)
    puts '############################################################################################'.colorize(:yellow)
    listings = get_cinema_listings($state['cinema'], $state['day'])['listings']
    listings.each do |listing|
        puts ''
        puts '--------------------------------------------------------------------------------------------'
        puts 'FILM: '.colorize(:blue) + listing['title']
        puts 'TIMES: '.colorize(:blue) + listing['times'].join(', ')
    end
end

def dates
    $n = 1
    $choices = []
    7.times do
        $choices << {name: (Date.today + $n).strftime("%A"), value: $n}
        $n += 1
    end
    $choices
end

def future_listings
    $state['day'] = $prompt.select('Choose a day:', dates, per_page: 7)
    cinema_listings
end
    

