UEFI:SIMPLE - EFI development made easy
=======================================

A simple UEFI "Hello World!" style application that can:
* be compiled on Windows or Linux, using Visual Studio 2022, MinGW or gcc.
* be compiled for x86_32, x86_64, ARM, ARM64 or RISCV64 targets
* be tested on the fly, through a [QEMU](https://www.qemu.org/) + 
 [OVMF](https://github.com/tianocore/tianocore.github.io/wiki/OVMF) or
 [QEMU_EFI](http://snapshots.linaro.org/components/kernel/leg-virt-tianocore-edk2-upstream/latest/)
 virtual machine.

## Prerequisites

* [Visual Studio 2022](https://www.visualstudio.com/vs/community/) or gcc/make
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

If needed you can also add `ARCH=<arch>` and `CROSS_COMPILE=<tuple>`, e.g.:

* `make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-`
* `make ARCH=aa64 CROSS_COMPILE=aarch64-linux-gnu-`
* `make ARCH=riscv64 CROSS_COMPILE=riscv64-linux-gnu-`

where `<arch>` can be `x64`, `ia32`, `arm`, `aa64` or `riscv64`.

You can also add `qemu` as your `make` target to run the application under QEMU,
in which case a relevant UEFI firmware (OVMF for x86 or QEMU_EFI for Arm) will
be automatically downloaded to run your application against it.

## Visual Studio 2022 and ARM/ARM64 support

Please be mindful that, to enable ARM or ARM64 compilation support in Visual Studio
2022, you __MUST__ go to the _Individual components_ screen in the setup application
and select the ARM/ARM64 build tools there, as they do __NOT__ appear in the default
_Workloads_ screen:

![VS2019 Individual Components](https://files.akeo.ie/pics/VS2019_Individual_Components.png)
