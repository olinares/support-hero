require 'sinatra'
require './environments'
require 'date'
require 'sinatra/flash'
require 'sinatra/activerecord'
require 'sinatra/redirect_with_flash'
require 'rack/utils'

enable :sessions

class App < Sinatra::Base
 register Sinatra::ActiveRecordExtension
end

# Views
get '/'  do
  @create_schedule = CreateSchedule.new.new_month_schedule
  @calendar = GenerateCalendar.new.new_calendar
  @todays_hero = TodaysHero.new.return_hero
  erb :index
end

get '/:name' do
  @name = params[:name]
  @hero_profile = Hero.find_by(name: @name)
  @create_schedule = CreateSchedule.new.new_month_schedule
  @calendar = GenerateCalendar.new.new_calendar
  @hero_schedule = HeroSchedule.new.all_dates_for_hero(@name)
  erb :profile
end

post '/:name/unavailable' do
  Unavailable.create!( date: params[:date], heroes_id: params[:hero_profile_id])
  hero = Hero.find(params[:hero_profile_id])
  @name = hero.name
  @create_schedule = CreateSchedule.new.new_month_schedule
  @hero_schedule = HeroSchedule.new.all_dates_for_hero(@name)
  @calendar = GenerateCalendar.new.new_calendar
  redirect "/#{@name}"
end

post '/:name/switch' do
  date1 = StringtoDateTime.new.extract_datetime(params[:date1])
  date2 = StringtoDateTime.new.extract_datetime(params[:date2])
  Switch.new.hero_switch(date1, date2)
  hero = Hero.find(params[:hero_profile_id])
  @name = hero.name
  redirect "/#{@name}"
end

class Switch
  def hero_switch(date1, date2)
    calendar1 = Calendar.find_by( date: date1 )
    calendar2 = Calendar.find_by( date: date2 )
    hero1 = calendar1.heroes_id
    hero2 = calendar2.heroes_id
    calendar1.update( date: date1, heroes_id: hero2, switch_flag: 1)
    calendar2.update( date: date2, heroes_id: hero1, switch_flag: 1)
  end
end

# Models

class Hero < ActiveRecord::Base
  self.table_name = "heroes"
  has_many :starting_orders
  belongs_to :calendars
  validates :name, presence: true
end

class Calendar < ActiveRecord::Base
  has_many :heroes
  has_many :unavailables
  has_many :starting_orders

  validates :starting_orders_id, presence: true
  validates :date, presence: true
  validates :heroes_id, presence: true
  validates :switch_flag, presence: true
end

class StartingOrder < ActiveRecord::Base
  belongs_to :heroes
  belongs_to :calendars

  validates :heroes_id, presence: true
  validates :list_order, presence: true
end

class Unavailable < ActiveRecord::Base
  belongs_to :heroes
  belongs_to :calendars

  validates :date, presence: true
  validates :heroes_id, presence: true
end

class Holiday < ActiveRecord::Base
  belongs_to :calendars
  belongs_to :heroes

  validates :date, presence: true
  validates :heroes_id, presence: true
end

class StringtoDateTime
  def extract_datetime(d)
    year = d.split(',')[0].to_i
    month = d.split(',')[1].to_i
    day = d.split(',')[2].to_i
    date = DateTime.new(year, month, day)
    return date
  end
end

class TodaysDate
  def datetime_object(d = Time.now.utc)
    year = d.strftime('%Y').to_i
    month = d.strftime('%m').to_i
    day = d.strftime('%d').to_i
    DateTime.new(year, month, day)
    return DateTime.new(year, month, day)
  end
end

class Month
  def month_start(d = Time.now.utc)
    year = d.strftime('%Y').to_i
    month = d.strftime('%m').to_i
    day = 1.to_i
    return year, month, day
  end

  def remainder_month_start(d = Time.now.utc)
    year = d.strftime('%Y').to_i
    month = d.strftime('%m').to_i
    day = d.strftime('%d').to_i
    return year, month, day
  end

  def month_range(year = 2015, month = 6, day = 1)
    begin_date = DateTime.new(year, month, day)
    end_date = DateTime.new(year, month, -1)
    month_range = (begin_date .. end_date)
  end
end

class HeroSchedule
  def all_dates_for_hero(name)
    hero = Hero.find_by( name: name )
    hero_id = hero.id
    hero_schedule = Calendar.where( heroes_id: hero_id )
    return hero_schedule
  end
end

class TodaysHero
  def return_hero(date = TodaysDate.new.datetime_object)
    hero_date = Calendar.find_by( date: date )
    todays_heroid = hero_date.heroes_id
    todays_hero = Hero.find_by( id: todays_heroid )
    todays_hero_name = todays_hero.name
    todays_hero_data = Hash.new
    todays_hero_data[date] = todays_hero_name
    return todays_hero_data
  end
end

class DetermineStartingHero
  def check_for_start_order(date = TodaysDate.new.datetime_object)
    if Calendar.where( date: date ).exists? == true
      calendar_date = Calendar.find_by( date: date )
        if Calendar.where( id: (calendar_date.id - 1) ).exists? == true
          calendar_date = Calendar.find_by( id: (calendar_date.id - 1) )
          starting_order = calendar_date.starting_orders_id + 1
        end
    else
      starting_order = 1
    end
      puts "start order is #{starting_order}"
    return starting_order
  end
end

class CreateSchedule
def new_month_schedule(month_range = Month.new.month_range, starting_order=1)
    n = starting_order
    month_range.each do |d|
      if d.wday == 6 or d.wday == 0
        next
      elsif Holiday.where( date: d ).exists? == true
        next
      elsif Calendar.where( date: d, switch_flag: 1).exists? == true
        next
      else
        puts n
        if n == (StartingOrder.all.count + 1)
            n = 1
        end
        scheduled_hero = StartingOrder.find_by( list_order: n )
        while Unavailable.where( date: d, heroes_id: scheduled_hero.heroes_id ).exists? == true
          n += 1
          if n == (StartingOrder.all.count + 1)
          n = 1
          end
          scheduled_hero = StartingOrder.find_by( list_order: n )
        end
        if Calendar.where( date: d ).exists? == true
            calendar = Calendar.find_by( date: d)
            calendar.update( date: d, heroes_id: scheduled_hero.heroes_id, starting_orders_id: scheduled_hero.id )
        else
            Calendar.create!( date: d, heroes_id: scheduled_hero.heroes_id, starting_orders_id: scheduled_hero.id, switch_flag: 0 )
        end
        n += 1
      end
    end
  end
end

class GenerateCalendar
  def new_calendar(month_range = Month.new.month_range)
    new_calendar = Hash.new
    month_range.each do |d|
      if d.wday == 6
        new_calendar[d] = ""
      elsif d.wday == 0
        new_calendar[d] = ""
      else
        if Calendar.where( date: d ).exists? == true
          assignment = Calendar.find_by( date: d )
          hero = Hero.find_by( id: assignment.heroes_id )
          new_calendar[d] = hero.name
        end
        if Holiday.where( date: d ).exists? == true
          holiday = Holiday.find_by( date: d)
          new_calendar[d] = holiday.holidayName
        end
      end
    end
    new_calendar
  end
end
