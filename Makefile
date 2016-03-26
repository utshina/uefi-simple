TARGET = x64

ifeq ($(TARGET),x64)
	ARCH          = x86_64
	CROSS_COMPILE = x86_64-w64-mingw32-
	OVMF_ARCH     = X64
	QEMU_ARCH     = x86_64
	EP_PREFIX     =
	CFLAGS        = -m64 -mno-red-zone -fpic
	LDFLAGS	      = -Wl,-dll -Wl,--subsystem,10
else ifeq ($(TARGET),ia32)
	ARCH          = ia32
	CROSS_COMPILE = i686-w64-mingw32-
	OVMF_ARCH     = IA32
	QEMU_ARCH     = i386
	EP_PREFIX     = _
	CFLAGS       = -m32 -mno-red-zone
	LDFLAGS	      = -Wl,-dll -Wl,--subsystem,10
else ifeq ($(TARGET),arm)
	ARCH          = arm
	CROSS_COMPILE = arm-linux-gnueabihf-
	OVMF_ARCH     = ARM
	QEMU_ARCH     = arm
	EP_PREFIX     =
	CFLAGS        = -marm -fpic -fshort-wchar
	LDFLAGS       =
endif

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
# Linker option '--subsystem 10' specifies an EFI application. 
LDFLAGS+= -nostdlib -shared -e $(EP_PREFIX)EfiMain
LIBS   := -L$(GNUEFI_PATH)/$(ARCH)/lib -lgcc -lefi

OVMF_ZIP = OVMF-$(OVMF_ARCH)-r15214.zip

GCCVERSION := $(shell $(CC) -dumpversion | cut -f1 -d.)
GCCMINOR   := $(shell $(CC) -dumpversion | cut -f2 -d.)
GCCNEWENOUGH := $(shell ( [ $(GCCVERSION) -gt "4" ]           \
                          || ( [ $(GCCVERSION) -eq "4" ]      \
                               && [ $(GCCMINOR) -ge "7" ] ) ) \
                        && echo 1)
ifneq ($(GCCNEWENOUGH),1)
  $(error You need GCC 4.7 or later)
endif

.PHONY: all
all: $(GNUEFI_PATH)/$(ARCH)/lib/libefi.a main.efi

$(GNUEFI_PATH)/$(ARCH)/lib/libefi.a:
	$(MAKE) -C$(GNUEFI_PATH) CROSS_COMPILE=$(CROSS_COMPILE) ARCH=$(ARCH) lib

%.efi: %.o $(GNUEFI_PATH)/$(ARCH)/lib/libefi.a
	$(CC) $(LDFLAGS) $< -o $@ $(LIBS)

%.o: %.c
	$(CC) $(CFLAGS) -ffreestanding -c $<

qemu: all OVMF.fd image/efi/boot/boot$(TARGET).efi
	$(QEMU) -bios ./OVMF.fd -net none -hda fat:image

image/efi/boot/boot$(TARGET).efi: main.efi
	mkdir -p image/efi/boot
	cp -f $< $@

OVMF.fd:
	# Use our own mirror, since SourceForge are being such ASSES about direct downloads...
	wget http://efi.akeo.ie/OVMF/$(OVMF_ZIP)
	unzip $(OVMF_ZIP) OVMF.fd
	rm $(OVMF_ZIP)

clean:
	rm -f main.efi *.o
	rm -rf image

superclean: clean
	$(MAKE) -C$(GNUEFI_PATH) clean
	rm -f OVMF.fd
