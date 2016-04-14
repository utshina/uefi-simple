UEFI:SIMPLE - EFI development made easy
=======================================

A simple UEFI "Hello World!" style application that can:
* be compiled on Windows or Linux (using Visual Studio 2015, MinGW or gcc).
* be compiled for x86_32, x86_64 or ARM targets
* be tested on the fly, through a [QEMU](http://www.qemu.org)+[OVMF](http://tianocore.github.io/ovmf/)
  UEFI virtual machine (x86_32 or x86_64 __ONLY__).

## Prerequisites

* [Visual Studio 2015](http://www.visualstudio.com/products/visual-studio-community-vs)
  or [MinGW](http://www.mingw.org/)/[MinGW64](http://mingw-w64.sourceforge.net/)
  (preferably installed using [msys2](https://sourceforge.net/projects/msys2/))
* [QEMU](http://www.qemu.org)
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

`make TARGET=<target>`

where `target` is one of `ia32` (x86_32), `x64` (x86_64) or `arm`.

You can also add `qemu` as a parameter to run the application in QEMU, in which
case the debug process will download the current version of the EDK2 UEFI
firmware and run your application against it in the QEMU virtual UEFI environment.  
Note that, in case the download fails, you can download the latest from:
http://tianocore.sourceforge.net/wiki/OVMF and extract the `OVMF.fd` as
`OVMF_x86_32.fd` or `OVMF_x86_64.fd` in the top directory.

## Visual Studio and ARM support

To enable ARM compilation in Visual Studio 2015, you must perform the following:
* Make sure Visual Studio is fully closed.
* Navigate to `C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140\Platforms\ARM` and
  remove the read-only attribute on `Platform.Common.props`.
* With a text editor __running with Administrative privileges__ open:  
  `C:\Program Files (x86)\MSBuild\Microsoft.Cpp\v4.0\V140\Platforms\ARM\Platform.Common.props`.
* Under the `<PropertyGroup>` section add the following:  
  `<WindowsSDKDesktopARMSupport>true</WindowsSDKDesktopARMSupport>`
