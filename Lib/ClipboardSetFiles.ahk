; #region:ClipboardSetFiles() (887366420)

; #region:Metadata:
; Snippet: ClipboardSetFiles()
; --------------------------------------------------------------
; Author: just me
; License: Unlicense
; Source: https://www.autohotkey.com/boards/viewtopic.php?p=63914#p63914
; (19 April 2023)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 19 - Clipboard
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Explorer function for Drag&Drop and Pasting. Enables the explorer paste context menu option.
; 
; 
; #endregion:Description

; #region:Example
; #NoEnv
; ; Retrieve files in a certain directory sorted by modification date:
; FileList :=  "" ; Initialize to be blank
; ; Create a list of those files consisting of the time the file was modified and the file path separated by tab
; Loop, %A_MyDocuments%\*.*
;    FileList .= A_LoopFileTimeModified . "`t" . A_LoopFileLongPath . "`n"
; Sort, FileList, R  ;   ; Sort by time modified in reverse order
; Loop, Parse, FileList, `n
; {
;    If (A_LoopField = "") ; omit the last linefeed (blank item) at the end of the list.
;       Continue
;    StringSplit, FileItem, A_LoopField, %A_Tab%  ; Split into two parts at the tab char
;    ; FileItem1 is FileTimeModified und FileItem2 is FileName
;    MsgBox, 36, Last modified file, %FileItem1% - %FileItem2%`n`nDo you want to continue?
;    IfMsgBox, Yes
;       ClipBoardSetFiles(FileItem2)
;    Break
; }
; ExitApp
; #endregion:Example


; #region:Code
ClipboardSetFiles(FilesToSet, DropEffect := "Copy") {
   ; FilesToSet - list of fully qualified file pathes separated by "`n" or "`r`n"
   ; DropEffect - preferred drop effect, either "Copy", "Move" or "" (empty string)
   Static TCS := A_IsUnicode ? 2 : 1 ; size of a TCHAR
   Static PreferredDropEffect := DllCall("RegisterClipboardFormat", "Str", "Preferred DropEffect")
   Static DropEffects := {1: 1, 2: 2, Copy: 1, Move: 2}
   ; -------------------------------------------------------------------------------------------------------------------
   ; Count files and total string length
   TotalLength := 0
   FileArray := []
   Loop, Parse, FilesToSet, `n, `r
   {
      If (Length := StrLen(A_LoopField))
         FileArray.Push({Path: A_LoopField, Len: Length + 1})
      TotalLength += Length
   }
   FileCount := FileArray.Length()
   If !(FileCount && TotalLength)
      Return False
   ; -------------------------------------------------------------------------------------------------------------------
   ; Add files to the clipboard
   If DllCall("OpenClipboard", "Ptr", A_ScriptHwnd) && DllCall("EmptyClipboard") {
      ; HDROP format ---------------------------------------------------------------------------------------------------
      ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
      hDrop := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 20 + (TotalLength + FileCount + 1) * TCS, "UPtr")
      pDrop := DllCall("GlobalLock", "Ptr" , hDrop)
      Offset := 20
      NumPut(Offset, pDrop + 0, "UInt")         ; DROPFILES.pFiles = offset of file list
      NumPut(!!A_IsUnicode, pDrop + 16, "UInt") ; DROPFILES.fWide = 0 --> ANSI, fWide = 1 --> Unicode
      For Each, File In FileArray
         Offset += StrPut(File.Path, pDrop + Offset, File.Len) * TCS
      DllCall("GlobalUnlock", "Ptr", hDrop)
      DllCall("SetClipboardData","UInt", 0x0F, "UPtr", hDrop) ; 0x0F = CF_HDROP
      ; Preferred DropEffect format ------------------------------------------------------------------------------------
      If (DropEffect := DropEffects[DropEffect]) {
         ; Write Preferred DropEffect structure to clipboard to switch between copy/cut operations
         ; 0x42 = GMEM_MOVEABLE (0x02) | GMEM_ZEROINIT (0x40)
         hMem := DllCall("GlobalAlloc", "UInt", 0x42, "UInt", 4, "UPtr")
         pMem := DllCall("GlobalLock", "Ptr", hMem)
         NumPut(DropEffect, pMem + 0, "UChar")
         DllCall("GlobalUnlock", "Ptr", hMem)
         DllCall("SetClipboardData", "UInt", PreferredDropEffect, "Ptr", hMem)
      }
      DllCall("CloseClipboard")
      Return True
   }
   Return False
}
; #endregion:Code



; #endregion:ClipboardSetFiles() (887366420)
