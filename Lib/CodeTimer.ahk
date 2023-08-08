; #region:CodeTimer (2035383057)

; #region:Metadata:
; Snippet: CodeTimer;  (v.1.0)
; --------------------------------------------------------------
; Author: CodeKnight
; Source: https://www.autohotkey.com/boards/viewtopic.php?p=316296&sid=c01c43fbcca28736a01cdd9a64214f66#p316296
; (01 Mai 2023)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 23 - Other
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: performance, time
; #endregion:Metadata


; #region:Description:
; approximate measure of how much time has exceeded between two positions in code. Returns an array containing the time expired (in ms), as well as the displayed string.
; #endregion:Description

; #region:Example
; CodeTimer("A timer")
; Sleep 1050
; ; Insert other code between the two function calls
; CodeTimer("A timer")
; 
; #endregion:Example


; #region:Code
CodeTimer(Description,x:=500,y:=500,ClipboardFlag:=0)
{
    Global StartTimer
    If (StartTimer != "")
    {
        FinishTimer := A_TickCount
            , TimedDuration := FinishTimer - StartTimer
            , StartTimer := ""
        If (ClipboardFlag=1) {
            Clipboard.="`n" TimedDuration
        }
        tooltip % String:="Timer " Description "`n" TimedDuration " ms have elapsed!",% x,% y
        Return [TimedDuration,String]
    } Else {
        StartTimer := A_TickCount
    }
    return
}
; #endregion:Code



; #endregion:CodeTimer (2035383057)
