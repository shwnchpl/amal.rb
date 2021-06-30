amal.rb
=======

A simple tool to generate an amalgamated C source file.

Usage
-----

Usage::

  $ amal.rb --headers ./include --src ./src

Output::

  [An amalgamated C source file].

Each option may be specified more than once. All C source files ending
in .c in directory trees specified by --src options are included in the
output in lexicographic order based on their fully qualified relative or
absolute path (whichever is specified). All C header files ending in .h
in directory trees specified by --headers are included *before* C source
files in the output, in the same sort of lexicographic order as C source
files. C header files ending in .h found in trees specified by --src are
included if and only if they are referenced in some unconditionally
included file.

Output is dumped to stdout. To write to a file instead, simply redirect
this output.

Does not currently support C++ source files.

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
