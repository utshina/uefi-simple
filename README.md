UEFI:SIMPLE - EFI development made easy
=======================================

A simple UEFI "Hello World!" style application that can:
* be compiled on Windows or Linux, using Visual Studio 2017 (including CodeGen/Clang support), MinGW or gcc.
* be compiled for x86_32, x86_64, ARM or AARCH64 targets
* be tested on the fly, through a [QEMU](http://www.qemu.org)+[OVMF](http://tianocore.github.io/ovmf/)
  UEFI virtual machine.

## Prerequisites

* [Visual Studio 2017](https://www.visualstudio.com/vs/community/) or gcc/make
* [QEMU](http://www.qemu.org) __v2.7 or later__
  (NB: You can find QEMU Windows binaries [here](https://qemu.weilnetz.de/w64/))
* git
* wget, unzip, if not using Visual Studio

## Sub-Module initialization

For convenience, the project relies on the gnu-efi library, so you need to initialize the git
submodule either through git commandline with:
```
git submodule init
git submodule update
```
Or, if using a UI client (such as TortoiseGit) by selecting _Submodule Update_ in the context menu.

## Compilation and testing

If using Visual Studio, just press `F5` to have the application compiled and
launched in the QEMU emulator.

If using MinGW or Linux, issue the following from a command prompt:

`make`

If needed you can also add `ARCH=<arch>` and `CROSS_COMPILE=<tuple>`:

`make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-`

where `<arch>` can be `x64`, `ia32`, `arm` or `aa64`.

You can also add `qemu` as your `make` target to run the application under QEMU,
in which case a relevant UEFI firmware (OVMF for x86 or QEMU_EFI for Arm) will
be automatically downloaded to run your application against it.

## Visual Studio 2017 and ARM support

Since Microsoft, in their great wisdom, decided to remove ARM compilation from
the VS2017 native tools, ARM support is only available with CodeGen/Clang.
To compile for ARM, you must therefore use the `uefi-simple (Clang).sln` solution.
