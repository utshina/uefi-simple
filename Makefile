TARGET    = x64
# You can alter the subsystem according to your EFI binary target:
# 10 = EFI application
# 11 = EFI boot service driver
# 12 = EFI runtime driver
SUBSYSTEM = 10

ifeq ($(TARGET),x64)
	ARCH          = x86_64
	GCC_ARCH      = x86_64
	QEMU_ARCH     = x86_64
	CROSS_COMPILE = $(GCC_ARCH)-w64-mingw32-
	EP_PREFIX     =
	CFLAGS        = -m64 -mno-red-zone
	LDFLAGS	      = -Wl,-dll -Wl,--subsystem,$(SUBSYSTEM) -nostdlib
else ifeq ($(TARGET),ia32)
	ARCH          = ia32
	GCC_ARCH      = i686
	QEMU_ARCH     = i386
	CROSS_COMPILE = $(GCC_ARCH)-w64-mingw32-
	EP_PREFIX     = _
	CFLAGS        = -m32 -mno-red-zone
	# Can't use -nostdlib as we're missing an implementation of __umoddi3
	# and __udivdi3, required by ia32/math.c and present in libgcc.a
	LDFLAGS	      = -Wl,-dll -Wl,--subsystem,$(SUBSYSTEM)
else ifeq ($(TARGET),arm)
	ARCH          = arm
	GCC_ARCH      = arm
	QEMU_ARCH     = arm
	CROSS_COMPILE = $(GCC_ARCH)-linux-gnueabihf-
	EP_PREFIX     =
	CFLAGS        = -marm -fpic -fshort-wchar
	LDFLAGS       = -Wl,--no-wchar-size-warning -Wl,--subsystem,$(SUBSYSTEM) -nostdlib
endif
OVMF_ARCH       = $(shell echo $(TARGET) | tr a-z A-Z)

# Set parameters according to our platform
ifeq ($(SYSTEMROOT),)
  QEMU = qemu-system-$(QEMU_ARCH) -nographic
else
  QEMU = "/c/Program Files/qemu/qemu-system-$(QEMU_ARCH)w.exe"
  CROSS_COMPILE =
endif
GNUEFI_PATH = $(CURDIR)/gnu-efi

CC     := $(CROSS_COMPILE)gcc
CFLAGS += -fno-stack-protector -Wshadow -Wall -Wunused -Werror-implicit-function-declaration
CFLAGS += -I$(GNUEFI_PATH)/inc -I$(GNUEFI_PATH)/inc/$(ARCH) -I$(GNUEFI_PATH)/inc/protocol
LDFLAGS+= -shared -e $(EP_PREFIX)EfiMain
LIBS   := -L$(GNUEFI_PATH)/$(ARCH)/lib -lefi

OVMF_ZIP = OVMF-$(OVMF_ARCH)-r15214.zip

ifeq (, $(shell which $(CC)))
  $(error The selected compiler ($(CC)) was not found)
endif

GCCVERSION := $(shell $(CC) -dumpversion | cut -f1 -d.)
GCCMINOR   := $(shell $(CC) -dumpversion | cut -f2 -d.)
GCCMACHINE := $(shell $(CC) -dumpmachine)
GCCNEWENOUGH := $(shell ( [ $(GCCVERSION) -gt "4" ]           \
                          || ( [ $(GCCVERSION) -eq "4" ]      \
                              && [ $(GCCMINOR) -ge "7" ] ) )  \
                        && echo 1)
ifneq ($(GCCNEWENOUGH),1)
  $(error You need GCC 4.7 or later)
endif

ifneq ($(GCC_ARCH),$(findstring $(GCC_ARCH), $(GCCMACHINE)))
  $(error The selected compiler ($(CC)) is not set for $(TARGET))
endif

.PHONY: all clean superclean
all: $(GNUEFI_PATH)/$(ARCH)/lib/libefi.a main.efi

$(GNUEFI_PATH)/$(ARCH)/lib/libefi.a:
	$(MAKE) -C$(GNUEFI_PATH) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) lib

%.efi: %.o $(GNUEFI_PATH)/$(ARCH)/lib/libefi.a
	@echo  [LD]  $(notdir $@)
	@$(CC) $(LDFLAGS) $< -o $@ $(LIBS)

%.o: %.c
	@echo  [CC]  $(notdir $@)
	@$(CC) $(CFLAGS) -ffreestanding -c $<

qemu: CFLAGS += -D_DEBUG
qemu: all OVMF_$(OVMF_ARCH).fd image/efi/boot/boot$(TARGET).efi
	$(QEMU) -bios ./OVMF_$(OVMF_ARCH).fd -net none -hda fat:image

image/efi/boot/boot$(TARGET).efi: main.efi
	mkdir -p image/efi/boot
	cp -f $< $@

OVMF_$(OVMF_ARCH).fd:
	wget http://efi.akeo.ie/OVMF/$(OVMF_ZIP)
	unzip $(OVMF_ZIP) OVMF.fd
	mv OVMF.fd OVMF_$(OVMF_ARCH).fd
	rm $(OVMF_ZIP)

clean:
	rm -f main.efi *.o
	rm -rf image

superclean: clean
	$(MAKE) -C$(GNUEFI_PATH) clean
	rm -f *.fd
