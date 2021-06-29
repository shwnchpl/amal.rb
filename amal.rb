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

trees = Hash.new {|h, k| h[k] = []}

ARGV << '--help' if ARGV.empty?

class String
  def clean_path
    self.delete_prefix('./').chomp('/')
  end
end

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
    trees[:headers].append headers.clean_path
  end

  opts.on("--src SOURCE", "Include all sources in a tree.") do |source|
    if not Dir.exist? source
      $stderr.puts "'#{source}' is not a valid directory."
      exit -1
    end
    trees[:sources].append source.clean_path
  end
end.parse!

# TODO: Is there a cleaner way to do this?
# TODO: Should I even be using a hash map for these few options?

could_include = []
trees[:sources].each do |h|
  could_include += Dir.glob("#{h}/**/*.h")
end

must_include = []
trees[:headers].each do |h|
  must_include += Dir.glob("#{h}/**/*.h")
end

trees[:sources].each do |s|
  must_include += Dir.glob("#{s}/**/*.c")
end

# Walk --headers and --src trees, making sets and alphabetical
# (including subdir prefix) lists of all files referenced.

# FIXME: Make this work on non-POSIX systems, to be nice.
# The main/only issue here is that I'm hardcoding path
# separator.

paths_avail = Hash[(could_include + must_include).collect {|p| [p, true]}]

def include_path(pa, ht, p)
  context, _, file = p.rpartition('/')
  pa[p] = false
  puts "/******* BEGIN FILE #{p} *******/"
  File.foreach(p) do |line|
    # FIXME: This will break on comments after include directives.
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
    paths_avail = include_path(paths_avail, trees[:headers], p)
  end
end

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
