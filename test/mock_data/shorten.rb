#!/usr/bin/env ruby
require 'rubygems'
require 'mp3info'

len= 50000
files= ARGV
if files.empty?
  puts "Nothing to do."
  exit 0
end
files.each{|f|
  unless File.exists?(f)
    puts "File not found: #{f}"
    exit 1
  end
}

files.each{|file|
  printf "#{file}..."; $stdout.flush
  d= File.read(file)

  mp3= Mp3Info.new(file)
  a= mp3.audio_content[0] + len/2
  b= mp3.audio_content[1] - len/2
  mp3.close

  unless b-a < 1000
    d= d[0..a] + d[b..-1]
    File.open(file,"wb") {|fout| fout<< d}
    puts "ok"
  else
    puts "file too small"
  end
}
puts "Done."

