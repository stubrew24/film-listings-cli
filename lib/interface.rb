require_relative "../lib/api.rb"
require "colorize"

$prompt = TTY::Prompt.new
$postcode = ''

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
    if message
        puts message.colorize(:red)
    end
    $postcode = $prompt.ask("Please enter your postcode to get started:")
    menu
end

def menu
    title
    response = get_cinemas_by_postcode($postcode)
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
    cinema_id = $prompt.select('Pick a cinema...', cinemas, per_page: 11)
    if cinema_id === 0 
        system('clear')
        puts 'Good night, and good luck.'
        puts ''
        exit
    else 
        cinema_menu(cinema_id)
    end
end

def cinema_menu(cinema_id)
    puts ''
    $prompt.select('Choose an option') do |m|
        m.choice 'Cinema Info', -> {cinema_info(cinema_id)}
        m.choice 'Listings', -> {cinema_listings(cinema_id)}
        m.choice 'Main Menu', -> {menu}
    end
    cinema_menu(cinema_id)
end

def cinema_info(cinema_id)
    cinema = get_cinema_info(cinema_id)
    puts ''
    puts '--------------------------------------------------------------------------------------------'
    puts 'CINEMA: '.colorize(:blue) + cinema['name']
    puts 'ADDRESS: '.colorize(:blue) + cinema['address1'] + ', ' + cinema['postcode']
    puts 'WEBSITE: '.colorize(:blue) + cinema['website']
    puts 'PHONE: '.colorize(:blue) + cinema['phone']
end

def cinema_listings(cinema_id)
    listings = get_cinema_listings(cinema_id)['listings']
    listings.each do |listing|
        puts ''
        puts '--------------------------------------------------------------------------------------------'
        puts 'FILM: '.colorize(:blue) + listing['title']
        puts 'TIMES: '.colorize(:blue) + listing['times'].join(', ')
    end
end
