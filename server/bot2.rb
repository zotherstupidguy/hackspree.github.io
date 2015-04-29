require 'rubygems'
require 'isaac'

configure do |c|
  #c.username = "hackspreelogger"
  #c.realname = "hackspree logger bot"
  c.nick    = "hackspreelogger"
  c.server  = "irc.freenode.net"
  c.port    = 6667
end

on :connect do
  join "#hackspree"
end

on :channel, /.*/ do
  open("#{channel}.log", "a") do |log|
    log.puts "#{nick}: #{message}"
  end

  puts "#{channel}: #{nick}: #{message}"
end
