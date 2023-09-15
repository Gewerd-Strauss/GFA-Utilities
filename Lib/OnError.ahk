
MyErrorHandler(oError) {
    global guiObject
    static errorlog_path
    static init := MyErrorHandler(false)
    if (!oError && !IsSet(init)) {
        elp:=A_ScriptDir "\Errorlog.txt"
        OnError(A_ThisFunc, 1)
        FileDelete % elp
        errorlog_path:=elp
        return true
    }
    message := "Error: " oError.Message "`n`n"
    if (oError.HasKey("Extra") && oError.Extra != "") {
        message .= "    Specifically: " oError.Extra "`n`n"
    }
    message .= "Call stack:`n"
    loop {
        index := (A_Index * -1) - 1
        stack := Exception("", index)
        if (stack.What = index) {
            break
        }
        message .= Format("`n> {}:{} : [{}]", stack.File, stack.Line, stack.What)
    }
    message .= "`n> Auto-execute" ; `message` will have the format of your choosing
    ;TODO: check listA_.ahk for expressVars to convert this into a populated thingie, then push it into the JSON_DUMP
    Variables:={"Properties":["A_Args","A_WorkingDir","A_InitialWorkingDir","A_ScriptDir","A_ScriptName","A_ScriptFullPath","A_ScriptHwnd","A_LineNumber","A_LineFile","A_ThisFunc","A_ThisLabel","A_AhkVersion","A_AhkPath","A_IsUnicode","A_IsCompiled","A_ExitReason"]
            , "Date and Time":["A_YYY","A_MM","A_DD","A_MMMM","A_MMM","A_DDDD","A_DDD","A_WDay","A_YDay","A_YWeek","A_Hour","A_Min","A_Sec","A_MSec","A_Now","A_NowUTC","A_TickCount"]
            ,"Script Settings":["A_IsSuspended","A_IsPaused","A_IsCritical","A_BatchLines","A_ListLines","A_TitleMatchMode","A_TitleMatchModeSpeed","A_DetectHiddenWindows","A_DetectHiddenText","A_AutoTrim","A_StringCaseSense","A_FileEncoding","A_FormatInteger","A_FormatFloat","A_SendMode","A_SendLevel","A_StoreCapsLockMode","A_KeyDelay","A_KeyDuration","A_KeyDelayPlay","A_KeyDurationPlay","A_WinDelay","A_ControlDelay","A_MouseDelay","A_MouseDelayPlay","A_DefaultMouseSpeed","A_CoordModeToolTip","A_CoordModePixel","A_CoordModeMouse","A_CoordModeCaret","A_CoordModeMenu","A_RegView","A_IconHidden","A_IconTip","A_IconFile","A_IconNumber"]
            , "User Idle Time":["A_TimeIdle","A_TimeIdlePhysical","A_TimeIdleKeyboard","A_TimeIdleMouse"]
            , "GUI Windows an Menu Bars":["A_DefaultGUI","A_DefaultListView","A_DefaultTreeView","A_Gui","A_GuiControl","A_GuiWidth","A_GuiHeight","A_GuiX","A_GuiY","A_GuiEvent","A_GuiControlEvent","A_EventInfo"]
            ,"Hotkeys,Hotstrings, Custom Menu items":["A_ThisMenuItem","A_ThisMenu","A_ThisMenuItemPos","A_ThisHotkey","A_PriorHotkey","A_PriorKey","A_TimeSinceThisHotkey","A_TimeSincePriorHotkey","A_EndChar"]
            ,"Operating System and User Info":["A_ComSpec","A_Temp","A_OSType","A_OSVersion","A_Is64bitOS","A_PtrSize","A_Language","A_ComputerName","A_UserName","A_WinDir","A_ProgramFiles","A_AppData","A_AppDataCommon","A_Desktop","A_DesktopCommon", stopped here]}   
    Vars:=ExpressVariables(Variables)
    JSON_DUMP:=JSON.Dump({ZZZ000_Arguments:guiObject.dynGUI.Arguments
            ,RCode_Template:guiObject.RCodeTemplate
            ,Configurator_Settings:script.config.Configurator_settings
            ,Renamer_Settings:script.config.GFA_Renamer_settings
            ,Version:script.version
            ,AHK_Environment:Vars
            ,confVersion:script.config.Version}, pretty := 1)
    if A_IsCompiled {
        a:=((script.config.Configurator_settings.bDebugSwitch || globalLogicSwitches.bIsDebug)?JSON_DUMP:"JSON NOT DUMPED")
        FileAppend % message "`n`n" a, % errorlog_path
        AppError("",  message "`n`nThis error has been saved to the file '" errorlog_path "'")

    } else {
        if (IsDebug()) {
            a:=((script.config.Configurator_settings.bDebugSwitch || globalLogicSwitches.bIsDebug)?JSON_DUMP:"JSON NOT DUMPED")
            FileAppend % message "`n`n" a, *       ; throow to the db-console

        } else {
            AppError("",  message "`n`nThis error has been saved to the file '" errorlog_path "'")
            a:=((script.config.Configurator_settings.bDebugSwitch || globalLogicSwitches.bIsDebug)?JSON_DUMP:"JSON NOT DUMPED")
            FileAppend % message "`n`n" a, % errorlog_path
        }
    }
    return true                   ; Exit thread, prevent standard Exception thrown
}
ExpressVariables(Variables) {
    Obj:={}
    for sec_id,section in Variables {
        Obj[sec_id]:={}
        for var_id, variable in Variables[sec_id] {
            Obj[sec_id][variable]:=a:=Deref("%" variable "%")
        }
    }
    return Obj
}


/*
fonError(DebugState) {

if (DebugState) {
msgbox % DebugState " Encountered error"
}
; TODO: write in extensive CodeTimer-calls for every step, push all times and their names to an array
; and write that to the log when the program exits
; or encounters an error
}
If for example, in the very first lines of your script, you add an include to the
error handler as follows:

;#Include <MyErrorHandler>
; Or
;#Include path\to\MyErrorHandler.ahk

And the function is written like this:

MyErrorHandler(oError) {
static init := MyErrorHandler(false)
if (!oError && !IsSet(init)) {
OnError(A_ThisFunc, 1)
return true
}
; Rest of the function here
}

That will auto-load the function as the error handler and every error will pass
through that function.

More than obvious that the function/lib can be named anything, this name is just
me and my severe lack of ideas on how to name stuff.

main()

Exit ; End of auto-execute

main() {
main_abc()
FileAppend This will never print`n, *
}

main_wvx() {
FileAppend Before 1st exception`n, *
try {
throw Exception("Your error message", , "Your error extra details")
} catch {
FileAppend Code to handle the thrown error`n, *
}
FileAppend After 1st exception`n, *
throw Exception("Your error message", , "Your error extra details")
FileAppend This will never print`n, *
}

main_stu() {
main_wvx()
}

main_pqr() {
main_stu()
}

main_mno() {
main_pqr()
}

main_jkl() {
main_mno()
}

main_ghi() {
main_jkl()
}

main_def() {
main_ghi()
}

main_abc() {
main_def()
}
*/
