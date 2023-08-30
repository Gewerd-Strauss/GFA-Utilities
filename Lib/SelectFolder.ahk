; #region:SelectFolder (2939428128)

; #region:Metadata:
; Snippet: SelectFolder;  (v.1.0.1)
; --------------------------------------------------------------
; Author: JayC_
; Source: https://www.autohotkey.com/boards/viewtopic.php?f=76&t=120019&p=532694&hilit=select+folder#p532681
; (30 August 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: FileSelectFolder, Folder
; #endregion:Metadata


; #region:Description:
; Modern folder-select dialogue visually similar to the "Save File as"-Dialogue, allows setting the dialogue's start directory
; #endregion:Description

; #region:Example
; SelectFolder(A_Desktop,"Select a folder on the desktop, or elsewhere")
; #endregion:Example


; #region:Code
SelectFolder(StartingFolder:="", Prompt:="", GuiHwnd:=0, ButtonLabel:="", Options:=0x2002028) {
    OSVersion := DllCall("GetVersion") & 0xFFFF
    if (OSVersion <= 6) {																								; IFileDialog req Vista(+). Vista is 6
        FileSelectFolder SelectedFolder, % StartingFolder, 3, % Prompt
        if ErrorLevel																									; If cancel, exit
            return
        return SelectedFolder
    }
    IFileDialog := ComObjCreate("{DC1C5A9C-E88A-4dde-A5A1-60F82A20AEF7}", "{42f85136-db7e-439c-85f1-e4075d135fc8}")
    vtable := NumGet(IFileDialog + 0)
    if ((StartingFolder != "") && FileExist(StartingFolder)) {															; If the directory exists and starting folder parameter is used
        VarSetCapacity(IID_IShellItem, 16, 0)
        DllCall("Ole32.dll\IIDFromString", "WStr", "{43826d1e-e718-42ee-bc55-a1e261c37bfe}", "Ptr", &IID_IShellItem := 0)
        DllCall("Shell32.dll\SHCreateItemFromParsingName", "WStr", StartingFolder, "Ptr", 0, "Ptr", &IID_IShellItem, "Ptr*", DefaultPath)
        DllCall(NumGet(vtable + 0, 12 * A_PtrSize), "Ptr", IFileDialog, "Ptr", DefaultPath)								; SetFolder offset = 12
    }
    if (ButtonLabel != "")
        DllCall(NumGet(vtable + 0, 18 * A_PtrSize), "Ptr", IFileDialog, "WStr", ButtonLabel)							; SetOkButtonLabel offset = 18
    if (Prompt != "")
        DllCall(NumGet(vtable + 0, 17 * A_PtrSize), "Ptr", IFileDialog, "WStr", Prompt)									; SetTitle offset = 17
    if ((GuiHwnd != 0) && !WinExist("ahk_id" GuiHwnd))																	; Check if Hwnd isn't empty and exists. If not pass null
        GuiHwnd := 0
    DllCall(NumGet(vtable + 0, 9 * A_PtrSize), "Ptr", IFileDialog, "Uint", Options)										; https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/ne-shobjidl_core-_fileopendialogoptions Defaults: FOS_DONTADDTORECENT|FOS_PICKFOLDERS|FOS_NOCHANGEDIR|FOS_CREATEPROMPT
    DllCall(NumGet(vtable + 0, 3 * A_PtrSize), "Ptr", IFileDialog, "Ptr", GuiHwnd)										; Show offset = 3
    DllCall(NumGet(vtable + 0, 20 * A_PtrSize), "Ptr", IFileDialog, "Ptr*", ResultPath) 								; GetResult offset = 20
    DllCall(NumGet(NumGet(ResultPath + 0) + 0, 5 * A_PtrSize), "Ptr", ResultPath, "Uint", 0x80058000, "Ptr*", sPtr)		; GetDisplayName offset = 5 | SIGDN_FILESYSPATH
    SelectedFolder := StrGet(sPtr, "UTF-16")
    DllCall("Ole32.dll\CoTaskMemFree", "Ptr", sPtr)
    if (DefaultPath)
        ObjRelease(DefaultPath)
    ObjRelease(ResultPath)
    ObjRelease(IFileDialog)
    if (SelectedFolder != "")
        return SelectedFolder
    return
}
; #endregion:Code



; #endregion:SelectFolder (2939428128)
