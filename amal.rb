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

# Something similar to mksqlite3c.tcl, but hopefully slightly more
# flexible. Just an outline to start.

# Projected usage:
#   $ amal.rb --headers ./include --src ./src
#
# Output:
#   [An amalgamated source file including all project local headers
#    inline and include directives for each other header only once,
#    as described below. This should include all .c source files in
#    all trees from the specified directories. For --headers
#    directories, include all header files as well. It should be
#    possible to specify each option more than once.]

require 'optparse'
require 'set'

trees = Hash.new {|h, k| h[k] = []}

ARGV << '--help' if ARGV.empty?

OptionParser.new do |opts|
  opts.banner = "Usage: amal.rb [options]"

  opts.on('-h', '--help', "Display this help.") do
    $stderr.puts opts
    exit -1
  end

  opts.on("--headers HEADERS", "Include all headers in a tree.") do |headers|
    if not Dir.exist? headers
      $stderr.puts "'#{headers}' is not a valid directory."
      exit -1
    end
    trees[:headers].append headers
  end

  opts.on("--src SOURCE", "Include all sources in a tree.") do |source|
    if not Dir.exist? source
      $stderr.puts "'#{source}' is not a valid directory."
      exit -1
    end
    trees[:sources].append source
  end
end.parse!

# TODO: Is there a cleaner way to do this?
# TODO: Should I even be using a hash map for these few options?

class String
  def clean_path
    self.delete_prefix('./').chomp('/')
  end
end

could_include = []
trees[:sources].each do |h|
  could_include += Dir.glob("#{h.clean_path}/**/*.h")
end

must_include = []
trees[:headers].each do |h|
  must_include += Dir.glob("#{h.clean_path}/**/*.h")
end

trees[:sources].each do |s|
  must_include += Dir.glob("#{s.clean_path}/**/*.c")
end

puts "Could include:\n\n#{could_include}\n\n"
puts "Must include:\n\n#{must_include}\n\n"

# Walk --headers and --src trees, making sets and alphabetical
# (including subdir prefix) lists of all files referenced.

# FIXME: Make this work on non-POSIX systems, to be nice.
# The main/only issue here is that I'm hardcoding path
# separator.

all_paths = [could_include, must_include].flatten
paths_avail = Set.new(all_paths)

path_index = Hash.new { |h, k| h[k] = [].to_set }
all_paths.each do |p|
  c = ''
  while p do
    path_index[p].add(c)
    t, p = p.split('/', 2)
    c = c != '' ? c.concat('/', t) : t
  end
end

puts path_index

paths_seen = Set.new

# Write initial file header, version, copyright, etc.

# Include all --headers files, using process described below.

# Include all source files, using process described below.

# When including files:
#   - If an include statement has not yet been encountered:
#       - If we have a file to include in our trees, include it inline
#         if it has not been marked as included in our hash under some
#         other path prefix.
#       - Else, leave the include statement.
#   - Else, comment out include statement.
#   - Just before a file is included, a comment header indicating the
#     path of the file, relative to root, should appear. After the full
#     text of the file has been included, another comment indicating
#     the end of the file should appear.
#   - Add included file path to list of seen includes and also
#     mark as seen in our hash.

# Potential challenge:
#   - The following two include statements reference the same file:
#       - From foo/bar.c, #include "bas/quux.h"
#       - From foo/bas/quuz.c, #include "quux.h"
#     Beyond that, this tool doesn't really know what directories are
#     being searched for headers in general.
# Possible solutions:
#   - Do as gcc would and implicitly realize that for a file in some
#     given directory, an include statement searches in subdirectories
#     of that directory (as well as that current directory)
#     automatically when the appropriate prefix is specified. In
#     theory, it shouldn't be terribly difficult to keep track of
#     whether files in trees we're managing at least have already been
#     included.
#   - Simply don't handle this correctly.
