' Visual Studio QEMU debugging script.
'
' I like invoking vbs as much as anyone else, but we need to download and unzip our
' EFI BIOS file, as well as launch QEMU, and neither Powershell or a standard batch
' can do that without having an extra console appearing.
'
' Note: You may get a prompt from the firewall when trying to download the BIOS file

' Modify these variables if needed
OVMF_ZIP   = "OVMF-X64-r15214.zip"
OVMF_BIOS  = "OVMF.fd"
FTP_SERVER = "ftp.heanet.ie"
FTP_FILE   = "pub/download.sourceforge.net/pub/sourceforge/e/ed/edk2/OVMF/" & OVMF_ZIP
FTP_URL    = "ftp://" & FTP_SERVER & "/" & FTP_FILE

' Globals
Set fso = CreateObject("Scripting.FileSystemObject") 
Set shell = CreateObject("WScript.Shell")

Sub DownloadBios()
  Set file = fso.CreateTextFile("ftp.txt", True)
  Call file.Write("open " & FTP_SERVER & vbCrLf &_
    "anonymous" & vbCrLf & "user" & vbCrLf & "bin" & vbCrLf &_
    "get " & FTP_FILE & vbCrLf & "bye" & vbCrLf)
  Call file.Close()
  Call shell.Run("%comspec% /c ftp -s:ftp.txt > NUL", 0, True)
  Call fso.DeleteFile("ftp.txt")
End Sub

Sub UnzipBios()
  Const NOCONFIRMATION = &H10&
  Const NOERRORUI = &H400&
  Const SIMPLEPROGRESS = &H100&
  unzipFlags = NOCONFIRMATION + NOERRORUI + SIMPLEPROGRESS

  Set objShell = CreateObject("Shell.Application")
  Set objSource = objShell.NameSpace(fso.GetAbsolutePathName(OVMF_ZIP)).Items()
  Set objTarget = objShell.NameSpace(fso.GetAbsolutePathName("."))
  ' Only extract the filw we are interested in
  For i = 0 To objSource.Count - 1
    If objSource.Item(i).Name = OVMF_BIOS Then
      Call objTarget.CopyHere(objSource.Item(i), unzipFlags)
    End If
  Next
End Sub

' Retrieve the UEFI BIOS from ftp and unzip it
If Not fso.FileExists(OVMF_BIOS) Then
  Call WScript.Echo("The latest OVMF BIOS file, needed for QEMU/EFI, " &_
   "will be downloaded from: " & FTP_URL & vbCrLf & vbCrLf &_
   "Note: Unless you delete the file, this should only happen once.")
  Call DownloadBIOS()
  Call UnzipBios()
  Call fso.DeleteFile(OVMF_ZIP)
End If

' Copy the latest build and run it in QEMU
Call shell.Run("%COMSPEC% /c mkdir ""image\\efi\\boot""", 0, True)
Call fso.CopyFile(WScript.Arguments(0), "image\\efi\\boot\\bootx64.efi", True)
Call shell.Run("""C:\\Program Files\\qemu\\qemu-system-x86_64w.exe"" -L . -bios OVMF.fd -hda fat:image", 1, True)
