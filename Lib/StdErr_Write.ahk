; --uID:2565289504
; Metadata:
; Snippet: StdErr_Write()
; --------------------------------------------------------------
; Author: Lexikos
; License: public domain/CC0 if not applicable
; LicenseURL:  https://www.autohotkey.com/board/topic/36032-lexikos-default-copyright-license/
; Source: http://www.autohotkey.com/board/topic/50306-can-a-script-write-to-stderr/?hl=errorstdout#entry314658
; (17 April 2023)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 23 - Other
; Dependencies: StdErr_Write_
; AHK_Version: AHK_L
; --------------------------------------------------------------
; Keywords: stderr, debug

;; Description:
;; write directly to stderr for custom error messages, formatted like normal error messages.

;;; Example:
;;; StdErr_Write(A_LineNumber,"This function needs pairs of parameter.","odd number")
;;;    month<1 || month>12 ? StdErr_Write(A_LineNumber,"The variable month must have a value between 1 and 12.","month := " month)
;;; 

StdErr_Write(LineNumber, text, spec = "") {
    text := A_ScriptFullPath " (" LineNumber ") : ==>  " . text
    text .= spec?"`n     Specifically: " spec "`n":
    if A_IsUnicode
        return StdErr_Write_("astr", text, StrLen(text))
    return StdErr_Write_("uint", &text, StrLen(text))
}
StdErr_Write_(type, data, size) {
    static STD_ERROR_HANDLE := -12
    if (hstderr := DllCall("GetStdHandle", "uint", STD_ERROR_HANDLE)) = -1
        return false
    return DllCall("WriteFile", "uint", hstderr, type, data, "uint", size, "uint", 0, "uint", 0)
}


; License:

; This software is provided 'as-is', without any express or implied warranty. In no event will the authors be held liable for any damages arising from the use of this software.
; 
; Permission is granted to anyone to use this software for any purpose, including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
; [*:17p5ko30]The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.

; --uID:2565289504
