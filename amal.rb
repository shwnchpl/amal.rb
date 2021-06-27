#!/usr/bin/env ruby

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

# Walk --headers and --src trees, making sets and alphabetical
# (including subdir prefix) lists of all files referenced.

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
