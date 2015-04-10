require 'cinch'

# == Logging Plugin Authors
# Marvin Gülker (Quintus)
# Jonathan Cran (jcran)
#
# == License
# A logging plugin for Cinch.
# Copyright © 2012 Marvin Gülker
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as 
# published by the Free Software Foundation, either version 3 of 
# the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public 
# License along with this program.  If not, see 
# <http://www.gnu.org/licenses/>.
 
class Logger
  include Cinch::Plugin
 
  listen_to :connect,    :method => :setup
  listen_to :disconnect, :method => :cleanup
  listen_to :channel,    :method => :log_public_message
  timer 60,              :method => :check_midnight
 
  def initialize(*args)
    super
    @short_format = "%Y-%m-%d"
    @long_format = "%Y-%m-%d %H:%M:%S"
    @filename = "log-#{Time.now.strftime(@short_format)}.log"
    @logfile          = File.open(@filename,"w")
    @midnight_message =  "=== The dawn of a new day: #{@short_format} ==="
    @last_time_check  = Time.now
  end
 
  def setup(*)
    bot.debug("Opened message logfile at #{@filename}")
  end
 
  def cleanup(*)
    @logfile.close
    bot.debug("Closed message logfile at #{@filename}.")
  end
 
  ###
  ### Called every X seconds to see if we need to rotate the log
  ###
  def check_midnight
    time = Time.now
    if time.day != @last_time_check.day
      @filename = "log-#{Time.now.strftime(@short_format)}.log"
      @logfile = File.open(@filename,"w")
      @logfile.puts(time.strftime(@midnight_message))
    end
    @last_time_check = time
  end
 
  ###
  ### Logs a message!
  ###
  def log_public_message(msg)
    time = Time.now.strftime(@long_format)
    @logfile.puts(sprintf( "<%{time}> %{nick}: %{msg}",
                                :time => time,
                                :nick => msg.user.name,
                                :msg  => msg.message))
  end
 
end
 
bot = Cinch::Bot.new do
  configure do |c|
    c.server = "irc.freenode.org"
    c.nick     = "HackSpreeBot"
    c.channels = ["#hackspree"]
    c.plugins.plugins = [Logger]
  end

  on :message, "hello" do |m|
    m.reply "Hello, #{m.user.nick}"
  end

#  on :message, /^!msg (.+?) (.+)/ do |m, who, text|
#    User(who).send text
#  end

end

bot.start
