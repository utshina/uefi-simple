UEFI:SIMPLE - UEFI development made easy
========================================

A simple 64bit UEFI application of "Hello World!" which can be:
* compiled on either on Windows or Linux (Visual Studio 2013 or MinGW-w64).
* tested without the need for a separate UEFI environment (QEMU + OVMF)

## Prerequisites

* Visual Studio 2013 or MinGW-w64 (with msys, if using MinGW-w64 on Windows)
* QEMU
* git, wget, unzip

__Note:__ If compiling with Visual Studio, you must first apply 
`gnu-efi-MSVC-fixes.patch` to the `gnu-efi\` repository. I will try to get this
patch integrated into the official gnu-efi tree so that patching can be avoided.


## Sub-Module initialization

For convenience, the project relies on the gnu-efi library (but __not__ on
the gnu-efi compiler itself), so you need to initialize the git submodules:
```
git submodule init
git submodule update
```

## Compilation and testing

Issue the following to compile the application and test it in QEMU:

`make qemu`

The Makefile will download the current version of the EDK2 UEFI firmware and run
your application against it in an virtual UEFI environment.
If the download fails, check http://tianocore.sourceforge.net/wiki/OVMF.
