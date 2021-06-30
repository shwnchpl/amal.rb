#!/usr/bin/env ruby

#######################################################################
# Copyright 2021 Shawn M. Chapla
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#######################################################################

#######################################################################
# Similar to mksqlite3c.tcl, but hopefully slightly more flexible.
#
# Usage:
#   $ amal.rb --headers ./include --src ./src
#
# Output:
#   [An amalgamated C source file].
#
# Each option may be specified more than once.
#
# TODO: Add real usage notes.
#######################################################################

require 'optparse'

sources = []
headers = []

ARGV << '--help' if ARGV.empty?

OptionParser.new do |opts|
  opts.banner = "Usage: amal.rb [options]"

  opts.on('-h', '--help', "Display this help.") do
    $stderr.puts opts
    exit -1
  end

  opts.on("--headers HEADERS", "Include all headers in a tree.") do |p|
    if not Dir.exist?(p)
      $stderr.puts "'#{p}' is not a valid directory."
      exit -1
    end
    headers << p.delete_prefix('./').chomp('/')
  end

  opts.on("--src SOURCE", "Include all sources in a tree.") do |p|
    if not Dir.exist?(p)
      $stderr.puts "'#{p}' is not a valid directory."
      exit -1
    end
    sources << p.delete_prefix('./').chomp('/')
  end
end.parse!

could_include = []
must_include = []

sources.each {|h| could_include += Dir.glob("#{h}/**/*.h")}
headers.each {|h| must_include += Dir.glob("#{h}/**/*.h")}
sources.each {|s| must_include += Dir.glob("#{s}/**/*.c")}

paths_avail = Hash[(could_include + must_include).collect {|p| [p, true]}]

def include_path(pa, ht, p)
  context, _, file = p.rpartition('/')
  pa[p] = false
  puts "/******* BEGIN FILE #{p} *******/"

  File.foreach(p) do |line|
    # XXX: This discards comments after include directives, mainly
    # because it is not safe to wrap such comments and doing otherwise
    # would introduce unnecessary complexity.
    hmatch = /#include\s+[<"](.*)[">]/.match(line)
    if hmatch
      handled = false

      ([context] + ht).each do |c|
        c = c + '/' if c != ''
        full_path = c + hmatch[1]
        if pa.include?(full_path)
          if pa[full_path]
            pa = include_path(pa, ht, full_path)
          else
            puts "/* #{hmatch[0]} */"
          end
          handled = true
          break
        end
      end

      if not handled
        if not pa.include?(hmatch[1])
          puts line
          pa[hmatch[1]] = false
        else
          puts "/* #{hmatch[0]} */"
        end
      end
    else
      puts line
    end
  end

  puts "/******* END FILE #{p} *******/"
  pa
end

must_include.each do |p|
  if paths_avail[p]
    paths_avail = include_path(paths_avail, headers, p)
  end
end
