What is LKCC?
=======

LKCC is a tool that will make use of [ACC](https://github.com/lvc/abi-compliance-checker)
and [AD](https://github.com/lvc/abi-dumper), both made by [lvc](https://github.com/lvc)
(Andrey Ponomarenko), to generate reports for ```ABI``` and ```API``` compatibility for
all the kernels in ```kernel.org```.

This is still a WIP, currently only dumps are generated and only kernel 3.0+ are supported.

Setup LKCC
=======

First you need to clone both ```ACC``` and ```AD```, then edit ```lkcc.sh``` writing the right paths
for ```ACC``` and ```AD```.