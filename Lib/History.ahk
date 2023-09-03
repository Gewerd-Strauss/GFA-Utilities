
buildHistory(History,NumberOfRecords,configpath:="") {
    if (configpath!="") {
        if HasVal(History,configpath) {
            History.RemoveAt(HasVal(History,configpath),1)
        }
        History.InsertAt(1,configpath)
    }
    if (History.Count()>NumberOfRecords) {
        History.Delete(NumberOfRecords+1,History.Count())
    }
    return History
}


toggle_ReportTip() {
    global
    GuiControlGet vToggleLVReport
    GuiControl % (vToggleLVReport ? "+Tile" : "+Report"), % hwndLV_ConfigHistory
    if (vToggleLVReport) {
        LV_ModifyCol(1,"auto")
    } else {
        LV_ModifyCol(1,"auto")   
        LV_ModifyCol(3,"auto")   
    }
    return
}
toggle_ReportTip2() {
    global
    GuiControlGet vToggleLVReport2
    GuiControl % (vToggleLVReport2 ? "+Tile" : "+Report"), % global hwndLV_RScriptHistory
    if (vToggleLVReport2) {
        LV_ModifyCol(1,"auto")
    } else {
        LV_ModifyCol(1,"auto")   
        LV_ModifyCol(3,"auto")   
    }
    return
}
loadConfigFromLV(dynGUI) {
    global hwndLV_ConfigHistory
    gui Listview, % hwndLV_ConfigHistory
    ; TODO: clean up the load config logic to use one singular function, instead of the same code copy-pasted everywhere. then make this func properly take the right guiObject
    configPath:=getSelectedLVEntries()
    ;if !FileExist()
    loadConfig_Main(configPath,dynGUI)
    script.config.LastConfigsHistory:=buildHistory(script.config.LastConfigsHistory,script.config.Configurator_settings.ConfigHistoryLimit,configPath)
    updateLV(hwndLV_ConfigHistory,script.config.LastConfigsHistory)
    script.save(script.scriptconfigfile,,true)
    return
}
loadRScriptFromLV(dynGUI,guiObject) {
    global hwndLV_RScriptHistory
    global generateRScriptBtn
    gui Listview, % hwndLV_RScriptHistory
    ; TODO: clean up the load config logic to use one singular function, instead of the same code copy-pasted everywhere. then make this func properly take the right guiObject
    Chosen:=getSelectedLVEntries2()
    /*
    */
    if (Chosen!="") {
        ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:44:47 AM ; case sensitivity
        if (!InStr(Chosen,".R")) {
            Chosen:=Chosen ".R"
        }
        onGenerateRScript:=Func("createRScript").Bind(Chosen)
        guiControl GC:+g, %generateRScriptBtn%, % onGenerateRScript
        guicontrol % "GC:",vStarterRScriptLocation, % Chosen
        if (Chosen!="") {
            dynGUI.GFA_Evaluation_RScript_Location:=Chosen
        }
        if (!FileExist(Chosen)) {
            writeFile(Chosen,"","UTF-8-RAW",,true)
        } else {
        }
        guiResize(guiObject,true)
    }
    if (Chosen!="") {
        if (overwrite) {
            ;; TODO:  overwriting file: we come from "Edit existing R Script, and need to first parse the existing script for its settings before we can overwrite it"
            guiObject.RCodeTemplate:=handleCheckboxes()
            configLocationFolder:=guiObject.dynGUI.GFA_Evaluation_Configfile_Location
            if ((subStr(configLocationFolder,-1)!="\") && (subStr(configLocationFolder,-1)!="/") && (subStr(configLocationFolder,-3)!=".ini")) {
                configLocationFolder.="\"
            }
            WINDOWS:=strreplace(configLocationFolder,"/","\")
            MAC:=strreplace(configLocationFolder,"/","\")
            Code:=strreplace(guiObject.RCodeTemplate,"%GFA_CONFIGLOCATIONFOLDER_WINDOWS%",WINDOWS)
            Code:=strreplace(Code,"%GFA_EVALUATIONUTILITY%",strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/"))
            Code:=strreplace(Code,"%GFA_CONFIGLOCATIONFOLDER_MAC%",MAC)
            fillRC1(Code)
        } else {
            guiObject.RCodeTemplate:=handleCheckboxes()
            configLocationFolder:=guiObject.dynGUI.GFA_Evaluation_Configfile_Location
            if ((subStr(configLocationFolder,-1)!="\") && (subStr(configLocationFolder,-1)!="/") && (subStr(configLocationFolder,-3)!=".ini")) {
                configLocationFolder.="\"
            }
            WINDOWS:=strreplace(configLocationFolder,"/","\")
            MAC:=strreplace(configLocationFolder,"/","\")
            Code:=strreplace(guiObject.RCodeTemplate,"%GFA_CONFIGLOCATIONFOLDER_WINDOWS%",WINDOWS)
            Code:=strreplace(Code,"%GFA_EVALUATIONUTILITY%",strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/"))
            Code:=strreplace(Code,"%GFA_CONFIGLOCATIONFOLDER_MAC%",MAC)
            fillRC1(Code)
        }
        script.config.LastRScriptHistory:=buildHistory(script.config.LastRScriptHistory,script.config.Configurator_settings.ConfigHistoryLimit,Chosen)
        updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
        script.save(script.scriptconfigfile,,true)
    }
    return
}
getSelectedLVEntries() {
    vRowNum:=0
    loop {
        vRowNum:=LV_GetNext(vRowNum)
        if not vRowNum {
            break ; The above returned zero, so there are no more selected rows.
        }
        LV_GetText(sCurrText3,vRowNum,3)
    }
    return sCurrText3
}
getSelectedLVEntries2() {
    vRowNum:=0
    loop {
        vRowNum:=LV_GetNext(vRowNum)
        if not vRowNum {
            break ; The above returned zero, so there are no more selected rows.
        }
        LV_GetText(sCurrText2,vRowNum,2)
    }
    return sCurrText2
}
On_WM_NOTIFY(W, L, M, H) {
    ;; taken from https://www.autohotkey.com/boards/viewtopic.php?t=28792
    Global hwndLV_ConfigHistory, TThwnd
    Static NMHDRSize := A_PtrSize * 3
    Static offText := NMHDRSize + A_PtrSize
    Static offItem := NMHDRSize + (A_PtrSize * 2) + 4
    Static TTM_SETTITLE := (A_IsUnicode ? 0x421 : 0x420)
    Static LVN_GETINFOTIP := (A_IsUnicode ? -158 : -157)
    Static LVM_GETSTRINGWIDTH := (A_IsUnicode ? 0x1057 : 0x1011)

    Code := NumGet(L + (A_PtrSize * 2), "Int")
    HCTL := NumGet(L + 0, 0, "UPtr")
    ; HCTL is one of our listviews
    If (HCTL = hwndLV_ConfigHistory) {
        ; LVN_GETINFOTIPW, LVN_GETINFOTIPA
        If (Code = LVN_GETINFOTIP) {

            ; Get the address of the string buffer holding text from first column
            textAddr := NumGet(L + offText, "Ptr")

            ; Get the row we are over and then extract the text from the other columns
            Row := NumGet(L + offItem, "Int") + 1
            txt1 := LV_EX_GetSubItemText(HCTL, Row, 1)
            txt2 := LV_EX_GetSubItemText(HCTL, Row, 2)
            txt3 := LV_EX_GetSubItemText(HCTL, Row, 3)


            ; Get necessary width to show all text in the columns
            col2W := DllCall("SendMessage", "Ptr", HCTL, "UInt", LVM_GETSTRINGWIDTH, "Ptr", 0, "Ptr", &txt2)
            col3W := DllCall("SendMessage", "Ptr", HCTL, "UInt", LVM_GETSTRINGWIDTH, "Ptr", 0, "Ptr", &txt3)


            ; If none of the string widths are wider than the width that I made the tiles, we don't show the tooltip.
            if !(col2W > 310 || col3W > 310)
                return

            ; Set the ToolTip's Title to the text from the first column
            DllCall("SendMessage", "Ptr", TThwnd, "UInt", TTM_SETTITLE, "Ptr", 0, "Ptr", &txt1)
            ; Populate the string buffer with newly added text for the ToolTip
            StrPut(txt2 "`n" txt3, textAddr, "UTF-16")
        }
        else {
            ; Remove ToolTip's title in case we are on a column other than 1
            ; May be another way to do this so we aren't setting to nothing so often.
            DllCall("SendMessage", "Ptr", TThwnd, "UInt", TTM_SETTITLE, "Ptr", 0, "Ptr", "")
        }
    }
}


