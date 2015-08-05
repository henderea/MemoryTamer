#!/usr/bin/env ruby

require 'base64'

START_LINE = "-----BEGIN PUBLIC KEY-----\n"
END_LINE = "-----END PUBLIC KEY-----\n"

fname = ARGV.shift
vname = ARGV.shift || 'publicKey'
fname = File.expand_path(fname)

fdata = IO.read(fname)

fdata = fdata.gsub(START_LINE, '').gsub(END_LINE, '').encode('UTF-8')

puts fdata.inspect

base64_string = Base64.encode64(fdata)

puts "#{vname} = ''"

remaining_string = base64_string

until remaining_string.empty?
  len = rand(40) + 5
  if len >= remaining_string.length
    puts "#{vname} << #{remaining_string.inspect}"
    remaining_string = ''
  else
    tmp = remaining_string[0...len]
    remaining_string = remaining_string[len..-1]
    puts "#{vname} << #{tmp.inspect}"
  end
end