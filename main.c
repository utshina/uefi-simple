/*
 * UEFI:SIMPLE - UEFI development made easy
 * Copyright ©️ 2014-2023 Pete Batard <pete@akeo.ie> - Public Domain
 * See COPYING for the full licensing terms.
 */
#include <efi.h>
#include <efilib.h>
#include <libsmbios.h>

#if defined(_M_X64) || defined(__x86_64__)
static CHAR16* ArchName = L"x86 64-bit";
#elif defined(_M_IX86) || defined(__i386__)
static CHAR16* ArchName = L"x86 32-bit";
#elif defined (_M_ARM64) || defined(__aarch64__)
static CHAR16* ArchName = L"ARM 64-bit";
#elif defined (_M_ARM) || defined(__arm__)
static CHAR16* ArchName = L"ARM 32-bit";
#elif defined (_M_RISCV64) || (defined(__riscv) && (__riscv_xlen == 64))
static CHAR16* ArchName = L"RISC-V 64-bit";
#else
#  error Unsupported architecture
#endif

// Tri-state status for Secure Boot: -1 = Setup, 0 = Disabled, 1 = Enabled
INTN SecureBootStatus = 0;

/*
 * Query SMBIOS to display some info about the system hardware and UEFI firmware.
 * Also display the current Secure Boot status.
 */
static EFI_STATUS PrintSystemInfo(VOID)
{
	EFI_STATUS Status;
	SMBIOS_STRUCTURE_POINTER Smbios;
	SMBIOS_STRUCTURE_TABLE* SmbiosTable;
	SMBIOS3_STRUCTURE_TABLE* Smbios3Table;
	UINT8 Found = 0, * Raw, * SecureBoot, * SetupMode;
	UINTN MaximumSize, ProcessedSize = 0;

	Print(L"UEFI v%d.%d (%s, 0x%08X)\n", gST->Hdr.Revision >> 16, gST->Hdr.Revision & 0xFFFF,
		gST->FirmwareVendor, gST->FirmwareRevision);

	Status = LibGetSystemConfigurationTable(&SMBIOS3TableGuid, (VOID**)&Smbios3Table);
	if (Status == EFI_SUCCESS) {
		Smbios.Hdr = (SMBIOS_HEADER*)Smbios3Table->TableAddress;
		MaximumSize = (UINTN)Smbios3Table->TableMaximumSize;
	} else {
		Status = LibGetSystemConfigurationTable(&SMBIOSTableGuid, (VOID**)&SmbiosTable);
		if (EFI_ERROR(Status))
			return EFI_NOT_FOUND;
		Smbios.Hdr = (SMBIOS_HEADER*)(UINTN)SmbiosTable->TableAddress;
		MaximumSize = (UINTN)SmbiosTable->TableLength;
	}

	while ((Smbios.Hdr->Type != 0x7F) && (Found < 2)) {
		Raw = Smbios.Raw;
		if (Smbios.Hdr->Type == 0) {
			Print(L"%a %a\n", LibGetSmbiosString(&Smbios, Smbios.Type0->Vendor),
				LibGetSmbiosString(&Smbios, Smbios.Type0->BiosVersion));
			Found++;
		}
		if (Smbios.Hdr->Type == 1) {
			Print(L"%a %a\n", LibGetSmbiosString(&Smbios, Smbios.Type1->Manufacturer),
				LibGetSmbiosString(&Smbios, Smbios.Type1->ProductName));
			Found++;
		}
		LibGetSmbiosString(&Smbios, -1);
		ProcessedSize += (UINTN)Smbios.Raw - (UINTN)Raw;
		if (ProcessedSize > MaximumSize) {
			Print(L"%EAborting system report due to noncompliant SMBIOS%N\n");
			return EFI_ABORTED;
		}
	}

	SecureBoot = LibGetVariable(L"SecureBoot", &EfiGlobalVariable);
	SetupMode = LibGetVariable(L"SetupMode", &EfiGlobalVariable);
	SecureBootStatus = ((SecureBoot != NULL) && (*SecureBoot != 0)) ? 1 : 0;
	// You'd expect UEFI platforms to properly clear SetupMode after they
	// installed all the certs... but most of them don't. Hence Secure Boot
	// disabled having precedence over SetupMode. Looking at you OVMF!
	if ((SetupMode != NULL) && (*SetupMode != 0))
		SecureBootStatus *= -1;
	// Wasteful, but we can't highlight "Enabled"/"Setup" from a %s argument...
	if (SecureBootStatus > 0)
		Print(L"Secure Boot status: %HEnabled%N\n");
	else if (SecureBootStatus < 0)
		Print(L"Secure Boot status: %ESetup%N\n");
	else
		Print(L"Secure Boot status: Disabled\n");

	return EFI_SUCCESS;
}

// Application entrypoint (must be set to 'efi_main' for gnu-efi crt0 compatibility)
EFI_STATUS efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
	UINTN Event;

#if defined(_GNU_EFI)
	InitializeLib(ImageHandle, SystemTable);
#endif

	// The platform logo may still be displayed → remove it
	SystemTable->ConOut->ClearScreen(SystemTable->ConOut);

	/*
	 * In addition to the standard %-based flags, Print() supports the following:
	 *   %N       Set output attribute to normal
	 *   %H       Set output attribute to highlight
	 *   %E       Set output attribute to error
	 *   %r       Human readable version of a status code
	 */
	Print(L"\n%H*** UEFI Simple (%s) ***%N\n\n", ArchName);

	PrintSystemInfo();

	Print(L"\n%EPress any key to exit.%N\n");
	SystemTable->ConIn->Reset(SystemTable->ConIn, FALSE);
	SystemTable->BootServices->WaitForEvent(1, &SystemTable->ConIn->WaitForKey, &Event);
#if defined(_DEBUG)
	// If running in debug mode, use the EFI shut down call to close QEMU
	SystemTable->RuntimeServices->ResetSystem(EfiResetShutdown, EFI_SUCCESS, 0, NULL);
#endif

	return EFI_SUCCESS;
}
