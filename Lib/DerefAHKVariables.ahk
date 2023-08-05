DerefAHKVariables(String) {
    AHKVARIABLES := { "A_ScriptDir": A_ScriptDir, "A_ScriptName": A_ScriptName, "A_ScriptFullPath": A_ScriptFullPath, "A_ScriptHwnd": A_ScriptHwnd, "A_LineNumber": A_LineNumber, "A_LineFile": A_LineFile, "A_ThisFunc": A_ThisFunc, "A_ThisLabel": A_ThisLabel, "A_AhkVersion": A_AhkVersion, "A_AhkPath": A_AhkPath, "A_IsUnicode": A_IsUnicode, "A_IsCompiled": A_IsCompiled, "A_ExitReason": A_ExitReason, "A_YYYY": A_YYYY, "A_MM": A_MM, "A_DD": A_DD, "A_MMMM": A_MMMM, "A_MMM": A_MMM, "A_DDDD":A_DDDD,"A_DDD":A_DDD,"A_WDay":A_WDay,"A_YDay":A_YDay,"A_YWeek":A_YWeek,"A_Hour":A_Hour,"A_Min":A_Min,"A_Sec":A_Sec,"A_MSec":A_MSec,"A_Now":A_Now,"A_NowUTC":A_NowUTC,"A_TickCount":A_TickCount,"A_IsSuspended":A_IsSuspended,"A_IsPaused":A_IsPaused,"A_IsCritical":A_IsCritical,"A_BatchLines":A_BatchLines,"A_ListLines":A_ListLines,"A_TitleMatchMode":A_TitleMatchMode,"A_TitleMatchModeSpeed":A_TitleMatchModeSpeed,"A_DetectHiddenWindows":A_DetectHiddenWindows,"A_DetectHiddenText":A_DetectHiddenText,"A_AutoTrim":A_AutoTrim,"A_StringCaseSense":A_StringCaseSense,"A_FileEncoding":A_FileEncoding,"A_FormatInteger":A_FormatInteger,"A_FormatFloat":A_FormatFloat,"A_SendMode":A_SendMode,"A_SendLevel":A_SendLevel,"A_StoreCapsLockMode":A_StoreCapsLockMode,"A_KeyDelay":A_KeyDelay,"A_KeyDuration":A_KeyDuration,"A_KeyDelayPlay":A_KeyDelayPlay,"A_KeyDurationPlay":A_KeyDurationPlay,"A_WinDelay":A_WinDelay,"A_ControlDelay":A_ControlDelay,"A_MouseDelay":A_MouseDelay,"A_MouseDelayPlay":A_MouseDelayPlay,"A_DefaultMouseSpeed":A_DefaultMouseSpeed,"A_CoordModeToolTip":A_CoordModeToolTip,"A_CoordModePixel":A_CoordModePixel,"A_CoordModeMouse":A_CoordModeMouse,"A_CoordModeCaret":A_CoordModeCaret,"A_CoordModeMenu":A_CoordModeMenu,"A_RegView":A_RegView,"A_IconHidden":A_IconHidden,"A_IconTip":A_IconTip,"A_IconFile":A_IconFile,"A_IconNumber":A_IconNumber,"A_TimeIdle":A_TimeIdle,"A_TimeIdlePhysical":A_TimeIdlePhysical,"A_TimeIdleKeyboard":A_TimeIdleKeyboard,"A_TimeIdleMouse":A_TimeIdleMouse,"A_DefaultGUI":A_DefaultGUI,"A_DefaultListView":A_DefaultListView,"A_DefaultTreeView":A_DefaultTreeView,"A_Gui":A_Gui,"A_GuiControl":A_GuiControl,"A_GuiWidth":A_GuiWidth,"A_GuiHeight":A_GuiHeight,"A_GuiX":A_GuiX,"A_GuiY":A_GuiY,"A_GuiEvent":A_GuiEvent,"A_GuiControlEvent":A_GuiControlEvent,"A_EventInfo":A_EventInfo,"A_ThisMenuItem":A_ThisMenuItem,"A_ThisMenu":A_ThisMenu,"A_ThisMenuItemPos":A_ThisMenuItemPos,"A_ThisHotkey":A_ThisHotkey,"A_PriorHotkey":A_PriorHotkey,"A_PriorKey":A_PriorKey,"A_TimeSinceThisHotkey":A_TimeSinceThisHotkey,"A_TimeSincePriorHotkey":A_TimeSincePriorHotkey,"A_EndChar":A_EndChar,"A_ComSpec":A_ComSpec,"A_Temp":A_Temp,"A_OSType":A_OSType,"A_OSVersion":A_OSVersion,"A_Is64bitOS":A_Is64bitOS,"A_PtrSize":A_PtrSize,"A_Language":A_Language,"A_ComputerName":A_ComputerName,"A_UserName":A_UserName,"A_WinDir":A_WinDir,"A_ProgramFiles":A_ProgramFiles,"A_AppData":A_AppData,"A_AppDataCommon":A_AppDataCommon,"A_Desktop":A_Desktop,"A_DesktopCommon":A_DesktopCommon,"A_DesktopCommon":A_DesktopCommon}
    return Deref_FormatEx(String, AHKVARIABLES)
}

Deref_FormatEx(FormatStr, Values*) {
    replacements := []
    clone := Values.Clone()
    for i, part in clone
        IsObject(part) ? clone[i] := "" : Values[i] := {}
    FormatStr := Format(FormatStr, clone*)
    index := 0
    replacements := []
    for _, part in Values {
        for search, replace in part {
            replacements.Push(replace)
            FormatStr := StrReplace(FormatStr, "{" search "}", "{"++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}
