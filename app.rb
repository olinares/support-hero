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

