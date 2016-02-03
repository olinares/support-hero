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
  'Support Hero'    
end

# Models

class Hero < ActiveRecord::Base
  self.table_name = "heroes"
  has_many :starting_orders
  belongs_to :calendars
  validates :name, presence: true
end
