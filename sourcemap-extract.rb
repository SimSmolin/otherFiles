#!/usr/bin/env ruby

require 'open-uri'
require 'pathname'
require 'json'

def strip_hash(f)
  ext = f.extname

  if ext.include?("?")
    f.sub_ext(ext.split("?").first)
  else
    f
  end
end

sourcemap_url   = ARGV[0] or "USAGE: sourcemap-extract.rb <source-map-url> [<destination>]"
destination     = ARGV[1]
destination   ||= "./tmp"

root            = Pathname(destination || "./tmp").expand_path
sourcemap       = open(sourcemap_url).read
files, contents = JSON(sourcemap).values_at(*%w(sources sourcesContent))

files = files.map { |f| f.sub("~", "./vendor") }
files = files.map { |f| root.join(f).expand_path }
files = files.map { |f| strip_hash(f) }


files.zip(contents).each_with_index do |(dest, source), index|
  dest.dirname.mkpath
  puts "[%4s] \t (%5s) \t WROTE %s" % [index, dest.write(source), dest.relative_path_from(Pathname(".").expand_path)]
end

puts "\nDESTINATION #{root}"
