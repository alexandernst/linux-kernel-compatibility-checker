What is LKCC?
=======

LKCC is a tool that will make use of [ACC](https://github.com/lvc/abi-compliance-checker)
and [AD](https://github.com/lvc/abi-dumper), both made by [lvc](https://github.com/lvc)
(Andrey Ponomarenko), to generate reports for ```ABI``` and ```API``` compatibility for
all the kernels in ```kernel.org```.

This is still a WIP, currently only dumps are generated and only kernel 3.0+ are supported.

Setup LKCC
=======

You're not required to do anything at all! Just run the script and it will do everything automatically.
Oh well, maybe the only thing you'll need to do is compile the vtable dumper inside the `bin` folder.