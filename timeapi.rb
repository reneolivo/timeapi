require 'rubygems'
require 'sinatra'
require 'chronic'
require 'date'
require 'time'

module TimeAPI
  PST = -8
  MST = -7
  CST = -6
  EST = -5
  PDT = -7
  MDT = -6
  CDT = -5
  EDT = -4
  UTC = 0
  GMT = 0
  
  class App < Sinatra::Default
  
    set :sessions, false
    set :run, false
    set :environment, ENV['RACK_ENV']
    
    def format
      request.query_string \
        .gsub('%20', ' ') \
        .gsub('\\', '%') \
    end
    
    get '/' do
      erb :index
    end
    
    get '/favicon.ico' do
      ''
    end
    
    get '/:zone' do
      zone = params[:zone].upcase
      offset = TimeAPI::const_get(zone)
      
      Time.new.utc.to_datetime.new_offset(Rational(offset,24)).to_s(format)
    end
    
    get '/:zone/:time' do
      zone = params[:zone].upcase
      time = params[:time] \
              .gsub(/^at /, '') \
              .gsub(/(\d)h/, '\1 hours') \
              .gsub(/(\d)min/, '\1 minutes') \
              .gsub(/(\d)m/, '\1 minutes') \
              .gsub(/(\d)sec/, '\1 seconds') \
              .gsub(/(\d)s/, '\1 seconds')
      offset = TimeAPI::const_get(zone)
      
      Chronic.parse(
        time, :now=>Time.new.utc.set_timezone(offset)
      ).to_datetime.new_offset(Rational(offset,24)).to_s(format)
    end
  
  end
end

class Time
  def set_timezone(offset)
    Time.parse(to_datetime.new_offset(Rational(offset,24)).to_s)
  end
  
  def to_datetime
    # Convert seconds + microseconds into a fractional number of seconds
    seconds = sec + Rational(usec, 10**6)

    # Convert a UTC offset measured in minutes to one measured in a
    # fraction of a day.
    offset = Rational(utc_offset, 60 * 60 * 24)
    DateTime.new(year, month, day, hour, min, seconds, offset)
  end
end

class DateTime
  def to_datetime
    self
  end
  
  def to_s(format='')
    unless format.empty?
      strftime(format)
    else
      strftime
    end
  end
end