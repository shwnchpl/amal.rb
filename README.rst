amal.rb
=======

A simple tool to generate amalgamated C source files, inspired by the
SQLite amalgamation.

Usage
-----

Usage::

  $ amal.rb --headers ./include --src ./src

Output::

  [an amalgamated C source file]

Each option may be specified more than once. All C source files ending
in .c in directory trees specified by --src options are included in the
output in lexicographic order based on their fully qualified relative or
absolute path (whichever is specified). All C header files ending in .h
in directory trees specified by --headers are included *before* C source
files in the output, in the same sort of lexicographic order as C source
files. C header files ending in .h found in trees specified by --src are
included if and only if they are referenced in some unconditionally
included file.

It is critical to note that amal.rb makes no effort to understand any
preprocessor directives aside from include statements. This means that
if your include statement is within some sort of ``ifdef`` guard and
meant to only occur when some condition is satisfied, the file will be
included and/or treated as having been included by amal.rb. At this
point, amal.rb will only function correctly in cases where include
directives occur conditionally when those include directives are only
necessary *across the entire project* when the ignored (by amal.rb)
conditions are satisfied. Basically, if you want to use amal.rb, don't
include the same headers conditionally under different conditions (or
conditionally and unconditionally) within the same project. For now, at
least.

Output is dumped to stdout. To write to a file instead, simply redirect
this output.

Why?
----

If it makes sense for SQLite, it may make sense for your project too.
Amalgamated source files are easy to distribute and are easier for some
compilers to optimize (when compared to projects comprised of several
translation units). For more details, see `"The SQLite Amalgamation"
<https: //sqlite.org/amalgamation.html>`_.

Example
-------

For sample input and output, please see the sample directory.

Hacking
-------

Please refer to the ``wip`` branch for detailed (read: sloppy) git
history. The ``master`` branch is comprised exclusively of squashed
commits from the ``wip`` branch. When a "release" is cut, the commit
corresponding to that release in the ``wip`` branch is tagged
``wip-X.Y.Z`` where ``X`` is major version, ``Y`` is minor version, and
``Z`` is subminor version. The associated release on the ``master``
branch is tagged ``release-X.Y.Z``.

Should you wish to submit a pull request, please direct any such request
to the ``wip`` branch. Please also note that all commit titles on this
branch are prefaced with ``WIP:``. Please also feel free to add your
name to the AUTHORS file in the "Contributors" section.

License
-------

amal.rb is the work of Shawn M. Chapla, with contributions from other
contributors as noted in the AUTHORS file, and is released under the MIT
license. For more details, see the LICENSE file.
