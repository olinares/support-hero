require './app'
require 'date'

ca_holidays = { DateTime.new(2016,1,1) => "New Year’s Day", 
                DateTime.new(2016,1,18) => "Martin Luther King Jr. Day",
                DateTime.new(2016,2,15) => "Presidents’ Day",
                DateTime.new(2016,3,31) => "Cesar Chavez Day",
                DateTime.new(2016,5,30) => "Memorial Day",
                DateTime.new(2016,7,4) =>  "Independence Day",
                DateTime.new(2016,9,5) =>  "Labor Day",
                DateTime.new(2016,11,11) => "Veterans Day",
                DateTime.new(2016,11,24) => "Thanksgiving Day",
                DateTime.new(2016,11,25) => "Day after Thanksgiving",
                DateTime.new(2016,12,26) => "Christmas Day", }

support_heroes = ['Sherry', 'Boris', 'Vicente', 'Matte', 'Jack', 'Sherry', 
                    'Matte', 'Kevin', 'Kevin', 'Vicente', 'Zoe', 'Kevin',
                    'Matte', 'Zoe', 'Jay', 'Boris', 'Eadon', 'Sherry',
                    'Franky', 'Sherry', 'Matte', 'Franky', 'Franky', 'Kevin',
                    'Boris', 'Franky', 'Vicente', 'Luis', 'Eadon', 'Boris',
                    'Kevin', 'Matte', 'Jay', 'James', 'Kevin', 'Sherry',
                    'Sherry', 'Jack', 'Sherry', 'Jack']


heroes_list = Array.new
support_heroes.each do |person|
  heroes_list.push(person) if not heroes_list.include?(person)
  Hero.create!(name: person) unless Hero.where(name: person).first
end
puts heroes_list

# seed starting order
n = 1
support_heroes.each do |person|
  next_hero = Hero.find_by name: person
  StartingOrder.create!(heroes_id: next_hero.id, list_order: n) unless StartingOrder.where( list_order: n ).first
  puts n
  check_hero = StartingOrder.find_by(list_order: n)
  puts "Starting Order #{check_hero.list_order}"
  puts "Hero id #{check_hero.heroes_id}"
  n += 1
end

ca_holidays.each do |date, holidayName|
  Holiday.create!(date: date, holidayName: holidayName) unless Holiday.where(date: date).first
  holiday = Holiday.find_by(holidayName: holidayName)
  puts holiday.holidayName
end
