# APlug

Port of the LADSPA 1.1.1 API for Ada 2012. Doesn't do much at this time but does show up in Carla.

![Carla](./screenshots/carla.png)

# Building

## GNAT

```bash
$ git clone git@github.com:Lucretia/aplug.git
$ cd aplug/build/gnat
$ gprbuild -P amp.gpr -p
```

# Dependencies

Ada 2012 compiler.

## Tested with

FSF GNAT 9.2.0

# Copyright

Copyright (C) 2019 by Luke A. Guest

# Licence

New-style BSD, see LICENCE file in source root directory and at the start of all source files.
