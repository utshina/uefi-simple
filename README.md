UEFI:SIMPLE - EFI development made easy
=======================================

A simple UEFI "Hello World!" style application that can:
* be compiled on Windows or Linux (using Visual Studio 2015, MinGW or gcc).
* be compiled for x86_32, x86_64 or ARM targets
* be tested on the fly, through a [QEMU](http://www.qemu.org)+[OVMF](http://tianocore.github.io/ovmf/)
  UEFI virtual machine.

## Prerequisites

* [Visual Studio 2015](http://www.visualstudio.com/products/visual-studio-community-vs) or gcc/make
* [QEMU](http://www.qemu.org) __v2.5 or later__
  (NB: You can find QEMU Windows binaries [here](https://qemu.weilnetz.de/w64/))
* git
* wget, unzip, if not using Visual Studio

## Sub-Module initialization

For convenience, the project relies on the gnu-efi library (but __not__ on
the gnu-efi compiler itself), so you need to initialize the git submodules:
```
git submodule init
git submodule update
```

## Compilation and testing

If using Visual Studio, just press `F5` to have the application compiled and
launched in the QEMU emulator.

If using MinGW or Linux, issue the following from a command prompt:

`make`

If needed you can also add `ARCH=<arch>` and `CROSS_COMPILE=<tuple>`:

`make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf-`

where `<arch>` can be `x64`, `ia32` or `arm`.

You can also add `qemu` as your `make` target to run the application under QEMU,
in which case a relevant UEFI firmware (OVMF for x86 or QEMU_EFI for ARM) will
be automatically downloaded to run your application against it.

## Visual Studio and ARM support

To enable ARM compilation in Visual Studio 2015, you must perform the following:
* Make sure Visual Studio is fully closed.
* Navigate to `C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140\Platforms\ARM` and
  remove the read-only attribute on `Platform.Common.props`.
* With a text editor __running with Administrative privileges__ open:  
  `C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140\Platforms\ARM\Platform.Common.props`.
* Under the `<PropertyGroup>` section add the following:  
  `<WindowsSDKDesktopARMSupport>true</WindowsSDKDesktopARMSupport>`
