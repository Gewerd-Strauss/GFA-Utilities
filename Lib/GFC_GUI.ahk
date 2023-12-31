﻿class gfcGUI extends dynamicGUI {
    generateConfig(destroyGUI:=false) {
        this.SubmitDynamicArguments(destroyGUI)
        this._Adjust()
        Object:={}
        WriteInd:=0
        bValidateGroups:=false
        for key, Argument in this.Arguments {
            Object[Argument.ConfigSection]:={}
        }
        for key, Argument in this.Arguments {
            Object[Argument.ConfigSection][key]:=Argument.Value
            if (key="UniqueGroups") {
                bValidateGroups:=true
                ;; TODO: double-check for all groups if they are all unique, and if GroupOrder contains them all.
            } else if (key="Facet2D") {
                bValidateGroups:=false
            } else {
                bValidateGroups:=false
            }
            if (bValidateGroups) {
                this.validateduplicateGroups("GroupsOrder",destroyGUI)
                this.validateduplicateGroups("UniqueGroups",destroyGUI)
                this.validatematchingGroups(destroyGUI,"UniqueGroups","GroupsOrder")
                this.validateRefGroup(destroyGUI,"UniqueGroups","GroupsOrder")
                Object[Argument.ConfigSection][key]:=Argument.Value
            }
            if (Argument.Control="DateTime") {
                AHKVARIABLES := { "A_ScriptDir": A_ScriptDir, "A_ScriptName": A_ScriptName, "A_ScriptFullPath": A_ScriptFullPath, "A_ScriptHwnd": A_ScriptHwnd, "A_LineNumber": A_LineNumber, "A_LineFile": A_LineFile, "A_ThisFunc": A_ThisFunc, "A_ThisLabel": A_ThisLabel, "A_AhkVersion": A_AhkVersion, "A_AhkPath": A_AhkPath, "A_IsUnicode": A_IsUnicode, "A_IsCompiled": A_IsCompiled, "A_ExitReason": A_ExitReason, "A_YYYY": A_YYYY, "A_MM": A_MM, "A_DD": A_DD, "A_MMMM": A_MMMM, "A_MMM": A_MMM, "A_DDDD":A_DDDD,"A_DDD":A_DDD,"A_WDay":A_WDay,"A_YDay":A_YDay,"A_YWeek":A_YWeek,"A_Hour":A_Hour,"A_Min":A_Min,"A_Sec":A_Sec,"A_MSec":A_MSec,"A_Now":A_Now,"A_NowUTC":A_NowUTC,"A_TickCount":A_TickCount,"A_IsSuspended":A_IsSuspended,"A_IsPaused":A_IsPaused,"A_IsCritical":A_IsCritical,"A_BatchLines":A_BatchLines,"A_ListLines":A_ListLines,"A_TitleMatchMode":A_TitleMatchMode,"A_TitleMatchModeSpeed":A_TitleMatchModeSpeed,"A_DetectHiddenWindows":A_DetectHiddenWindows,"A_DetectHiddenText":A_DetectHiddenText,"A_AutoTrim":A_AutoTrim,"A_StringCaseSense":A_StringCaseSense,"A_FileEncoding":A_FileEncoding,"A_FormatInteger":A_FormatInteger,"A_FormatFloat":A_FormatFloat,"A_SendMode":A_SendMode,"A_SendLevel":A_SendLevel,"A_StoreCapsLockMode":A_StoreCapsLockMode,"A_KeyDelay":A_KeyDelay,"A_KeyDuration":A_KeyDuration,"A_KeyDelayPlay":A_KeyDelayPlay,"A_KeyDurationPlay":A_KeyDurationPlay,"A_WinDelay":A_WinDelay,"A_ControlDelay":A_ControlDelay,"A_MouseDelay":A_MouseDelay,"A_MouseDelayPlay":A_MouseDelayPlay,"A_DefaultMouseSpeed":A_DefaultMouseSpeed,"A_CoordModeToolTip":A_CoordModeToolTip,"A_CoordModePixel":A_CoordModePixel,"A_CoordModeMouse":A_CoordModeMouse,"A_CoordModeCaret":A_CoordModeCaret,"A_CoordModeMenu":A_CoordModeMenu,"A_RegView":A_RegView,"A_IconHidden":A_IconHidden,"A_IconTip":A_IconTip,"A_IconFile":A_IconFile,"A_IconNumber":A_IconNumber,"A_TimeIdle":A_TimeIdle,"A_TimeIdlePhysical":A_TimeIdlePhysical,"A_TimeIdleKeyboard":A_TimeIdleKeyboard,"A_TimeIdleMouse":A_TimeIdleMouse,"A_DefaultGUI":A_DefaultGUI,"A_DefaultListView":A_DefaultListView,"A_DefaultTreeView":A_DefaultTreeView,"A_Gui":A_Gui,"A_GuiControl":A_GuiControl,"A_GuiWidth":A_GuiWidth,"A_GuiHeight":A_GuiHeight,"A_GuiX":A_GuiX,"A_GuiY":A_GuiY,"A_GuiEvent":A_GuiEvent,"A_GuiControlEvent":A_GuiControlEvent,"A_EventInfo":A_EventInfo,"A_ThisMenuItem":A_ThisMenuItem,"A_ThisMenu":A_ThisMenu,"A_ThisMenuItemPos":A_ThisMenuItemPos,"A_ThisHotkey":A_ThisHotkey,"A_PriorHotkey":A_PriorHotkey,"A_PriorKey":A_PriorKey,"A_TimeSinceThisHotkey":A_TimeSinceThisHotkey,"A_TimeSincePriorHotkey":A_TimeSincePriorHotkey,"A_EndChar":A_EndChar,"A_ComSpec":A_ComSpec,"A_Temp":A_Temp,"A_OSType":A_OSType,"A_OSVersion":A_OSVersion,"A_Is64bitOS":A_Is64bitOS,"A_PtrSize":A_PtrSize,"A_Language":A_Language,"A_ComputerName":A_ComputerName,"A_UserName":A_UserName,"A_WinDir":A_WinDir,"A_ProgramFiles":A_ProgramFiles,"A_AppData":A_AppData,"A_AppDataCommon":A_AppDataCommon,"A_Desktop":A_Desktop,"A_DesktopCommon":A_DesktopCommon,"A_DesktopCommon":A_DesktopCommon}
                ;a:=
                ;dpdate:=DA_DateParse(a)
                FormatTime dpdate2, % DA_FormatEx(subStr(Argument.Value,1,8), AHKVARIABLES), % "dd.MM.yyyy"
                Object[Argument.ConfigSection][key]:=dpdate2
            }
        }
        this.ConfigObject:=Object
            , String:=""
        if IsObject(Object) {
            for SectionName, Entry in Object
            {
                String.="[" SectionName "]" "`n"
                    , Pairs := ""
                for key, Value in Entry
                {
                    WriteInd++
                    if !Instr(Pairs,key "=" Value "`n")
                        Pairs .= key "=" Value "`n"
                }
                String.=Pairs
            }
        } else {
            for SectionName, Entry in this.config
            {
                String.="[" SectionName "]" "`n"
                    , Pairs := ""
                for key, Value in Entry
                {
                    WriteInd++
                    if !Instr(Pairs,key "=" Value "`n")
                        Pairs .= key "=" Value "`n"
                }
                String.=Pairs
            }
        }
        this.ConfigString:=String
    }
    getTab3Parents() {
        sections:={}
        for _, Argument in this.Arguments {
            sections[Argument.Tab3Parent]:=Argument.Tab3Parent
        }
        return sections
    }
    validateduplicateGroups(checked_key:="",destroy:=false) {
        this.SubmitDynamicArguments(destroy)
        for key, Argument in this.Arguments {
            if (key=checked_key) {
                if (Argument.Value!="") {
                    cleanedVal:=removeDuplicates(Argument.Value, ",",0)
                    cleanedVal:=RTrim(cleanedVal,",")
                    if (cleanedVal!=Argument.Value) { ;; different, thus duplicates got removed.
                        MsgBox 0x40034, % script.name " - " A_ThisFunc
                            , % "The value you have entered for the key '" checked_key "' contains (potentially case-differing) repetitions."
                            . "`nThe program tried to correct the problem, please check the new contents for the key '" checked_key "' and confirm again."
                            . "`nKey: " checked_key
                            . "`nErroneous old value: " Argument.Value
                            . "`nSuggested new Value: " cleanedVal
                            . "`n"
                            . "`nConfirm to use the new value, decline to keep the old value."
                            . "`nKeeping the old value will likely cause errors when running the R-Script,"
                            . "`nexcept if you want to facet your Y-Axis."
                            . "`n"
                            . "`n`If you do not intend on faceting your plot, this will most likely cause issues."
                            . "`n"
                            . "`nPress 'Yes' to use the suggested new value, press 'no' to keep the old value."

                        IfMsgBox Yes, {
                            Argument.Value:=cleanedVal
                            guicontrol % "GC:",% "v" StrReplace(key,"-","___") , % cleanedVal
                        } Else IfMsgBox No, {
                            guicontrol % "GC:",% "v" StrReplace(key,"-","___") , % Argument.Value
                        }
                    }
                }
            }
        }
    }
    validatematchingGroups(destroy:=false,variadicGroupKeys*) {
        loop, 2 {
            this.SubmitDynamicArguments(destroy)
            Arr:={}
            Arr2:={}

            for key, Argument in this.Arguments {
                if (Argument.Value="") {
                    continue
                }
                for _,key_to_validate in variadicGroupKeys {
                    if (key=key_to_validate) {
                        value_to_validate:=removeDuplicates(Argument.Value, ",",1)
                        value_to_validate:=strsplit(value_to_validate,",")
                        Arr[key]:=value_to_validate
                        Arr2.push(key)
                    }
                }
            }
            Count:=0
            Success:=true
            for key_to_validate, _ in Arr {
                if (Count=0) {
                    Count:=_.Length()
                } else if (Count>0) {
                    if (Count!=_.Length()) {
                        Success:=false
                        break
                    } else {
                        Success:=true
                    }
                }
            }
            ind:=0
                ,value_missing:=false
            for key_to_validate, value_to_validate in Arr {
                ind++
                if (ind=1) {
                    firstvals:=value_to_validate.Clone()
                } if (ind>1) {

                    for _, thisval in firstvals {
                        if !HasVal(value_to_validate,thisval) {
                            value_missing:=true
                            break
                        }
                    }
                }
            }
            if (A_Index<2) {
                if ((!Success && Count>0) || value_missing) {
                    conflicting_keys:=trim(st_concat(", "," & ",Arr2))
                    conflicting_keys_vals:=""
                    for key,val in Arr {
                        conflicting_keys_vals.="`n" key ": " st_concat(", "," & ", val)
                        guicontrol % "GC:",% "v" StrReplace(key,"-","___") , % "ERROR: " st_concat(",",",", val)
                    }
                    MsgBox 0x40014, % script.name " - " A_ThisFunc
                        , % "The unique values you have entered for the keys " conflicting_keys " are different:"
                        . "`n`n" conflicting_keys_vals
                        . "`nPlease resolve the issue by only using the same values for the keys '" conflicting_keys "' and confirm again."
                }
            }
        }
    }
    validateRefGroup(destroy:=false,variadicGroupKeys*) {
        loop, 2 {
            this.SubmitDynamicArguments(destroy)
            Arr:={}
            Arr2:={}

            for key, Argument in this.Arguments {
                if (Argument.Value="") {
                    continue
                }
                for _,key_to_validate in variadicGroupKeys {
                    if (key=key_to_validate) {
                        value_to_validate:=removeDuplicates(Argument.Value, ",",1)
                        value_to_validate:=strsplit(value_to_validate,",")
                        Arr[key]:=value_to_validate
                        Arr2.push(key)

                    }
                }
            }
            Success:=0
            Expected:=0
            Expected:=Arr.Count()
            conflicting_keys:=""
            conflicting_keys_vals:=""
            for key_to_validate, haystack in Arr {
                if HasVal(haystack, this.Arguments.RefGroup.Value) {
                    Success++
                } else {
                    conflicting_keys.=key_to_validate
                    if (A_Index<Expected) {
                        if (A_Index<(Expected-1)) {
                            conflicting_keys.=", "
                        } else if (A_index=(Expected-1)) {
                            conflicting_keys.=" & "
                        }

                    }
                }
            }
            if (A_index<2) && (Success!=Expected) && (this.Arguments.RefGroup.Value!="") {
                for key,val in Arr {
                    conflicting_keys_vals.="`n" key ": " st_concat(", "," & ", val)
                }
                MsgBox 0x40014, % script.name " - " A_ThisFunc
                    , % "The value you have entered for the key 'RefGroup' is not present in the values you entered for the following keys: "
                    . "`n`n" "RefGroup: " this.Arguments.RefGroup.Value
                    . conflicting_keys_vals
                    . "`n`nPlease resolve the issue by only using the same values for the keys 'RefGroup, " conflicting_keys "' and confirm again."
                    . "`nYou can disregard this message if you chose to facet your Plot across the y-axis. However in this case you should be aware"
                    . " that this program cannot ensure the reference group you have given will be valid."
                    . "`n"
                    . "`nUse the new  value?"

                IfMsgBox Yes, {
                    Argument.Value:=cleanedVal
                    guicontrol % "GC:",% "v" StrReplace("RefGroup","-","___") , % "ERROR: " this.Arguments.RefGroup.Value
                } Else IfMsgBox No, {
                    guicontrol % "GC:",% "v" StrReplace("RefGroup","-","___") , % this.Arguments.RefGroup.Value
                }
            }
        }

    }
    __Set(_Param*){

    }
    loadConfigFromFile(File) {
        t_script:=new script_()
        t_script.Load(File)
        this.ArgumentsValidate:={}
        for param, _obj in this.Arguments {
            this.ArgumentsValidate[param]:={}
            for param_key, param_val in _obj {
                KeyNotPresent:=true
                for _, section_contents in t_script.config {
                    if (section_contents.HasKey(param)) {
                        KeyNotPresent:=false
                    }
                }
                if (KeyNotPresent) {
                    this.ArgumentsValidate[param][param_key]:=param_val
                    this.ArgumentsValidate[param]["Value"]:=""
                } else {
                    this.ArgumentsValidate[param][param_key]:=param_val
                }
            }
        }
        for _,_obj in t_script.config {
            for current_key,Value in _obj {
                if (this.ArgumentsValidate.HasKey(current_key)) {
                    if (this.ArgumentsValidate[current_key].Type="boolean") {
                        if (Value="T" || Value = "TRUE" || Value = "F" || Value = "FALSE") {
                            this.ArgumentsValidate[current_key].Value:=(InStr(Value,"T")?1:0)
                        }
                    } else if (this.ArgumentsValidate[current_key].Type="Integer") {
                        Value:=Value + 0
                        if (Value!="") {    ;; floored Value is an integer
                            this.ArgumentsValidate[current_key].Value:=floor(Value)
                        } else {            ;; floored Value is not an integer
                            this.ArgumentsValidate[current_key].Value:=this.ArgumentsValidate[current_key].Default
                            OutputDebug % "`nThe Value for Key '" current_key "' should be of type 'Integer', but coercing it into an integer by adding zero resulted in an empty string"
                        }
                    } else if (this.ArgumentsValidate[current_key].Control="DateTime") {
                        AHKVARIABLES := { "A_ScriptDir": A_ScriptDir, "A_ScriptName": A_ScriptName, "A_ScriptFullPath": A_ScriptFullPath, "A_ScriptHwnd": A_ScriptHwnd, "A_LineNumber": A_LineNumber, "A_LineFile": A_LineFile, "A_ThisFunc": A_ThisFunc, "A_ThisLabel": A_ThisLabel, "A_AhkVersion": A_AhkVersion, "A_AhkPath": A_AhkPath, "A_IsUnicode": A_IsUnicode, "A_IsCompiled": A_IsCompiled, "A_ExitReason": A_ExitReason, "A_YYYY": A_YYYY, "A_MM": A_MM, "A_DD": A_DD, "A_MMMM": A_MMMM, "A_MMM": A_MMM, "A_DDDD":A_DDDD,"A_DDD":A_DDD,"A_WDay":A_WDay,"A_YDay":A_YDay,"A_YWeek":A_YWeek,"A_Hour":A_Hour,"A_Min":A_Min,"A_Sec":A_Sec,"A_MSec":A_MSec,"A_Now":A_Now,"A_NowUTC":A_NowUTC,"A_TickCount":A_TickCount,"A_IsSuspended":A_IsSuspended,"A_IsPaused":A_IsPaused,"A_IsCritical":A_IsCritical,"A_BatchLines":A_BatchLines,"A_ListLines":A_ListLines,"A_TitleMatchMode":A_TitleMatchMode,"A_TitleMatchModeSpeed":A_TitleMatchModeSpeed,"A_DetectHiddenWindows":A_DetectHiddenWindows,"A_DetectHiddenText":A_DetectHiddenText,"A_AutoTrim":A_AutoTrim,"A_StringCaseSense":A_StringCaseSense,"A_FileEncoding":A_FileEncoding,"A_FormatInteger":A_FormatInteger,"A_FormatFloat":A_FormatFloat,"A_SendMode":A_SendMode,"A_SendLevel":A_SendLevel,"A_StoreCapsLockMode":A_StoreCapsLockMode,"A_KeyDelay":A_KeyDelay,"A_KeyDuration":A_KeyDuration,"A_KeyDelayPlay":A_KeyDelayPlay,"A_KeyDurationPlay":A_KeyDurationPlay,"A_WinDelay":A_WinDelay,"A_ControlDelay":A_ControlDelay,"A_MouseDelay":A_MouseDelay,"A_MouseDelayPlay":A_MouseDelayPlay,"A_DefaultMouseSpeed":A_DefaultMouseSpeed,"A_CoordModeToolTip":A_CoordModeToolTip,"A_CoordModePixel":A_CoordModePixel,"A_CoordModeMouse":A_CoordModeMouse,"A_CoordModeCaret":A_CoordModeCaret,"A_CoordModeMenu":A_CoordModeMenu,"A_RegView":A_RegView,"A_IconHidden":A_IconHidden,"A_IconTip":A_IconTip,"A_IconFile":A_IconFile,"A_IconNumber":A_IconNumber,"A_TimeIdle":A_TimeIdle,"A_TimeIdlePhysical":A_TimeIdlePhysical,"A_TimeIdleKeyboard":A_TimeIdleKeyboard,"A_TimeIdleMouse":A_TimeIdleMouse,"A_DefaultGUI":A_DefaultGUI,"A_DefaultListView":A_DefaultListView,"A_DefaultTreeView":A_DefaultTreeView,"A_Gui":A_Gui,"A_GuiControl":A_GuiControl,"A_GuiWidth":A_GuiWidth,"A_GuiHeight":A_GuiHeight,"A_GuiX":A_GuiX,"A_GuiY":A_GuiY,"A_GuiEvent":A_GuiEvent,"A_GuiControlEvent":A_GuiControlEvent,"A_EventInfo":A_EventInfo,"A_ThisMenuItem":A_ThisMenuItem,"A_ThisMenu":A_ThisMenu,"A_ThisMenuItemPos":A_ThisMenuItemPos,"A_ThisHotkey":A_ThisHotkey,"A_PriorHotkey":A_PriorHotkey,"A_PriorKey":A_PriorKey,"A_TimeSinceThisHotkey":A_TimeSinceThisHotkey,"A_TimeSincePriorHotkey":A_TimeSincePriorHotkey,"A_EndChar":A_EndChar,"A_ComSpec":A_ComSpec,"A_Temp":A_Temp,"A_OSType":A_OSType,"A_OSVersion":A_OSVersion,"A_Is64bitOS":A_Is64bitOS,"A_PtrSize":A_PtrSize,"A_Language":A_Language,"A_ComputerName":A_ComputerName,"A_UserName":A_UserName,"A_WinDir":A_WinDir,"A_ProgramFiles":A_ProgramFiles,"A_AppData":A_AppData,"A_AppDataCommon":A_AppDataCommon,"A_Desktop":A_Desktop,"A_DesktopCommon":A_DesktopCommon,"A_DesktopCommon":A_DesktopCommon}
                        Value:=DA_DateParse(DA_FormatEx(Value, AHKVARIABLES))
                        Value:=st_pad(Value,"",0,0,strLen(this.ArgumentsValidate[current_key].Value)-StrLen(Value))
                        this.ArgumentsValidate[current_key].Value:=Value
                    } else if (this.ArgumentsValidate[current_key].Type="String") {
                        this.ArgumentsValidate[current_key].Value:=Value
                    } else if (this.ArgumentsValidate[current_key].Type="number"){
                        Value:=Value + 0
                        if (Value!="") {    ;; floored Value is an integer
                            this.ArgumentsValidate[current_key].Value:=Value
                        } else {            ;; floored Value is not an integer
                            this.ArgumentsValidate[current_key].Value:=this.ArgumentsValidate[current_key].Default
                            OutputDebug % "`nThe value for key '" current_key "' should be of type 'number', but coercing it into a number by adding zero resulted in an empty string"
                        }
                    } else {
                        OutputDebug % "`nKey " current_key " is not part of the default config, and will be assumed invalid or corrupted"
                    }
                } else {
                    this.ArgumentsValidate[current_key].Value:=""
                }
            }
        }
    }
    validateLoadedConfig() {
        for param, _obj in this.ArgumentsValidate {
            for param_key, param_val in _obj {
                this.Arguments[param][param_key]:=param_val
            }
        }
    }
    populateLoadedConfig() {

        for Parameter,Value in this.Arguments {
            if (Value.Control="DDL" || Value.Control="DropDownList" || Value.Control="ComboBox") {
                if (Value.Control="ComboBox") {
                    if InStr(Value.ctrlOptions,Value.Value)  {
                        guicontrol % "GC:" "ChooseString",% "v" StrReplace(Parameter,"-","___") , % Value.Value
                    } else {
                        guicontrol % "GC:" ,% "v" StrReplace(Parameter,"-","___") , % Value.Value "||" strreplace(Value.ctrlOptions,"||","|")
                    }

                } else {
                    guicontrol % "GC:" "ChooseString",% "v" StrReplace(Parameter,"-","___") , % Value.Value
                }
            } else {
                guicontrol % "GC:",% "v" StrReplace(Parameter,"-","___") , % Value.Value
            }
        }
    }
    generateDocumentationString() {
        String:=""
        DocArray:={}
        DocArguments:={}
        DocArguments:=this.shallowCopy(DocArguments)
        for Parameter, Argument in DocArguments {
            if (!IsObject(DocArray[Argument.Tab3Parent])) {
                DocArray[Argument.Tab3Parent]:={}
            }
            Parametertemplate=
                (LTRIM

                    #### ```%Parameter`%`` {#sec-`%parameter_lowercase`%}

                    |             |                                                                     |
                    | ----------- | ------------------------------------------------------------------- |
                    | Parameter   | ```%Parameter`%`` [Section:```%ConfigSection`%``]%A_Space%%A_Space% |
                    | Value       | ```%Value`%``%A_Space%%A_Space%                                     |
                    | Default     | ```%Default`%``%A_Space%%A_Space%                                   |
                    | Type        | ```%Type`%``%A_Space%%A_Space%                                      |
                    | Options     | ```%ctrlOptions`%``%A_Space%%A_Space%                               |
                    | Instruction | ```%String`%``%A_Space%%A_Space%                                    |
                    | Elaboration | ```%TTIP`%``%A_Space%%A_Space%                                      |

                )
            if (Argument.Type="boolean") {
                Argument.ctrlOptions:="TRUE/FALSE"
            }
            if (!Argument.HasKey("ctrlOptions")) {
                Argument.ctrlOptions:="/"
            }
            for Key,Arg in Argument {
                if InStr(Parametertemplate,"%" Key "%") {
                    if (Key="ctrlOptions") {
                        if (RegexMatch(Arg,"w\d+")) {
                            Arg:=RegExReplace(Arg," w\d+","/")
                        }
                        if (RegexMatch(Arg,"h\d+")) {
                            Arg:=RegExReplace(Arg," h35","/")
                        }
                        if (RegexMatch(Arg,"w\d+")) {
                            Arg:=RegExReplace(Arg," w\d+","/")
                        }
                        if (RegexMatch(Arg,"g\w+")) {
                            Arg:=RegExReplace(Arg," g\w+","/")
                        }
                    } 
                    if (Argument.HasKey("TTIP")) {
                        Parametertemplate:=strreplace(Parametertemplate,"``%TTIP%``","``" Argument.TTIP "``")
                    } else {
                        Parametertemplate:=strreplace(Parametertemplate,"``%TTIP%``")
                    }
                    Parametertemplate:=strreplace(Parametertemplate,"%" Key "%",(Arg!=""?Arg:"/"))
                }
                Parametertemplate:=strreplace(Parametertemplate,"%Parameter%",Parameter)
                Parametertemplate:=strreplace(Parametertemplate,"%parameter_lowercase%",strreplace(regexreplace(Parameter,".*","$L0")," ","-"))
                Parametertemplate:=strreplace(Parametertemplate,"//","/")
                DocArray[Argument.Tab3Parent][Parameter]:=Parametertemplate
            }

        }
        String:=""
        for each, TabElements in DocArray {
            Str:="`n`n`n### " each "`n"
            for Parameter, Parameterstring in TabElements {
                Str.= Parameterstring "`n`n"
            }
            String.=Str
        }
        return String
    }
    shallowCopy(Object) {
        for Parameter, Argument in this.Arguments {
            if (!Object.HasKey(Parameter)) {
                Object[Parameter]:={}
            }
            for Key, _ in Argument
                if (!Object[Parameter].HasKey(Key)) {
                    Object[Parameter][Key]:=Argument[Key]
                }
        }
        return Object
    }
}
removeDuplicates(vText,Delim:=",",bSort:=0) {
    vOutput := ""
    VarSetCapacity(vOutput, StrLen(vText)*2*2)
    oArray := {}
    StrReplace(vText, ",",, vCount)
    oArray.SetCapacity(vCount+1)
    if (bSort) {
        Sort vText, D, ;add this line to sort the list
    }
    Loop Parse, vText, % Delim
    {
        if !oArray.HasKey("z" A_LoopField)
            oArray["z" A_LoopField] := 1, vOutput .= A_LoopField Delim
    }
    oArray := ""
    vOutput:=subStr(vOutput,1,StrLen(vOutput)-1)
    return vOutput
}

