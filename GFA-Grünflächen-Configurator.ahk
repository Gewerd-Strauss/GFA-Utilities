#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Requires AutoHotkey v1.1.35+ ;; version at which script was written.
#SingleInstance Force
#MaxHotkeysPerInterval 99999999
#Warn All, Outputdebug
;#Persistent
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
DetectHiddenWindows On
SetKeyDelay -1, -1
SetBatchLines -1
SetTitleMatchMode 2
CodeTimer("")
FileGetTime ModDate, %A_ScriptFullPath%, M
FileGetTime CrtDate, %A_ScriptFullPath%, C
CrtDate := SubStr(CrtDate, 7, 2) "." SubStr(CrtDate, 5, 2) "." SubStr(CrtDate, 1, 4)
    , ModDate := SubStr(ModDate, 7, 2) "." SubStr(ModDate, 5, 2) "." SubStr(ModDate, 1, 4)
global script := new script_()
    , bRunFromVSC:=(WinActive("ahk_class Chrome_WidgetWin_1") && WinActive("ahk_exe Code.exe"))
    , DEBUG := IsDebug()
    , globalLogicSwitches := {}
script := { base: script.base
        , name: regexreplace(A_ScriptName, "\.\w+")
        , crtdate: CrtDate
        , moddate: ModDate
        , offdoclink: A_ScriptDir "\assets\Documentation\GFA_Renamer_Readme.html"
        , resfolder: A_ScriptDir "\res"
        , iconfile: ""
        , version: ""
        , config: []
        , scriptconfigfile: A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
        , gfcGUIconfigfile: A_ScriptDir "\INI-Files\GFC_DA.ini"
        , configfolder: A_ScriptDir "\INI-Files"
        , aboutPath: A_ScriptDir "\res\About.html"
        , reqInternet: false
        , rfile: "https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/archive/refs/heads/master.zip"
        , vfile_raw: "https://raw.githubusercontent.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/master/version_check.txt"
        , vfile: "https://raw.githubusercontent.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/master/version_check.txt"
        , rfile_dev: "https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/archive/refs/heads/dev.zip"
        , vfile_raw_dev: "https://raw.githubusercontent.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/dev/version_check.txt"
        , vfile_dev: "https://raw.githubusercontent.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/dev/version_check.txt"
        , EL: "359b3d07acd54175a1257e311b5dfaa8370467c95f869d80dba32f4afdcae19f4485d67815d9c1f4fe9a024586584b3a0e37489e7cfaad8ce4bbc657ed79bd74"
        , authorID: "Laptop-C"
        , author: "Gewerd Strauss"
        , Computername: A_ComputerName
        , license: A_ScriptDir "\res\LICENSE.txt" ;; do not edit the variables above if you don't know what you are doing.
        , blank: "" }

globalLogicSwitches.Debug:=DEBUG

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
            , "Date and Time":["A_YYYY","A_MM","A_DD","A_MMMM","A_MMM","A_DDDD","A_DDD","A_WDay","A_YDay","A_YWeek","A_Hour","A_Min","A_Sec","A_MSec","A_Now","A_NowUTC","A_TickCount"]
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
            ,confVersion:script.config.Version},1)
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
    for sec_id,_ in Variables {
        Obj[sec_id]:={}
        for __, variable in Variables[sec_id] {
            Obj[sec_id][variable]:=Deref("%" variable "%")
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
main()
if (A_IsCompiled) {
    CodeTimer()
} else if ((globalLogicSwitches.bIsAuthor && !A_IsCompiled)) {
    CodeTimer("Startup Time")
} else {
    CodeTimer()
}
sleep 3500
tooltip
return

main() {
    bUpdateGeneratedFiles:=false
    Loop, % A_Args.Length() {
        param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
            , bUpdateGeneratedFiles:=param
        if bUpdateGeneratedFiles {
            break
        }
    }
    globalLogicSwitches.bIsAuthor:=(script.computername=script.authorID) + 0
        , globalLogicSwitches.Debug:=DEBUG
    if !FileExist(script.scriptconfigfile) || ((DEBUG && globalLogicSwitches.bIsAuthor) || bUpdateGeneratedFiles) {
        if (FileExist(script.scriptconfigfile)) {
            if (globalLogicSwitches.bIsAuthor) {
                ttip("Resetting program-configuration.")
            }   
        } else {
            ttip("Initialising program-configuration.")
        }
        setupdefaultconfig(1)
    }
    if !FileExist(script.gfcGUIconfigfile) || ((DEBUG && globalLogicSwitches.bIsAuthor)  || bUpdateGeneratedFiles) {
        if (FileExist(script.gfcGUIconfigfile)) {
            if (globalLogicSwitches.bIsAuthor) {
                ttip("Resetting GUI-configuration.")
            }   
        } else {
            ttip("Initialising GUI-configuration.")
        }
        setupdefaultconfig(2)
    }
    script.Load(script.scriptconfigfile, 1)
    if (script.config.Configurator_settings.bRunAsAdmin && !A_IsAdmin) {
        answer := AppError("Do you want to elevate the program ?", "Do you want to reload the program with administrator-privilages without saving any data? `n`nAny currently unsaved changes will not be saved.",0x34," - ")
        if (answer = "Yes") {
            RunAsAdmin()
        } else {
            answer := AppError("Do you want to exit the program ?", "You chose not to run the program with administrator-privileges.`nYou may either uncheck the configuration option 'bRunAsAdmin' in the program's settings, or elevate the program with administrator-privileges the next time it starts.`n`nDo you want to continue loading the program?",0x34," - ")
            if (answer = "No") {
                exitApp()
            }
        }
    }
    if !script.requiresInternet() {
        answer := AppError("The program requires an internet connection.", "The program requires an internet connection, which is not available. You may continue without one, but functionality may be severely impaired.`nDo you want to exit the program?",0x34," - ")
        if (answer = "Yes") {
            exitApp()
        }
    }
    globalLogicSwitches.bIsDebug:=script.config.Configurator_settings.bDebugSwitch + 0
    script.version:=script.config.version.GFC_version
        , script.loadCredits(script.resfolder "\credits.txt")
        , script.loadMetadata(script.resfolder "\meta.txt")
        , IconString:=A_ScriptDir "\res\icon.ico"
    ;, IconString:="iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAARISURBVGhD7dtLbxNXGMbxbFh2yRIpzkWQgpIUKFAVibCBknIJqCFOZNIbJg0Xp7ikkAAh4SJoCxUENiBgW6ktUldIKQURbmpAIkSiqlqg6gcAvsLLPPPKVjp5bM/xnAllMpb+K4/PeX9yjj1epGKmPpqcBmdAcLqPwcrKSol6cCo3BkczOJUbg6MZnMqNwdEMTuXG4GgGp3JjcDSDU7kG4OzvJ+TAs3NT6p04Kd1XB6TtbJc0fbZGaupq6etNqplX666VPNflrH1QesdP0b2/evAtfb03OJVrAext7x/fS9vwNlnwXiNdp1gLljXI5jNpdw22trdQwZnRI3TTQvX/NSwth1NSVVNF15tcorpKNgylZN+fp+lahfry7jG6njc4lWsAxp8W27RU237pk7kNdXRNNLe+TtJX9tHXlmr7yEG6pjc4lWsATl3aRTf1E96JhhWLp6xZv3yh9Nw+Sl/jp87LPVPWZMGpXANw89etdFO/ZcdOyPwl9fn18M6aHhNvH/a1/WfGQsGpXAPwwlVL6aYmdV89INW11e6ZTV/ZS68xadHqZXRWb3Aq1wCMMjcP041NWru/XdYPdNDnTMqMHpVEIkHn9Aancg3BH2Q30c1Nyj46Lnsef0OfM2lVz0Y6IwtO5RqCcUOQfXCcDuC39P1dkh4r/wMQZW4e8/V1lwtO5RqC0crPm+kQfup/Oizt1zZJ8teN0v/kLL3GTys+WU1nKxScyi0DjFIXd9JBSpWZOCRtI+vdMhMD9JpS4euRzVQsOJVbJhh/2uXciKTHdubBW8d20GuKhT3LuVeHU7llghG+R/E1wwYrVOetzjy4c/Rjek2h8ANlXuPbdJZSwancAGCEd3rL5QwdkNVxvTUP7vjN/41MytkjyK8wOJUbEJwLH2S4fWTDTi55rSUPTo600GsmhzVXbm2me5oEp3ItgRHuoNbs+Uh23yv8MzKHzbX/2TC9Dms097a6a7K9TINTuRbBuRJVCVmy7n3ZMJiST3/IundEvY9OSt/fZ6aA+5yfkHgO1+BavAavxRps7XKDU7khgIvlfSfZNWEEp3JjcLi9seCXdypea2ymYsGp3BjsLzbEdMZmKhacyg0AfnGjQv4Zchqcppy9nl9/jWD073dksJDCXrl92UzFglO5ZYJznR96Kz9E2GEvNoOf4FRuQPAX7bPpcGHUlZxNZ/ATnMoNCF7UOEee3+ID2u7dd+bQGfwEp3IDgtH4j7PogDZ7+NMsurff4HS1ziMw+MI0nOMg5xfBqVwL4O6O8M8xPivY3n6DU7kWwIudc8yGtFmQ84vgVK4FMArzHGNttqdJcLpa52EFfPFIeOcYnxFsT5PgVK4lcJjnGGuzPU2CU7mWwGGe46DnF8GpXEtgNP6z/XNs4/wiOF2t87AGDuMcY022l2lwKtci+P8cnMqNwdEMTuXG4GgGp3JjcDSDU7kz5j/TKppeAamEQurI/tgFAAAAAElFTkSuQmCC"
    try {
        script_TraySetup(IconString)
    }
    if (script.requiresInternet(script.vfile,true) && script.config.Configurator_settings.CheckUpdatesOnScriptStart) {
        if ((script.config.Configurator_settings.UpdateChannel="stable") && !DEBUG) {
            script.Update(script.vfile,script.rfile,1,,,1)
        } else if ((script.config.Configurator_settings.UpdateChannel="development") && !DEBUG) {
            script.Update(script.vfile_dev,script.rfile_dev,1,,,1)
        }
    }
    if (bUpdateGeneratedFiles) {
        FileDelete % script.AboutPath
        script.About(1)
        exitApp()

    }

    global guiObject:=guiCreate()
    guiObject.RCodeTemplate:=set_template()
    if !FileExist(script.gfcGUIconfigfile) || ((DEBUG && globalLogicSwitches.bIsAuthor)  || bUpdateGeneratedFiles) {
        if (DEBUG && globalLogicSwitches.bIsAuthor) {
            ttip("Generating parameter documentation string.")
            String:=guiObject.dynGUI.generateDocumentationString()
            Clipboard:=String
        }
    }
    guiShow(guiObject)
        , f5:=Func("guiShow2").Bind(guiObject)
        , f6:=Func("prepare_release")
        , f7:=func("copyGFA_EvaluationFolder").Bind(script.config.Configurator_settings.GFA_Evaluation_InstallationPath)
        , f8:=func("openCommandline_EvaluationFolder").Bind(script.config.Configurator_settings.GFA_Evaluation_InstallationPath)
    guiResize(guiObject)
    Menu Tray, Add, Show GUI, % f5
    if (globalLogicSwitches.bIsAuthor) {
        menu Tray, Add, Recompile, % f6
    }
    Menu Tray, Add, Copy GFA_Evaluation-Path, % f7
    Menu Tray, Add, Open CMD, % f8
    handleCheckboxes()
    handleConfig(guiObject.dynGUI,false)
    fillRC1(guiObject.RCodeTemplate)
    fillRC2(guiObject.dynGUI.ConfigString)
    return
}

;@ahk-neko-ignore 1 line; Function too big
guiCreate() {
    ;; Funktion erstellt die Benutzeroberfläche. Sehr basic, aber reicht für das was gemacht werden muss.
    gui GC: destroy
    bShowDebugPanelINMenuBar:=""
    if (script.config.Configurator_settings.SizeSetting="auto") { ; auto
        SysGet A, MonitorWorkArea
        guiHeight:=ABottom - 2*30
            , guiWidth:=A_ScreenWidth - 2*30
    } else if (script.config.Configurator_settings.SizeSetting="1440p") { ; 1440p
        guiWidth:=2560 - 2*30
            , guiHeight:=1392 - 2*30
    } else if (script.config.Configurator_settings.SizeSetting="1080p") { ; 1080p
        guiWidth:=1920 - 2*30
            , guiHeight:=1032 - 2*30
    }
    DPIAdjustmentFactor:=(1/(A_ScreenDPI/96))
    guiWidth:=guiWidth * DPIAdjustmentFactor
    guiHeight:=guiHeight * DPIAdjustmentFactor
    ;guiHeight:=990
    if (globalLogicSwitches.DEBUG) {
        ttip(["guiWidth: " guiWidth
                ,"guiHeight: " guiHeight
                ,"A_ScreenHeight " A_ScreenHeight
                ,"A_ScreenWidth " A_ScreenWidth
                , "A_DPI " A_ScreenDPI
                ,script.config.SizeSetting
                ,"is1080: " (script.config.Configurator_settings.SizeSetting="1080p")
                ,"is1440: " (script.config.Configurator_settings.SizeSetting="1440p")
                ,"isauto: " (script.config.Configurator_settings.SizeSetting="auto")
                ,"height-mwa 1440p: " 1392 - 2*30
                ,"guiWidth 1440p: " 2560 - 2*30
                ,"guiWidth  1080p: " 1920 - 2*30
                ,"height-mwa 1080p: " 1032 - 2*30,["bIsAuthor: " globalLogicSwitches.bIsAuthor,"bisDEBUG: " globalLogicSwitches.bIsDebug,globalLogicSwitches.DEBUG]],1,2300)
    }
    YMarginWidth:=XMarginWidth:=15
        , NumberofSections:=3
        , WidthMinusMargins:=guiWidth - 4*XMarginWidth + 0
        , SectionWidth:=WidthMinusMargins/NumberofSections + 0
        , SectionHeight:=guiHeight
        , Sections:=[]
        , middleanchor:=guiWidth-4*15
    loop, % NumberofSections {
        if (A_Index>1) {
            Sections[A_Index]:={XAnchor:XMarginWidth*A_Index + SectionWidth*(A_Index-1),YAnchor:3,Width:SectionWidth*1,Height:SectionHeight*1}
        } else {
            Sections[A_Index]:={XAnchor:XMarginWidth*A_Index,YAnchor:3,Width:SectionWidth*1,Height:SectionHeight*1}
        }
    }
    Sections[4]:={XAnchor:Sections[3].XAnchor,YAnchor:Sections[3].YAnchor,Width:Sections[3].Width,Height:Sections[3].Height}

    if (script.config.Configurator_settings.SizeSetting="1080p") {
        ShiftSection1:=0
    } else if (script.config.Configurator_settings.SizeSetting="1440p") {
        ShiftSection1:=50
    } else {
        ShiftSection1:=0
    }
    ShiftSection2:=250
        , Sections[1].Width:=Sections[1].Width-ShiftSection1
        , Sections[2].XAnchor:=Sections[2].XAnchor-ShiftSection1
        , Sections[2].Width:=Sections[2].Width-ShiftSection2
        , Sections[4].XAnchor:=Sections[4].XAnchor-ShiftSection1-ShiftSection2
        , Sections[4].Width:=Sections[4].Width+ShiftSection1+ShiftSection2
        , Sections[2].Height:=230
        , middleanchor:=guiWidth-4*15

    Sections[3].YAnchor:=Sections[2].Height-15
        , Sections[3].XAnchor:=Sections[2].XAnchor
        , Sections[3].Height:=(guiHeight-Sections[3].YAnchor)+3
        , Sections[3].Width:=Sections[2].Width
    global StatusBarMainWindow
        , vUsedConfigLocation
        , vStarterRScriptLocation
        , vreturnDays
        , vSaveFigures
        , vsaveRDATA
        , vSaveExcel
        , vRCRScript
        , vRCConfiguration
        , hwndLV_ConfigHistory
        , hwndLV_RScriptHistory
        , generateRScriptBtn
        , recompileBtn
        , vToggleLVReport
        , vToggleLVReport2
    gui GC: new
    gui GC:  +LabelGC +HWNDGCHWND
    gui GC: +Resize
    if (globalLogicSwitches.DEBUG) {
        gui -AlwaysOnTop
    }
    Names:=["1. Configuration File","2. R-Script- && CLI-Execution Configuration","4. Auxiliary Utilities","3. Preview"]
    ;gui GC: Show, % "w" guiWidth " h" guiHeight

    for each, section in Sections {
        Sections[each].Name:=Names[A_Index]
        gui add, text,% " y0 h0 w" 0 " x" 0, % section.name
    }
    ;; left side
    gui add, text,% "y15 x" Sections[1].XAnchor+5 " h0 w0",leftanchor
    gui add, text,% "y20 x" Sections[1].XAnchor+5 " h40 w350",% "Select the configuration file you want to use. Alternatively, choose a folder containing your data - where you want your configuration file to sit. All '.xlsx'/'.csv'-files in any subfolder will be used."
    ;gui add, button, y60 xp w80 hwndselectConfigLocation,% "Select &Folder"
    gui add, button,% "y60 w80 hwndnewConfigurationBtn x" Sections[1].XAnchor+5,% "New Config in Folder"
    gui add, button,% "yp w80 hwndeditConfigurationBtn x" Sections[1].XAnchor+95,% "Edit existing Config"
    gui add, edit,% "yp w160 hwnddropFilesEdit disabled -vscroll -hscroll x" Sections[1].XAnchor+180,% "Drop config file or config destination folder here"
    gui add, text,% "y100 x" Sections[1].XAnchor+5 "w0 h0"
    global dynGUI:= new gfcGUI("Experiment::blank",script.gfcGUIconfigfile,"-<>-",FALSE)
    dynGUI.GFA_Evaluation_Configfile_Location:=""
    dynGUI.GFA_Evaluation_RScript_Location:=""
    dynGUI.guiVisible:=false
        , dynGUI.GCHWND:=GCHWND
        , dynGUI.GenerateGUI(,,False,"GC:",false,Sections[1].Width-15,,9)

    ;; middle
    gui add, text,% "y15 x" Sections[2].XAnchor+5 " h0 w0", middleanchor
    gui add, text,% "y20 x" Sections[2].XAnchor+5 " h40 w350", % "Configure the R-Script used for running the GF-Analysis-Skript"
    gui add, button,% "y60 w80 hwndnewStarterScriptBtn x" Sections[2].XAnchor+5, % "New R-StarterScript"
    gui add, button,% "y60 w80 hwndeditStarterScriptBtn x" Sections[2].XAnchor+95, % "Edit existing R-StarterScript"
    gui add, edit,% "y60 w160 hwnddropFilesEdit2 disabled -vscroll -hscroll x" Sections[2].XAnchor+180,% "Drop RScript-file or RScript-destination folder here"
    gui add, text,% "y100 x" Sections[2].XAnchor+5 "w0 h0"
    gui add, checkbox, y125 xp hwndCheckreturnDays  vvreturnDays, Do you want to evaluate every day on its own?
    gui add, checkbox, y145 xp hwndCheckSaveFigures vvSaveFigures, Do you want to save 'Figures' to disk?
    gui add, checkbox, y165 xp hwndChecksaveRDATA   vvsaveRDATA, Do you want to save 'RData' to disk?
    gui add, checkbox, y185 xp hwndCheckSaveExcel   vvSaveExcel, Do you want to save 'Excel' to disk?
    gui add, text, % "x" Sections[3].XAnchor+5 " y" Sections[3].YAnchor+15 " h0 w0", middlebottomanchor
    gui add, tab3, % "hwndhwndTab3_2 x" Sections[3].XAnchor+5 " y" Sections[3].YAnchor+20 " h" (Sections[3].Height-(1*3 + 20)-2*15) " w" (Sections[3].Width - 3*5), Configurations and Image-renaming||R Scripts
    gui tab, Configurations and Image-renaming
    gui add, checkbox, % "hwndCheckToggleLVReport gtoggle_ReportTip x+5 y+5 vvToggleLVReport", % "Toggle Report-View?"
    gui add, button, % "hwndcsv2xlsxBtn yp-5 xp+120", % "csv&2xlsx"
    gui add, button, % "hwndrenameImagesBtn yp xp+55", % "rename &Images"
    gui add, button, % "hwndexecuteCLIBtn yp xp+87", % "CLI"

    gui add, Listview, % "hwndhwndLV_ConfigHistory +LV0x400 +LV0x10000 xp-262 y+5 h" (Sections[3].Height-(1*3 + 20)-2*15-3*5-5-35-20) " w" (Sections[3].Width - 3*5 - 3*5), Experiment's Name in Config|File Name|Full Path

    updateLV(hwndLV_ConfigHistory,script.config.LastConfigsHistory)

    ;; right
    RESettings2 :=
        ( LTrim Join Comments
            {
            "TabSize": 4,
            "Indent": "`t",
            "FGColor": 0xEDEDCD,
            "BGColor": 0x3F3F3F,
            "Font": {"Typeface": "Consolas", "Size": 11},
            "WordWrap": True,

            "UseHighlighter": True,
            "HighlightDelay": 200,
            "Colors": {
            "Comments":     0x7F9F7F,
            "Functions":    0x7CC8CF,
            "Keywords":     0xE4EDED,
            "Multiline":    0x7F9F7F,
            "Numbers":      0xF79B57,
            "Punctuation":  0x97C0EB,
            "Strings":      0xCC9893,

            ; AHK
            "A_Builtins":   0xF79B57,
            "Commands":     0xCDBFA3,
            "Directives":   0x7CC8CF,
            "Flow":         0xE4EDED,
            "KeyNames":     0xCB8DD9,

            ; CSS
            "ColorCodes":   0x7CC8CF,
            "Properties":   0xCDBFA3,
            "Selectors":    0xE4EDED,

            ; HTML
            "Attributes":   0x7CC8CF,
            "Entities":     0xF79B57,
            "Tags":         0xCDBFA3,

            ; JS
            "Builtins":     0xE4EDED,
            "Constants":    0xF79B57,
            "Declarations": 0xCDBFA3

            ; INI
            }
            }
        )
    gui tab, R Scripts
    gui add, checkbox, % "hwndCheckToggleLVReport2 gtoggle_ReportTip2 x+5 y+5 vvToggleLVReport2", % "Toggle Report-View?"
    gui add, Listview, % "hwndhwndLV_RScriptHistory +LV0x400 +LV0x10000 xp y+11 h" (Sections[3].Height-(1*3 + 20)-2*15-3*5-5-35-20) " w" (Sections[3].Width - 3*5 - 3*5), File Name|Full Path
    updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
    GuiControl Choose, vTab3, % "Configurations and Image-renaming"
    gui tab,
    gui add, text, % "y15 x" Sections[4].XAnchor+5 " h0 w0", rightanchor

    gui add, text, % "y20 x" Sections[4].XAnchor+5 " h40 w" Sections[4].Width - 3*5, curr. loaded R-Script
    gui add, edit,% "y" (20)-3 " x" Sections[4].XAnchor+5 + Sections[4].Width - (3*5) - (Sections[4].Width*0.85) + -1*2 " r1 disabled hwndhwndStarterRScriptLocation vvStarterRScriptLocation w" Sections[4].Width*0.85+4,   % "<Location of Starter-'.R'-Script>"
    global RC:=new GC_RichCode(RESettings2, "y45" " x" Sections[4].XAnchor+5 " w" Sections[4].Width - 3*5 " h489" , Func("HighlightR"))
    gui add, text, % "y" (45+489+5) " x" Sections[4].XAnchor+5 " h40 w" Sections[4].Width - (3*5) - (Sections[4].Width*0.85), curr. loaded Config
    gui add, edit,% "y" (45+489+5)-3 " x" Sections[4].XAnchor+5 + Sections[4].Width - (3*5) - (Sections[4].Width*0.85) + -1*2 " r1 disabled hwndhwndUsedConfigLocation vvUsedConfigLocation w" Sections[4].Width*0.85+4,   % "<Location of Configuration-'.ini'-File>"
    buttonHeight:=40
    global RC2:=new GC_RichCode(RESettings2,"y" (45+489+5+25) " x" Sections[4].XAnchor+5 " h" (guiHeight-(45+489+5+40+5+5+buttonHeight+5)) " w" Sections[4].Width - 3*5, Func("HighlightR"))
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndgenerateRScriptBtn x" Sections[4].XAnchor+5, % "Generate R-Script"
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndpreviewConfigurationBtn x" Sections[4].XAnchor+95, % "Preview Configuration"
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndgenerateConfigurationBtn x" Sections[4].XAnchor+185, % "Generate Configuration"
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndEditSettingsBtn gfEditSettings  x" Sections[4].XAnchor+275, % "Open &program settings"
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndOpenRScriptBtn x" Sections[4].XAnchor+365, % "Open current &script"
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndOpenConfigBtn x" Sections[4].XAnchor+455, % "Open current &config"
    gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80 hwndExitProgramBtn gexitApp x" Sections[4].XAnchor+545, % "Exit Program"
    if (globalLogicSwitches.bIsAuthor) {
        gui add, button,% "y" (45+489+5+25+(guiHeight-(45+489+5+40+5+5+buttonHeight+5))+5) " w80  gprepare_release hwndrecompileBtn x" Sections[4].XAnchor+635, % "Recompile"
    }

    gui add, statusbar, -Theme vStatusBarMainWindow  gfCallBack_StatusBarMainWindow
    if ((bShowDebugPanelINMenuBar) && (script.authorID=A_ComputerName)) {
        SB_SetParts(0,240,100,280,125,70,80,170)
    } Else {
        SB_SetParts(0,240,100,270,125,70,80)
    }
    SB_SetText(script.name " v." script.config.version.GFC_version A_Space script.config.version.build,2)
    SB_SetText(" by " script.author,3)
    if (globalLogicSwitches.bIsDebug) {
        SB_SetText("Author/Debug Mode Engaged. Click to exit debug-mode",4)
    } else {
        SB_SetText("Standard Mode Engaged. Click to enter debug-mode",4)
    }
    SB_SetText((A_IsAdmin?"Admin Privileges":"Standard privileges"),5)
    SB_SetText("Report a bug",6)
    SB_SetText("Documentation",7)
    guiObject:={guiWidth:guiWidth
            ,guiHeight:guiHeight
            ,dynGUI:dynGUI
            ,Sections:Sections
            ,XMarginWidth:XMarginWidth
            ,YMarginWidth:YMarginWidth}
    onEditConfiguration := Func("editConfiguration").Bind("")
        , onEditStarterScript := Func("editRScript").Bind("")
        , onPreviewConfiguration := Func("handleConfig").Bind(dynGUI,false)
        , onGenerateConfiguration := Func("handleConfig").Bind(dynGUI,true)
        , onCheckreturnDays:=Func("handleCheckboxesWrapper")
        , onCheckSaveFigures:=Func("handleCheckboxesWrapper")
        , onChecksaveRDATA:=Func("handleCheckboxesWrapper")
        , onCheckSaveExcel:=Func("handleCheckboxesWrapper")
        , onGenerateRScript:=Func("createRScript").Bind("D:/")
        , onLoadConfigFromLV:=Func("loadConfigFromLV").Bind(dynGUI)
        , onLoadRScriptFromLV:=Func("loadRScriptFromLV").Bind(dynGUI,guiObject)
        , oncsv2xlsx := Func("convertCSV2XLSX").Bind(dynGUI)
        , onrenameImages := Func("renameImages").Bind(dynGUI)
        , onexecuteCLI := Func("runCLI").Bind(dynGUI)
        , onOpencurrentScript := Func("runRScript").Bind(dynGUI)
        , onOpencurrentConfig := Func("runConfig").Bind(dynGUI)
    if (globalLogicSwitches.DEBUG) {
        onNewConfiguration := Func("createConfiguration").Bind(A_ScriptDir,guiObject)
        oncreateRScript := Func("createRScript").Bind(A_ScriptDir)
    } else {
        onNewConfiguration := Func("createConfiguration").Bind("D:/",guiObject)
        oncreateRScript := Func("createRScript").Bind("D:/")
    }
    if (globalLogicSwitches.bIsAuthor) {
        onRecompile := Func("prepare_release")
    }
    guiControl GC:+g, %generateRScriptBtn%, % onGenerateRScript
    guiControl GC:+g, %PreviewConfigurationBtn%, % onPreviewConfiguration
    guiControl GC:+g, %generateConfigurationBtn%, % onGenerateConfiguration
    guiControl GC:+g, %EditConfigurationBtn%, % onEditConfiguration
    guiControl GC:+g, %NewConfigurationBtn%, % onNewConfiguration
    guiControl GC:+g, %newStarterScriptBtn%, % oncreateRScript
    guiControl GC:+g, %editStarterScriptBtn%, % onEditStarterScript
    guiControl GC:+g, %hwndLV_ConfigHistory%, % onLoadConfigFromLV
    guiControl GC:+g, %hwndLV_RScriptHistory%, % onLoadRScriptFromLV
    guiControl GC:+g, %csv2xlsxBtn%, % oncsv2xlsx
    guiControl GC:+g, %renameImagesBtn%, % onrenameImages
    guiControl GC:+g, %executeCLIBtn%, % onexecuteCLI
    guiControl GC:+g, %openRScriptBtn%, % onOpencurrentScript
    guiControl GC:+g, %openConfigBtn%, % onOpencurrentConfig


    guiControl GC:+g, %CheckreturnDays%, % onCheckreturnDays
    guiControl GC:+g, %CheckSaveFigures%, % onCheckSaveFigures
    guiControl GC:+g, %ChecksaveRDATA%, % onChecksaveRDATA
    guiControl GC:+g, %CheckSaveExcel%, % onCheckSaveExcel
    if (globalLogicSwitches.bIsAuthor) {
        guiControl GC:+g, %recompileBtn%, % onRecompile
    }
    AddToolTip(newConfigurationBtn,"Create a new configuration-file in a desired folder.")
    AddToolTip(editConfigurationBtn,"Edit an existing configuration-file.")

    AddToolTip(newStarterScriptBtn,"Create a new RScript-file in a desired folder.")
    AddToolTip(editStarterScriptBtn,"Edit an existing RScript-file.")

    AddToolTip(CheckreturnDays,"Do you want to generate statistical data and a close-up  plot for each individual day?")
    AddToolTip(CheckSaveFigures,"Do you want to save generated figures to file?")
    AddToolTip(ChecksaveRDATA,"Do you want to save the R-Workspace to file after the **function 'GFA_Evaluation'** has run?`n`nNote: This will not save data not generated during the execution of this function.")
    AddToolTip(CheckSaveExcel,"Do you want to save statistical data to an xlsx-file?")



    AddToolTip(CheckToggleLVReport,"Change the view-type for the listview below between report and the traditional list view.`nList view is more compact, but Report-view may give more details on a specific file. Also people have preferences.")
    AddToolTip(CheckToggleLVReport2,"Change the view-type for the listview below between report and the traditional list view.`nList view is more compact, but Report-view may give more details on a specific file. Also people have preferences.")
    AddToolTip(renameImagesBtn,"It is recommended to rename images prior to analysis,`nand to do so with consistent naming scheme so that the resulting data is always sorted in the same manner.")
    AddToolTip(csv2xlsxBtn,"If a config-file has been selected (by the ListView below, or any other means), you`ncan use this button to automatically create xlsx-files for any csv-file which does not`nn have an xlsx-version. CSV-files are supported, but heavily discouraged by the author.",, GCHWND)
    AddToolTip(executeCLIBtn,"After selecting a configuration file and execution options, you`nmay run the GFA_Evaluation-Script with these parameters via R's command line.",, GCHWND)

    AddToolTip(generateRScriptBtn,"Write the RScript to the selected file.")
    AddToolTip(PreviewConfigurationBtn,"Preview the configuration options selected in section 1 without writing them to a file.")
    AddToolTip(generateConfigurationBtn,"Write the configuration options selected in section 1 to a file.")
    AddToolTip(EditSettingsBtn,"Open the settings for this program itself.")
    AddToolTip(openRScriptBtn,"Open the currently selected R-Script (see section 3, top). This program will`nattempt to open the script via the program associated with '.R'-files. If this`ndoes not work, it will recover by opening the containing folder instead.")
    AddToolTip(openConfigBtn,"Open the currently selected configuration-file (see section 3, bottom). This program will`nattempt to open the configuration via the program associated with '-ini'-files. If this`ndoes not work, it will recover by opening the containing folder instead.")
    AddToolTip(ExitProgramBtn,"Exit this program.")
    return guiObject
}
guiShow3(guiObject,ShowThirdPane:=true) {
    if (ShowThirdPane) {
        gui GC: show,% "w" guiObject["guiWidth"] " h" guiObject["guiHeight"] " x0 y0" , % script.name " - Complementary program for GFA_Evaluation.R"
    } else {
        gui GC: show,% "w" (guiObject["guiWidth"]-(guiObject["Sections"][4]["Width"]+guiObject.XMarginWidth*2)) " h" guiObject["guiHeight"] "x0 y0" , % script.name " - Complementary program for GFA_Evaluation.R"
    }
    return
}
guiShow2(guiObject) {
    if (WinActive("ahk_id " guiObject.dynGUI.GCHWND)) {
        guiShow(guiObject)
        guiObject.dynGUI.guiVisible:=true
    } else {
        guiShow(guiObject)
        guiObject.dynGUI.guiVisible:=true
    }
    return
}
guiShow(guiObject) {
    gui GC: default
    useGroupbox:=1
    for each, section in guiObject.Sections {
        if (useGroupbox) {
            if section.HasKey("YAnchor") {
                gui add, groupbox,% "hwndgb" each " y" section.YAnchor " h" section.Height-2*15 " w" section.Width " x" section.XAnchor-5, % section.name
            } else {
                gui add, groupbox,% "hwndgb" each " y3 h" section.Height-2*15 " w" section.Width " x" section.XAnchor-5, % section.name
            }
        } else {
            if section.HasKey("YAnchor") {
                gui add, text,% " y" section.YAnchor " h15 w" section.Width " x" section.XAnchor-5, % section.name
            } else {
                gui add, text,% " y3 h15 w" section.Width " x" section.XAnchor-5, % section.name
            }
        }
    }
    if (guiObject.dynGUI.GFA_Evaluation_Configfile_Location="") {
        gui GC: show,%   "AutoSize x0 y0" , % script.name " - Complementary program for GFA_Evaluation.R"
    } else {
        gui GC: show,% "w" guiObject["guiWidth"] " h" guiObject["guiHeight"] " Center" , % script.name " - Complementary program for GFA_Evaluation.R"
    }
    guicontrol GC: hide, % "vExcelSheetPreview"
    guiObject.dynGUI.guiVisible:=true
    handleCheckboxes()
    handleConfig(guiObject.dynGUI,false)
    ;handleExcelSheets(dynGUI.Arguments)
    Tabs:=[]
    TabName:="Example-Excel-File No. "
    loop, 12 {
        Tabs[A_Index]:=TabName A_Index
    }
    gui gc: default
    gui % "GC: " ((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
    if (globalLogicSwitches.DEBUG) {
        gui -AlwaysOnTop
    }
    return
}

guiHide() {
    GCEscape()
    return 
}
guiResize(guiObject,normalOperation:=true) {
    if (normalOperation) {
        if (guiObject.dynGUI.GFA_Evaluation_Configfile_Location="") && (guiObject.dynGUI.GFA_Evaluation_RScript_Location="") {
            guiShow3(guiObject,false)
        } else {
            guiShow3(guiObject,true)
        }
    }
    return
}
WinGetPos(title) {
    WinGetPos x, y, w, h, % title
    return {x: x, y: y, w: w, h: h}
}
GCSize() {
    ;global
    global gb3
    global gb4
    global hwndStarterRScriptLocation
    global hwndUsedConfigLocation
    global EditSettingsBtn
    global ExitProgramBtn
    global OpenRScriptBtn
    global OpenConfigBtn
    global recompileBtn
    global RC
    global RC2
    global hwndLV_ConfigHistory
    global hwndLV_RScriptHistory
    global hwndTab3_2
    global guiObject
    gui GC: default
    wgp := WinGetPos("ahk_id " guiObject.dynGUI.GCHWND)
    gui GC: default
    SB_SetText("x" wgp.x " y" wgp.y " w" wgp.w " h" wgp.H " " (A_IsCompiled?"Compiled":"Not Compiled"),8)
    AutoXYWH("h*", gb3)
    AutoXYWH("wh*", gb4)
    AutoXYWH("w", hwndStarterRScriptLocation)
    AutoXYWH("w", hwndUsedConfigLocation)
    AutoXYWH("y", EditSettingsBtn, ExitProgramBtn)
    AutoXYWH("y", OpenRScriptBtn)
    AutoXYWH("y", OpenConfigBtn)
    AutoXYWH("y", "Open current &script")
    AutoXYWH("y", "Open current &config")
    AutoXYWH("y", "Open &program settings")
    AutoXYWH("y", "Exit Program")
    AutoXYWH("y", "Generate Configuration")
    AutoXYWH("y", "Generate R-Script")
    AutoXYWH("y", "Preview Configuration")
    if (globalLogicSwitches.bIsAuthor) {
        AutoXYWH("y", recompileBtn)
    }
    AutoXYWH("w", RC.HWND)
    AutoXYWH("wh", RC2.HWND)
    AutoXYWH("h", hwndLV_ConfigHistory)
    AutoXYWH("h", hwndLV_RScriptHistory)
    AutoXYWH("h", hwndTab3_2)
    return
}

GCDropFiles(_GuiHwnd, File, _*) {

    global guiObject
    global hwndLV_RScriptHistory
    global hwndLV_ConfigHistory
    if (A_GuiControl="Drop config file or config destination folder here") {    ;; ini-file
        if (File.Count()>1) {
            AppError("2+ files/folders dropped", "You have dropped more than either 1 .ini-file or 1 folder on the GUI. This will not work. Please drop either a single file`, or a single folder onto the GUI.")
            return
        }
        if (InStr(FileExist(File[1]),"D")) { ; directory
            ; if directory, check first if ini-files exist
            ; multiple ini-files exist. if true, open a fileselectfile dialogue on that folder prompting to ask 
            iniCount:=0 
            loop, Files, % File[1] "\*.ini"        ;; check number of ini-files
            {
                iniCount:=A_Index
                confPath:=A_LoopFileFullPath
            }
            if (iniCount>1) {                       ;; multiple files, select one
                FileSelectFile configPath, 3, % File[1], % "Please select the ini-file you want to edit.", *.ini
            } else if (iniCount=1) {                ;; select the only one available
                configPath:=confPath
            } else if (iniCount=0) {                ;; create a new one
                FileSelectFile configPath, S8, % File[1], % "Please create the ini-file you want to use.", *.ini
            }
        } else { ; file
            configPath:=File[1]
        }
        loadConfig_Main(configPath,guiObject.dynGUI)
    } else if (A_GuiControl="Drop RScript-file or RScript-destination folder here") {                                                                    ;; Rscript-file
        if (File.Count()>1) {
            AppError("2+ files/folders dropped", "You have dropped more than either 1 .Rscript-file or 1 folder on the GUI. This will not work. Please drop either a single file`, or a single folder onto the GUI.")
            return
        }
        if (InStr(FileExist(File[1]),"D")) { ; directory
            ; if directory, check first if Rscript-files exist
            ; multiple Rscript-files exist. if true, open a fileselectfile dialogue on that folder prompting to ask 
            rCount:=0 
            loop, Files, % File[1] "\*.R"        ;; check number of Rscript-files
            {
                rCount:=A_Index
                R_Path:=A_LoopFileFullPath
            }
            if (rCount>1) {                       ;; multiple files, select one
                FileSelectFile rPath, 3, % File[1], % "Please select the Rscript-file you want to edit.", *.R
            } else if (rCount=1) {                ;; select the only one available
                rPath:=R_Path
            } else if (rCount=0) {                ;; create a new one
                FileSelectFile rPath, S8, % File[1], % "Please create the Rscript-file you want to use.", *.R
            }
        } else { ; file
            rPath:=File[1]
        }
        if (rPath="") {
            AppError("Selection-GUI got cancelled", "You have closed the selection-window without selecting an existing or creating a new Rscript-file. Please do either.")
            return
        }

        if RegexMatch(rPath,"\.ini$")  {
            AppError("Dropped config-file on rscript-dropper", "You have dropped the config-file`n`n'" rPath "'`n`n on the right selection-window. Please drag-and-drop an Rscript-file here instead.")
            return
        }
        if !RegexMatch(rPath,"\.R$")  {
            rPath.= ".R"
        }
        guicontrol % "GC:",vStarterRScriptLocation, % rPath
        if (rPath!="") {
            guiObject.dynGUI.GFA_Evaluation_RScript_Location:=rPath
            if (!InStr(rPath,A_ScriptDir)) {
                script.config.LastRScriptHistory:=buildHistory(script.config.LastRScriptHistory,script.config.Configurator_settings.ConfigHistoryLimit,rPath)
                updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
                script.save(script.scriptconfigfile,,true)
            }
        }
    } else { ;; anywhere else
        AppError("Files dropped somewhere", "You have dropped files outside the designated areas of the GUI. That is not permitted. Please drop them in their designated locations.")
        return
    }
    if (rPath!="") {
        guiObject.dynGUI.GFA_Evaluation_RScript_Location:=rPath
        guiResize(guiObject)
    }
    if (configPath!="") {
        guiObject.dynGUI.GFA_Evaluation_Configfile_Location:=configPath
        guiResize(guiObject)
    }
    return  
}
fillRC1(Code) {
    global RC
    gui GC: default
    Code:=FormatEx(Code,{GFA_EVALUATIONUTILITY:strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/")})
    RC.Settings.Highlighter:= "HighlightR"
        , RC.Value:= Code
    return
}
fillRC2(INI) {
    global RC2
    gui GC: default
    RC2.Settings.Highlighter:= "HighlightINI"
        , RC2.Value:= INI
    return
}
loadConfig_Main(configPath,dynGUI) {
    global hwndLV_ConfigHistory
    global guiObject
    if (configPath="") {
        AppError("Selection-GUI got cancelled", "You have closed the selection-window without selecting an existing or creating a new config-file. Please do either.")
        return
    }
    if RegexMatch(configPath,"\.R$")  {
        AppError("Dropped RScript-file on config-dropper", "You have dropped the RScript-file`n`n'" configPath "'`n`n on the left selection-window. Please drag-and-drop a configuration-file (.ini) here instead.")
        return
    }
    if !RegexMatch(configPath,"\.ini$") {
        configPath.= ".ini"
    }
    if !FileExist(configPath) {                 ;; create a new config file in the folder, use the current config selections existing in the GUI and write them to file
        dynGUI.generateConfig(0)
        written_config:=dynGUI.ConfigObject
        t_script:=new script_()
        t_script.Save(configPath,written_config)
    } else {                                    ;; a config-file exists - load the selections into the dynGUI; while doing so validate that all values are valid and that the ini is not corrupted.
        dynGUI.loadConfigFromFile(configPath)
        dynGUI.validateLoadedConfig()
        dynGUI.populateLoadedConfig()
        handleConfig(dynGUI,false)
        IniRead ExperimentName_Key, % configPath, Experiment, Name, % "Name not specified"
        SplitPath % configPath,,,, FileName
        itemLocation:=LV_EX_FindStringEx( hwndLV_ConfigHistory, configPath)
        if !itemLocation && !IsObject(itemLocation){
            gui listview,% hwndLV_ConfigHistory
            LV_Add("",ExperimentName_Key,FileName,configPath)
        }
    }
    guicontrol % "GC:",vUsedConfigLocation, % configPath
    if (configPath!="") {
        dynGUI.GFA_Evaluation_Configfile_Location:=configPath
        guiResize(guiObject)
        SplitPath % configPath,, Chosen
        if ((subStr(Chosen,-1)!="\") && (subStr(Chosen,-1)!="/")) {
            Chosen.="\"
        }
        Chosen:=configPath
        WINDOWS:=strreplace(Chosen,"/","\")
        MAC:=strreplace(Chosen,"/","\")
        String:=guiObject.RCodeTemplate
        ;needle:="GFA_main\((folder_path = r.+""),"
        ;rep1:="GFA_main(folder_path = r""("
        ;rep2:=")"","
        ;Matches:=RegexMatchAll(String, "iU)" needle)
        ;for _, match in Matches {                                                  ;; star, top
        ;    match_ := match[0]
        ;    if (_<2) {
        ;        String:=strreplace(String,match_,rep1 WINDOWS rep2)
        ;    } else {
        ;        String:=strreplace(String,match_,rep1 MAC rep2)
        ;    }
        ;}
        if (script.config.Configurator_settings.UseRelativeConfigPaths) {
            SplitPath WINDOWS,  WINDOWS
            SplitPath MAC,  MAC
        }
        RC1Object:={GFA_CONFIGLOCATIONFOLDER_WINDOWS:WINDOWS
                , GFA_CONFIGLOCATIONFOLDER_MAC:MAC
                ,GFA_EVALUATIONUTILITY:strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/")}
        String:=FormatEx(String,RC1Object)
        if (!InStr(String,WINDOWS) || !InStr(String,MAC,,,2)) {
            needle:="GFA_main\((folder_path = r.+""),"
            rep1:="GFA_main(folder_path = r""("
            rep2:=")"","
            Matches:=RegexMatchAll(String, "iU)" needle)
            for _, match in Matches {                                                  ;; star, top
                match_ := match[0]
                if (_<2) {
                    String:=strreplace(String,match_,rep1 WINDOWS rep2)
                } else {
                    String:=strreplace(String,match_,rep1 MAC rep2)
                }
            }
        }
        guiObject.RCodeTemplate:=String
        handleCheckboxesWrapper()
    }
    return
}

handleCheckboxesWrapper() {
    fillRC1(handleCheckboxes())
}

handleCheckboxes() {
    global guiObject
    global vreturnDays
    global vSaveFigures
    global vsaveRDATA
    global vSaveExcel
    gui GC: submit, nohide
    template:=guiObject.RCodeTemplate
    template:=strreplace(template,"returnDays = %breturnDays%","returnDays = " vreturnDays)
    template:=strreplace(template,"saveFigures = %bSaveFigures%","saveFigures = " vSaveFigures)
    template:=strreplace(template,"saveRDATA = %bsaveRDATA%","saveRDATA = " vsaveRDATA)
    template:=strreplace(template,"saveExcel = %bSaveExcel%","saveExcel = " vSaveExcel)
    template:=strreplace(template,"returnDays = 1","returnDays = " vreturnDays)
    template:=strreplace(template,"saveFigures = 1","saveFigures = " vSaveFigures)
    template:=strreplace(template,"saveRDATA = 1","saveRDATA = " vsaveRDATA)
    template:=strreplace(template,"saveExcel = 1","saveExcel = " vSaveExcel)
    template:=strreplace(template,"returnDays = 0","returnDays = " vreturnDays)
    template:=strreplace(template,"saveFigures = 0","saveFigures = " vSaveFigures)
    template:=strreplace(template,"saveRDATA = 0","saveRDATA = " vsaveRDATA)
    template:=strreplace(template,"saveExcel = 0","saveExcel = " vSaveExcel)
    return template
}
handleConfig(dynGUI,writetoFile:=false) {
    dynGUI.generateConfig(0)
    if (dynGUI.ConfigString!="") {
        fillRC2(dynGUI.ConfigString)
    }
    if (writetoFile) {
        SplitPath % dynGUI.GFA_Evaluation_Configfile_Location,,,,, OutDrive     ;; we do it this way because we can also write a new, so-far nonexistant, file to disk. In that case, doing FileExist() on its whole path would fail.
        if (!FileExist(OutDrive) || dynGUI.GFA_Evaluation_Configfile_Location="") { ;; can't believe this is necessary...
            ttip("You have not yet selected a location for your configuration file. Please do so before attempting to save your configuration.")
            return
        }
        try {
            if (!InStr(dynGUI.GFA_Evaluation_Configfile_Location,A_ScriptDir)) {
                writeFile(dynGUI.GFA_Evaluation_Configfile_Location,dynGUI.ConfigString,script.config.Configurator_settings.INI_Encoding,,1)
                script.config.LastConfigsHistory:=buildHistory(script.config.LastConfigsHistory,script.config.Configurator_settings.ConfigHistoryLimit,dynGUI.GFA_Evaluation_Configfile_Location)
                script.save(script.scriptconfigfile,,true)
            } else { ;; only update the config file, but do not update the script data
                writeFile(dynGUI.GFA_Evaluation_Configfile_Location,dynGUI.ConfigString,script.config.Configurator_settings.INI_Encoding,,1)
            }
        } catch {
            throw Exception( "Failed to write config with encoding '" script.config.Configurator_Settings.INI_Encoding "' to path '" dynGUI.GFA_Evaluation_Configfile_Location "'`n`n" CallStack(),-1)
        }
    }
    return
}
GCSubmit() {
    gui GC: submit
    return
}
GCEscape() {
    gui GC: hide
    return
}

fCallBack_StatusBarMainWindow() {
    gui GC: Submit, NoHide
    gui GC: -AlwaysOnTop
    if ((A_GuiEvent="DoubleClick") && (A_EventInfo=1)) {        ; part 0  -  ??

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=2)) { ; part 1  -  build/version - check for updates
        if (script.config.Configurator_settings.UpdateChannel="stable") {
            script.Update(script.vfile,script.rfile,1,,,1)
        } else if (script.config.Configurator_settings.UpdateChannel="development") {
            script.Update(script.vfile_dev,script.rfile_dev,1,,,1)
        }
        gui % "GC: "((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
        gui % "GC: Default"
        gui % "GC: +OwnDialogs"
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=3)) { ; part 2  -  Author
        script.About()
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=4)) { ; part 3  -  Mode Toggle
        globalLogicSwitches.bIsDebug:=!globalLogicSwitches.bIsDebug
        ; (not author + not debug)                                             || author + not debug
        if (!(script.authorID!=A_ComputerName) & !globalLogicSwitches.bIsDebug) || ((script.authorID!=A_ComputerName) & !globalLogicSwitches.bIsDebug)
        { ;; public display
            SB_SetText("Standard Mode Engaged. Click to enter debug-mode",4)
            SoundBeep 150, 150
            SoundBeep 150, 150
            SoundBeep 150, 150
            ListLines Off
        }
        else if (!(script.authorID!=A_ComputerName)) || ((script.authorID!=A_ComputerName) && globalLogicSwitches.bIsDebug)
        {
            SoundBeep 1750, 150
            SoundBeep 1750, 150
            SoundBeep 1750, 150
            SB_SetText("Author/Debug Mode Engaged. Click to exit debug-mode",4)
            Clipboard:=ttip(["guiWidth: " guiWidth
                    ,"guiHeight: " guiHeight
                    ,"A_ScreenHeight " A_ScreenHeight
                    ,"A_ScreenWidth " A_ScreenWidth
                    , "A_DPI " A_ScreenDPI
                    , "Size Setting  " script.config.SizeSetting
                    ,"height-mwa 1440p: " 1392 - 2*30
                    ,"guiWidth 1440p: " 2560 - 2*30
                    ,"guiWidth  1080p: " 1920 - 2*30
                    ,"height-mwa 1080p: " 1032 - 2*30,["bIsAuthor: " globalLogicSwitches.bIsAuthor,"bisDEBUG: " globalLogicSwitches.bIsDebug,"DEBUG " globalLogicSwitches.DEBUG]
                    , ["Loaded script Configuration: ",script.config]],1,2300)
            ListLines On
        }
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=5)) { ; part 4 - script privileges
        if (!A_IsAdmin) {
            answer := AppError("Do you want to elevate the program ?", "Do you want to reload the program with administrator-privilages without saving any data? `n`nAny currently unsaved changes will not be saved.",0x34," - ")
            if (answer = "Yes") {
                RunAsAdmin()
            }
        }
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=6)) { ; part 5 - report bug
        if script.requiresInternet(script.metadataArr.Issues) {
            script.About(1)
            run % "https://www." script.metadataArr.Issues
        }
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=7)) { ; part 6 - documentation
        if script.requiresInternet(script.metadataArr["GH-Repo"]) {
            run % "https://htmlpreview.github.io/?https://" script.metadataArr.Documentation2
            script.About(1)
        }
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=8)) { ; part 7

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=9)) { ; part 8

    }
    gui % "GC: " ((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
    gui GC: Default
    gui GC: +OwnDialogs
    return
}
createConfiguration(Path,guiObject) {
    global hwndLV_ConfigHistory
    global dynGUI
    if (!globalLogicSwitches.DEBUG) {
        SearchPath:="C://"
    }
    if (!FileExist(Path)) {
        SearchPath:="C://"
    } else {
        SearchPath:=Path
    }
    gui -AlwaysOnTop
    FileSelectFile Chosen, S8, % SearchPath, % "Please create the ini-file you want to use.", *ini
    if (Chosen!="") {
        if !RegexMatch(Chosen,"\.ini$") {
            Chosen.=".ini" 
        }
        guicontrol % "GC:",vUsedConfigLocation, % Chosen
        if (!FileExist(Chosen)) {
            writeFile(Chosen,"",script.config.Configurator_settings.INI_Encoding,,true)
        } else {
            dynGUI.loadConfigFromFile(Chosen)
                , dynGUI.validateLoadedConfig()
                , dynGUI.populateLoadedConfig()
                , handleConfig(dynGUI,false)
            IniRead ExperimentName_Key, % Chosen, Experiment, Name, % "Name not specified"
            SplitPath % Chosen,,,, FileName
            itemLocation:=LV_EX_FindStringEx( hwndLV_ConfigHistory, Chosen)
            if !itemLocation && !IsObject(itemLocation){
                gui listview,% hwndLV_ConfigHistory
                LV_Add("",ExperimentName_Key,FileName,Chosen)
            }
        }
    } else {
        ttip("Please select a configuration file. Aborting file-creation.")
        return
    }
    GFA_configurationFile:=Chosen
        , dynGUI.GFA_Evaluation_Configfile_Location:=Chosen
    guiResize(guiObject)
    if (Chosen!="") {

        if (script.config.Configurator_settings.UseRelativeConfigPaths) {
            if (InStr(FileExist(Chosen),"D")) { ;; directory
                Chosen.="\GFA_conf.ini"
            }
            WINDOWS:=strreplace(Chosen,"/","\")
            MAC:=strreplace(Chosen,"/","\")
            SplitPath WINDOWS,  WINDOWS, GFA_Evaluation_RScript_Location
            SplitPath MAC,  MAC
            guiObject.dynGUI.GFA_Evaluation_RScript_Location:=GFA_Evaluation_RScript_Location "\RScript.R"
            guicontrol % "GC:",vStarterRScriptLocation, % guiObject.dynGUI.GFA_Evaluation_RScript_Location
            if !FileExist(guiObject.dynGUI.GFA_Evaluation_RScript_Location) {
                writeFile(guiObject.dynGUI.GFA_Evaluation_RScript_Location,"","UTF-8-RAW",,true)
            }
        } else {
            if (InStr(FileExist(Chosen),"D")) { ;; directory
                Chosen.="\GFA_conf.ini"
            }
            WINDOWS:=strreplace(Chosen,"/","\")
            MAC:=strreplace(Chosen,"/","\")
        }
        String:=guiObject.RCodeTemplate
        RC1Object:={GFA_CONFIGLOCATIONFOLDER_WINDOWS:WINDOWS
                , GFA_CONFIGLOCATIONFOLDER_MAC:MAC
                ,GFA_EVALUATIONUTILITY:strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/")}
        String:=FormatEx(String,RC1Object)
        guiObject.RCodeTemplate:=String
        handleCheckboxesWrapper()
    }
    gui % "GC: " ((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
    return Chosen
}
editConfiguration(configurationFile) {
    global guiObject
    gui Submit,NoHide
    ;; we do the InStr-Check this way because for some reason this sometimes returns 'A', and sometimes returns 'N', even though both times the file is correct and does exist. No clue why, but this is what it is.
    if (InStr("AN",FileExist(guiObject.dynGUI.GFA_Evaluation_Configfile_Location)) && (guiObject.dynGUI.GFA_Evaluation_Configfile_Location!="")) {      ;; if you have a config-file selected, run createConfiguration on that location
        SplitPath % guiObject.dynGUI.GFA_Evaluation_Configfile_Location,, OutDir
        GFA_configurationFile:=createConfiguration(OutDir,guiObject)
    } else if (InStr("AN",FileExist(guiObject.dynGUI.GFA_Evaluation_RScript_Location)) && (guiObject.dynGUI.GFA_Evaluation_RScript_Location!="")) {      ;; if you have a script-file selected, run createConfiguration on that location
        SplitPath % guiObject.dynGUI.GFA_Evaluation_RScript_Location,, OutDir
        GFA_configurationFile:=createConfiguration(OutDir,guiObject)
    } else if (InStr("AN",FileExist(configurationFile)) && (configurationFile!="")) {
        run % configurationFile
    } else {
        if (globalLogicSwitches.DEBUG) {
            GFA_configurationFile:=createConfiguration(A_ScriptDir,guiObject)
        } else {
            GFA_configurationFile:=createConfiguration("D:/",guiObject)
        }
    }
    gui GC: default
    return
}
editRScript(rScriptFile) {
    global guiObject
    global hwndLV_RScriptHistory
    gui Submit,NoHide
    if (FileExist(rScriptFile)) {
        run % rScriptFile
    } else if (FileExist(guiObject.dynGUI.GFA_Evaluation_Configfile_Location)) {
        SplitPath % guiObject.dynGUI.GFA_Evaluation_Configfile_Location,, OutDir
        GFA_rScriptFile:=createRScript(OutDir,true,true)
    } else {
        if (globalLogicSwitches.DEBUG) {
            GFA_rScriptFile:=createRScript(A_ScriptDir)
        } else {
            GFA_rScriptFile:=createRScript("D:/")
        }
    }
    if (GFA_rScriptFile!="") {
        script.config.LastRScriptHistory:=buildHistory(script.config.LastRScriptHistory,script.config.Configurator_settings.ConfigHistoryLimit,GFA_rScriptFile)
        updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
        script.save(script.scriptconfigfile,,true)
    }
    gui GC: default
    return
}
;@ahk-neko-ignore 1 line; Function too big.
createRScript(Path,forceSelection:=false,overwrite:=false) {
    global
    static Chosen
    gui Submit, NoHide


    SplitPath % dynGUI.GFA_Evaluation_RScript_Location,,OutDir
    if (!(FileExist(dynGUI.GFA_Evaluation_RScript_Location) && InStr(dynGUI.GFA_Evaluation_Configfile_Location,OutDir))) { ;; can't believe this is necessary...
        if FileExist(dynGUI.GFA_Evaluation_Configfile_Location) {
            SplitPath % dynGUI.GFA_Evaluation_Configfile_Location, , SearchPath,
        }
    }
    if (!globalLogicSwitches.DEBUG) {
        SearchPath:="C:\"
    }
    if (SearchPath="") {
        if (!FileExist(Path)) {
            if IsObject(Path) {
                if (Path.HasKey("GFA_Evaluation_Configfile_Location")) {
                    SplitPath % Path.GFA_Evaluation_Configfile_Location,, SearchPath
                } else {
                    SearchPath:="C:\"
                }
            } else {
                SearchPath:="C:\"
            }
        } else {
            SearchPath:=Path
        }
    } else {
        if (FileExist(vStarterRScriptLocation)) {
            Chosen:=vStarterRScriptLocation
            forceSelection:=false
        }
    }
    if (Chosen="" || forceSelection || InStr("Edit existing R-StarterScript|||New &R-StarterScript",A_GuiControl)) {
        FileSelectFile Chosen, S8, % SearchPath, % "Please create the Rscript-file you want to use.", *.R
    }
    if (!InStr(Chosen,SearchPath) && (dynGUI.GFA_Evaluation_Configfile_Location!="")) {
        HeuristicRScript_config_match:=determineHeuristicScriptRelationByPath(Chosen,dynGUI.GFA_Evaluation_Configfile_Location,dynGUI)
        if (!InStr(Chosen,SearchPath) && (dynGUI.GFA_Evaluation_Configfile_Location!="")) && (!HeuristicRScript_config_match) {
            ;; we changed folder away from the initial config folder, so... throw an error to warn the user?!
            msg := "The script ""thinks"" by a simple heuristic approach that the given config file:"
                . "`n"
                . "`n'" dynGUI.GFA_Evaluation_Configfile_Location "'"
                . "`n"
                . "`nand the selected location for the RScript:"
                . "`n"
                . "`n'" Chosen "'"
                . "`n"
                . "`ndo not match."
                . (HeuristicRScript_config_match>-1?"`nDo you still want to write to the shown rscript-location? THIS MIGHT RESULT IN LOSS OF DATA, as the entire R-Script File will be overwritten.":"")
                . (HeuristicRScript_config_match==-1?"`nYou are trying to edit an rscript-file which lies in a folder other than the one the current configuration-file lies in. You must decide if you want to use this path, or not.":"")
                . (HeuristicRScript_config_match==-2?"`nCritical error: The arguments-structure currently loaded does not contain the required object structure 'this.Arguments'":"")
                . (HeuristicRScript_config_match==-3?"`nCritical error: the config key 'UniqueGroups' does not exist in the currently loaded config":"")
                . (HeuristicRScript_config_match==-4?"`nCritical error: the config key 'UniqueGroups' is not populated in the currently loaded config":"")
            answer := AppError(script.name " - " A_ThisFunc " - Config-Script-Mismatch", msg, 0x4)
            if (HeuristicRScript_config_match<0) { ;; errors are critical, so throw them and interrupt flow
                str:=(HeuristicRScript_config_match==-1?"`nYou are trying to edit an rscript-file which lies in a folder other than the one the current configuration-file lies in. You must decide if you want to use this path, or not.":(HeuristicRScript_config_match==-2?"`nCritical error: The arguments-structure currently loaded does not contain the required object structure 'this.Arguments'":(HeuristicRScript_config_match==-3?"`nCritical error: the config key 'UniqueGroups' does not exist in the currently loaded config":(HeuristicRScript_config_match==-4?"`nCritical error: the config key 'UniqueGroups' is not populated in the currently loaded config":""))))
                throw Exception(str "`n" CallStack(), -1)
            } else if (answer = "No") {
                FileSelectFile Chosen, S8, % SearchPath, % "Please create the Rscript-file you want to use.", *.R
            }
        }
    }
    if (Chosen!="") {
        configLocationFolder:=guiObject.dynGUI.GFA_Evaluation_Configfile_Location
        if ((StrLen(configLocationFolder)=0) || (configLocationFolder="")) {
            ttip("No config location selected so far. Please first select a config file before creating/editing an R-Script.")
            return
        }
    }
    if (Chosen!="") {
        SplitPath % Chosen, , , OutExtension
        if (!InStr(Chosen,".R") && (OutExtension!="R")) {
            Chosen:=Chosen ".R"
        }
        guicontrol % "GC:",vStarterRScriptLocation, % Chosen
        if (Chosen!="") {
            dynGUI.GFA_Evaluation_RScript_Location:=Chosen
        }
        if (!FileExist(Chosen)) {
            writeFile(Chosen,"","UTF-8-RAW",,true)
        } else {
            of:=fileOpen(dynGUI.GFA_Evaluation_RScript_Location,"r","UTF-8-RAW")
            current_contents:=of.Read()
            current_contents:=strreplace(current_contents,"`r`n","`n")
            of.Close()
        }
        guiResize(guiObject)
    }
    if (Chosen!="") {
        if (overwrite) {
            guiObject.RCodeTemplate:=handleCheckboxes()
            if ((subStr(configLocationFolder,-1)!="\") && (subStr(configLocationFolder,-1)!="/") && (subStr(configLocationFolder,-3)!=".ini")) {
                configLocationFolder.="\"
            }
            WINDOWS:=strreplace(configLocationFolder,"/","\")
            MAC:=strreplace(configLocationFolder,"/","\")
            if (script.config.Configurator_settings.UseRelativeConfigPaths) {
                SplitPath WINDOWS,  WINDOWS
                SplitPath MAC,  MAC
            }
            RC1Object:={GFA_CONFIGLOCATIONFOLDER_WINDOWS:WINDOWS
                    , GFA_CONFIGLOCATIONFOLDER_MAC:MAC
                    ,GFA_EVALUATIONUTILITY:strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/")}
            Code:=FormatEx(guiObject.RCodeTemplate,RC1Object)
            if (!InStr(Code,WINDOWS) || !InStr(Code,MAC,,,2)) {
                needle:="GFA_main\((folder_path = r.+""),"
                rep1:="GFA_main(folder_path = r""("
                rep2:=")"","
                Matches:=RegexMatchAll(String, "iU)" needle)
                for _, match in Matches {                                                  ;; star, top
                    match_ := match[0]
                    if (_<2) {
                        String:=strreplace(String,match_,rep1 WINDOWS rep2)
                    } else {
                        String:=strreplace(String,match_,rep1 MAC rep2)
                    }
                }
            }
            if ((StrLen(current_contents)>0) && (current_contents!="")) {
                if (Code!=current_contents) {
                    Code:=compareRScripts(Code,current_contents,guiObject.dynGUI.GCHWND,Chosen)
                }
            }
            fillRC1(Code)
            try {
                writeFile(Chosen,Code,"UTF-8-RAW",,true)
                if (Chosen!="") {
                    script.config.LastRScriptHistory:=buildHistory(script.config.LastRScriptHistory,script.config.Configurator_settings.ConfigHistoryLimit,Chosen)
                    updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
                    script.save(script.scriptconfigfile,,true)
                }
            } catch {
                throw Exception( "Failed to write script-file with encoding 'UTF-8-RAW' to path '" Chosen "'`n`n" CallStack(),-1)
            }
        } else {

            guiObject.RCodeTemplate:=handleCheckboxes()
            configLocationFolder:=guiObject.dynGUI.GFA_Evaluation_Configfile_Location
            if ((subStr(configLocationFolder,-1)!="\") && (subStr(configLocationFolder,-1)!="/") && (subStr(configLocationFolder,-3)!=".ini")) {
                configLocationFolder.="\"
            }
            WINDOWS:=strreplace(configLocationFolder,"/","\")
            MAC:=strreplace(configLocationFolder,"/","\")
            if (script.config.Configurator_settings.UseRelativeConfigPaths) {
                SplitPath WINDOWS,  WINDOWS
                SplitPath MAC,  MAC
            }
            RC1Object:={GFA_CONFIGLOCATIONFOLDER_WINDOWS:WINDOWS
                    , GFA_CONFIGLOCATIONFOLDER_MAC:MAC
                    ,GFA_EVALUATIONUTILITY:strreplace(script.config.Configurator_settings.GFA_Evaluation_InstallationPath,"\","/")}
            Code:=FormatEx(Code,RC1Object)
            if ((StrLen(current_contents)>0) && (current_contents!="")) {
                if (Code!=current_contents) {
                    Code:=compareRScripts(Code,current_contents,guiObject.dynGUI.GCHWND,Chosen)
                }
            }
            fillRC1(Code)
            try {
                writeFile(Chosen,Code,"UTF-8-RAW",,true)
                if (GFA_rScriptFile!="") {
                    script.config.LastRScriptHistory:=buildHistory(script.config.LastRScriptHistory,script.config.Configurator_settings.ConfigHistoryLimit,GFA_rScriptFile)
                    updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
                    script.save(script.scriptconfigfile,,true)
                }
            } catch {
                throw Exception( "Failed to write script-file with encoding 'UTF-8-RAW' to path '" Chosen "'`n`n" CallStack(),-1)
            }
        }
    }
    return Chosen
}
compareRScripts(new_contents,current_contents,HWND,Filepath) {
    global compare_contents_UseNew:=""
    global compare_returnedContent:=""
    if (script.config.Configurator_settings.SizeSetting="auto") { ; auto
        SysGet A, MonitorWorkArea
        guiHeight:=ABottom - 2*30
            , guiWidth:=A_ScreenWidth - 2*30
    } else if (script.config.Configurator_settings.SizeSetting="1440p") { ; 1440p
        guiWidth:=2560 - 2*30
            , guiHeight:=1392 - 2*30
    } else if (script.config.Configurator_settings.SizeSetting="1080p") { ; 1080p
        guiWidth:=1920 - 2*30
            , guiHeight:=1032 - 2*30
    }
    DPIAdjustmentFactor:=(1/(A_ScreenDPI/96))
    guiWidth:=guiWidth * DPIAdjustmentFactor
    guiHeight:=guiHeight * DPIAdjustmentFactor
    RCWidth:=(guiWidth-3*15)/2

    gui compare_contents: destroy
    gui compare_contents: new
    gui compare_contents: +HWNDCCHWND +Owner%HWND% -SysMenu +ToolWindow -caption +Border +AlwaysOnTop
    gui %HWND%:+Disabled
    RESettings2 :=
        ( LTrim Join Comments
            {
            "TabSize": 4,
            "Indent": "`t",
            "FGColor": 0xEDEDCD,
            "BGColor": 0x3F3F3F,
            "Font": {"Typeface": "Consolas", "Size": 11},
            "WordWrap": True,

            "UseHighlighter": True,
            "HighlightDelay": 200,
            "Colors": {
            "Comments":     0x7F9F7F,
            "Functions":    0x7CC8CF,
            "Keywords":     0xE4EDED,
            "Multiline":    0x7F9F7F,
            "Numbers":      0xF79B57,
            "Punctuation":  0x97C0EB,
            "Strings":      0xCC9893,

            ; AHK
            "A_Builtins":   0xF79B57,
            "Commands":     0xCDBFA3,
            "Directives":   0x7CC8CF,
            "Flow":         0xE4EDED,
            "KeyNames":     0xCB8DD9,

            ; CSS
            "ColorCodes":   0x7CC8CF,
            "Properties":   0xCDBFA3,
            "Selectors":    0xE4EDED,

            ; HTML
            "Attributes":   0x7CC8CF,
            "Entities":     0xF79B57,
            "Tags":         0xCDBFA3,

            ; JS
            "Builtins":     0xE4EDED,
            "Constants":    0xF79B57,
            "Declarations": 0xCDBFA3

            ; INI
            }
            }
        )

    gui add, text, x15 y15 w0 h0, % "anchor"
    gui add, text, x15 y25 h15, % "Old Code"
    global RC_Old:=new GC_RichCode(RESettings2, "y45" " x" 15 " w" RCWidth " h560" , HighlightBound=Func("HighlightR"))
    gui add, button,% "xp"+ RCWidth - 160 " yp+560 gcompareKeepOld w160", % "Keep &old contents"
    gui add, edit,%  "hwndhwndcompare_contentsCurrPath h15 disabled x" 0.3*guiWidth " w" guiWidth*(1-2*0.3), % Filepath
    gui add, text,%  "x" 15 + RCWidth + 15 " y25 h15", % "New Code"
    global RC_New:=new GC_RichCode(RESettings2, "y45" " x" 15 + RCWidth + 15 " w" RCWidth " h560" , HighlightBound=Func("HighlightR"))
    gui add, button,% "xp" +0 - 0 " yp+560 gcompareUseNew w160", % "Overwrite with &new contents"
    RC_Old.Settings.Highlighter:= "HighlightR"
        , RC_Old.Value:= current_contents
    RC_New.Settings.Highlighter:= "HighlightR"
        , RC_New.Value:= new_contents
    gui compare_contents: show,% "w" guiWidth " h" guiHeight " x0 y0 AutoSize" , % script.name " - Select script contents to keep"
    WinWait % script.name " - Select script contents to keep"
    CenterControl(CCHWND,hwndcompare_contentsCurrPath,0,0)
    WinWaitClose % script.name " - Select script contents to keep"
    gui %HWND%:-Disabled
    return compare_returnedContent

}
#if WinActive("ahk_id " CCHWND)
!F4::ttip("You cannot close this window.")
#if
runRScript(dynGUI) {
    if (dynGUI.HasKey("GFA_Evaluation_RScript_Location")) {
        if (dynGUI.GFA_Evaluation_RScript_Location!="") {
            if (FileExist(dynGUI.GFA_Evaluation_RScript_Location)) {
                try {
                    run % "*edit " dynGUI.GFA_Evaluation_RScript_Location,,UseErrorLevel
                    if (ErrorLevel!=0) {
                        run % "explore " dynGUI.GFA_Evaluation_RScript_Location,,UseErrorLevel
                        if (ErrorLevel!=0) {
                            SplitPath % dynGUI.GFA_Evaluation_RScript_Location, , OutDir
                            Run %  OutDir
                        }
                    }
                } catch {
                    if (ErrorLevel!=0) {
                        run % dynGUI.GFA_Evaluation_RScript_Location,,UseErrorLevel
                        if (ErrorLevel!=0) {
                            SplitPath % dynGUI.GFA_Evaluation_RScript_Location,, OutDir
                            Run %  OutDir
                        }
                    }
                }
            } else {
                ttip("The selected R-Script does not exist.")
            }
        } else {
            ttip("No R-Script has been selected yet.")
        }
    } else {
        ttip("No R-Script has been selected yet.")
    }
    return
}
runConfig(dynGUI) {
    if (dynGUI.HasKey("GFA_Evaluation_Configfile_Location")) {
        if (dynGUI.GFA_Evaluation_Configfile_Location!="") {
            if (FileExist(dynGUI.GFA_Evaluation_Configfile_Location)) {
                SplitPath % dynGUI.GFA_Evaluation_Configfile_Location, , OutDir
                Run %  OutDir
            } else {
                ttip("The selected Configuration does not exist.")
            }
        } else {
            ttip("No configuration has been selected yet.")
        }
    } else {
        ttip("No configuration has been selected yet.")
    }
    return
}
copyGFA_EvaluationFolder(Path) {
    Clipboard:=strreplace(Path,"\","/")
    return
}
runCLI(dynGUI) {
    if (dynGUI.GFA_Evaluation_Configfile_Location!="") {
        GetStdStreams_WithInput("where rscript", A_ScriptDir,InOut)
        InOut:=strreplace(InOut,"`n")
        if (!FileExist(InOut)) {
            t:="'RScript' not found"
            m:="'RScript.exe' is not part of the 'PATH'-Variable.`nPlease refer to the documentation for further details. Open documentation now?"
            answer := AppError(t,m,0x4," - ")
            OnMessage(0x44, "")
            if (answer = "Yes") {
                run % "https://htmlpreview.github.io/?https://" script.metadataArr.Documentation2
            }
            return
        } else {
            global vreturnDays
            global vSaveFigures
            global vsaveRDATA
            global vSaveExcel
            gui GC: submit, nohide
            sF:=1
                , sD:=(vreturnDays?1:0)
                , sR:=(vsaveRDATA?1:0)
                , sE:=(vSaveExcel?1:0)

            Command:="rscript gfa_evaluation.r -i """ dynGUI.GFA_Evaluation_Configfile_Location """ -d " sD " -f " sF " -e " sE " -r " sR
            SplitPath % script.config.Configurator_settings.GFA_Evaluation_InstallationPath,, OutDir
            ttip("Executing 'GFA_Evaluation()'...",5)
            ts:=A_Now
            GetStdStreams_WithInput(Command,OutDir, InOut)
            SplitPath % dynGUI.GFA_Evaluation_Configfile_Location,, OutDir
            tf:=A_Now
                , errorlog:=OutDir "\GFA_Evaluation_EL_" A_Now ".txt"
            if (!InStr(InOut,"<-- GFA_Main(): Execution finished")) {
                ttip("GFA_Evaluation: Execution failed.")
                Title:= " - " A_ThisFunc " - Script-Execution failed" 
                Message:="The R-Script 'GFA_Evaluation.R' (Path:" dynGUI.GFA_Evaluation_InstallationPath ") failed to finish execution. The complete callstack of the execution was printed to the file '" errorlog "'`n`nOpen the errorlog now?"
                writeFile(errorlog,InOut,"utf-8-raw",,true)
                Gui +OwnDialogs
                AppError(Title, Message,0x14,"")
                IfMsgBox Yes, {
                    Run %  "*edit " errorlog
                } Else IfMsgBox No, {
                    return
                }
            } else {
                if (InStr(InOut,"GFA_Main(): Execution finished")) {
                    tdiff:=tf-ts
                    time:=Format("{:02}:{:02}", tdiff//60, Mod(tdiff, 60))
                    ttip("GFA_Evaluation: Execution finished in " time " [mm:ss]")
                }
                Title:= " - " A_ThisFunc " - Script-Execution succeeded" 
                    , Message:="GFA_Evaluation: Execution finished.`nThe complete callstack of the execution was printed to the file '" errorlog "'.`n`nOpen the errorlog now?"
                writeFile(errorlog,InOut,"utf-8-raw",,true)
                Gui +OwnDialogs
                AppError(Title, Message,0x44,"")
                IfMsgBox Yes, {
                    Run %  "*edit " errorlog
                } Else IfMsgBox No, {
                    return
                }
            }
        }
    } else {
        ttip("No configuration has been selected yet.")
        return
    }
    return
}
openCommandline_EvaluationFolder(Path) {
    global guiObject
    if (!FileExist(Path)) {
        ttip("Critical: configuration path '" Path "' does not exist. Commandline cannot be openend at directory.")
        return
    }
    if (FileExist(guiObject.dynGUI.GFA_Evaluation_Configfile_Location)) {
        Clipboard:="rscript gfa_evaluation.r -i " . """" guiObject.dynGUI.GFA_Evaluation_Configfile_Location """"
        ttip("Configuration Path '" guiObject.dynGUI.GFA_Evaluation_Configfile_Location "' was put onto your clipboard")
    }
    SplitPath % Path, , OutDir
    run cmd /K rscript GFA_Evaluation.R -h,% OutDir
    return
}
compareKeepOld() {
    global RC_Old
    gui compare_contents: Submit
    global compare_returnedContent:=RC_Old.Value
    gui compare_contents: destroy
    return
}
compareUseNew() {
    global RC_New
    gui compare_contents: Submit
    global compare_returnedContent:=RC_New.Value
    gui compare_contents: destroy
    return
}
determineHeuristicScriptRelationByPath(rscript_path,config_path,dynGUI) {
    ;; function _ATTEMPTS_ to heuristically determine if the rscript path selected corresponds to the config file in its folder, by checking if it would find the same config file again.
    ;; it returns true if the functiona determined the two paths to be unrelated, aka they should not be matched against each other.
    SplitPath % rscript_path, , rscript_folder
    SplitPath % config_path, , config_folder
    ;; check if directories are the same
    if !(rscript_folder==config_folder) {       ;; they differ, so we might be dealing with different locations. Next, check if the script's location already contains a config file which contains a few relevant config keys
        ret:=-1     ;; if there is no config file in the rscript-folder, so they might be related.
        Loop, Files, % rscript_folder "\*.ini",R
        {
            IniRead rscript_groups, % A_LoopFileFullPath, % "Experiment", % "UniqueGroups", % "Groups not specified"
            if (isObject(dynGUI.Arguments)) {
                if (dynGUI.Arguments.HasKey("UniqueGroups")) {
                    dynGUIGroups:=dynGUI.Arguments.UniqueGroups.Value
                    if (dynGUIGroups="") {
                        ret:=-4         ;; dynGUI.Arguments.UniqueGroups.Value is empty
                    } else if (rscript_groups=dynGUIGroups) {
                        ret:=true       ;; they match, so we assume they are related, and can go forth. 
                        break
                    } else {
                        ret:=false      ;; they do not match, so we assume they are NOT related
                    }
                } else {
                    ret:=-3             ;; dyngui.Arguments.Uniquegroups is not populated
                }
            } else {
                ret:=-2                 ;; dynGUI.Arguments is not an object - somehow
            }
        }
        return ret
    } else {        ;; they match, so return true
        return true
    }
}
selectConfigLocation(SearchPath) {
    if (!globalLogicSwitches.DEBUG) {
        SearchPath:="C://"
    }
    FileSelectFile Chosen, 3, % SearchPath, % "Please select the ini-file you want to use.", *.R

    SplitPath % Chosen
    if (Chosen!="") {
        Chosen:=Chosen "\GFA_conf_AG.ini"
        guicontrol % "GC:",vUsedConfigLocation, % Chosen
        if (!FileExist(Chosen)) {
            writeFile(Chosen,"",script.config.Configurator_settings.INI_Encoding,,true)
        } else {
            IniRead ExperimentName_Key, % Chosen, Experiment, Name, % "Name not specified"
            SplitPath % Chosen,,,, FileName
            gui listview,% hwndLV_ConfigHistory
            LV_Add("",ExperimentName_Key,FileName,Chosen)
        }
        guiResize(guiObject)
    }
    global GFA_configurationFile:=Chosen
    return Chosen
}
updateLV(hwnd,Object) {
    gui Listview, % hwnd
    static Count:=0, lvttarr:={}
    if (Count<3) {
        Count++
        lvttarr[hwnd]:= DllCall("SendMessage", "ptr", hwnd, "uint", 0x104E, "ptr", 0, "ptr", 0, "ptr")
    }
    global LVTTHWNDARR:=lvttarr
    LV_Delete()
    SetExplorerTheme(hwnd)
    for each, File in Object {
        if (FileExist(File)) {
            SplitPath % File,,,, FileName
            oldFileEnc:=A_FileEncoding
            FileEncoding % script.config.Configurator_settings.INI_Encoding
            IniRead ExperimentName_Key, % File, % "Experiment", % "Name", % "Name not specified"
            FileEncoding % oldFileEnc
            if (InStr(File,".ini")) {
                LV_Add("",ExperimentName_Key,FileName,File)
            } else if (InStr(File,".R")) {
                LV_Add("",FileName,File)
            }
        } else {
            Object.RemoveAt(each,1)
        }
    }
    LV_EX_SetTileViewLines(hwnd, 2, 310)
    LV_EX_SetTileInfo(hwnd, 0, 2,3, 4)
    ; WM_NOTIFY handler
    OnMessage(0x4E, "On_WM_NOTIFY")
    WinSet AlwaysOnTop, On, % "ahk_id " LVTTHWNDARR[hwnd]
    Object:=buildHistory(Object,script.config.Configurator_settings.ConfigHistoryLimit)
    return
}

reload() {
    reload
}

exitApp() {
    ExitApp
}
set_template() {
    template=
        (LTRIM
            get_os <- function() {
            `tsysinf <- Sys.info()
            `tif (!is.null(sysinf)) {
            `t`tos <- sysinf["sysname"]
            `t`tif (os == "Darwin") {
            `t`t`tos <- "osx"
            `t`t}
            `t} else { ## mystery machine
            `t`tos <- .Platform$OS.type
            `t`tif (grepl("^darwin", R.version$os)) {
            `t`t`tos <- "osx"
            `t`t}
            `t`tif (grepl("linux-gnu", R.version$os)) {
            `t`t`tos <- "linux"
            `t`t}
            `t}
            `treturn(tolower(os))
            }
            if (isFALSE(exists("GFA_main", where = -1,mode = "function"))) { # this checks if a function of this name exists in the current scope - in this case, in the entire environment. If it does, there is no point in re-sourcing it again, so we can skip this time-consuming step.
            `tsource("{GFA_EVALUATIONUTILITY}")       
            }
            if (isTRUE(as.logical(get_os() == "windows"))) { # this is an optimistic approach to the problem, I won't try to anticipate all possible OS-names`t# WINDOWS: 
            `tplot_1 <- GFA_main(folder_path = r"({GFA_CONFIGLOCATIONFOLDER_WINDOWS})",returnDays = `%breturnDays`%,saveFigures = `%bsaveFigures`%,saveExcel = `%bsaveExcel`%,saveRDATA = `%bsaveRDATA`%)
            } else {`t# MAC:
            `tplot_1 <- GFA_main(folder_path = r"({GFA_CONFIGLOCATIONFOLDER_MAC})",returnDays = `%breturnDays`%,saveFigures = `%bsaveFigures`%,saveExcel = `%bsaveExcel`%,saveRDATA = `%bsaveRDATA`%)
            }
            ## do not clear your workspace between the calls to ``source()`` and ``GFA_main()``. 
            ## If you absolutely MUST, only clear your worspace after GFA_main() has returned its output and you no longer need its results,
            ## or selectively clear variables. 
            ## 
            ## Clearing the workspace inbetween these two points will render the script useless.
        )
    if FileExist(script.config.Configurator_settings.Custom_R_Script_Template) {
        fo:=fileopen(script.config.Configurator_settings.Custom_R_Script_Template,"r")
        custom_template:=fo.Read()
        fo.Close()
        ret:=custom_template
        for _, key in ["{GFA_EVALUATIONUTILITY}","{GFA_CONFIGLOCATIONFOLDER_WINDOWS}","{GFA_CONFIGLOCATIONFOLDER_MAC}","`%breturnDays`%","`%bsaveFigures`%","`%bsaveRDATA`%"] {
            if !InStr(custom_template,key) {
                OnMessage(0x44, "OnMsgBox_MissingContent")
                answer := AppError("custom template does not contain required contents", "The required element '" key "' does not exist in the template at`n'" script.config.Configurator_settings.Custom_R_Script_Template "'`n`nPlease ensure that the section the original template contains is unchanged in your script. `nThis is necessary to ensure the script's functionality.",0x4," - ")
                OnMessage(0x44, "")
                if (answer = "Yes") {
                    ret:=template
                    break
                }
                exitApp()
            }
        }
    } else {
        ret:=template
    }
    return ret
}
OnMsgBox_MissingContent() {
    DetectHiddenWindows On
    Process Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Use Default
        ControlSetText Button2, Exit Program
    }
}
prepare_release() {
    Run % A_ScriptDir "\Excludes\build.ahk"
    exitApp()
}
#if WinExist("ahk_id " guiObject.dynGUI.GCHWND)
::gfc.s::
guiShow2(guiObject)
return
#if DEBUG ;; hard-coded reload for when running through vsc, not usable in compiled form.
NumpadDot::reload()
#if globalLogicSwitches.bIsDebug
~!Esc:: ;; debug-state-dependent, usable by normal users when compiled
answer := AppError("Do you want to reload without saving?", "You pressed Alt+Escape while in Debug-Mode. Do you want to reload the program without saving any data? `n`nAny currently unsaved changes will not be saved.",0x34," - ")
if (answer = "Yes") {
    Reload()
}
return
#if


/*
script() - class for common script management.
This is based on the example script-class written by RaptorX (https://github.com/RaptorX/ScriptObj),
since that project does not have a license attached to it.
*/
class script_ {
    static DBG_NONE     := 0
        ,  DBG_ERRORS   := 1
        ,  DBG_WARNINGS := 2
        ,  DBG_VERBOSE  := 3

    static name       := ""
        , version      := ""
        , author       := ""
        , authorID	  := ""
        , authorlink   := ""
        , email        := ""
        , credits      := ""
        , creditslink  := ""
        , crtdate      := ""
        , moddate      := ""
        , homepagetext := ""
        , homepagelink := ""
        , ghtext 	  := ""
        , ghlink       := ""
        , doctext	  := ""
        , doclink	  := ""
        , forumtext	  := ""
        , forumlink	  := ""
        , donateLink   := ""
        , resfolder    := ""
        , iconfile     := ""
        , vfile_local  := ""
        , vfile_remote := ""
        , config       := ""
        , configfile   := ""
        , configfolder := ""
        , icon         := ""
        , systemID     := ""
        , dbgFile      := ""
        , rfile		  := ""
        , vfile		  := ""
        , dbgLevel     := script_.DBG_NONE
        , versionScObj := "0.22.4"
        , versionAHK   := "1.1"
    About(bGenerateOnly:=false) {
        /**
        Function: About
        Shows a quick HTML Window based on the object's variable information

        Parameters:
        scriptName   (opt) - Name of the script which will be
        shown as the title of the window and the main header
        version      (opt) - Script Version in SimVer format, a "v"
        will be added automatically to this value
        author       (opt) - Name of the author of the script
        credits 	 (opt) - Name of credited people
        ghlink 		 (opt) - GitHubLink
        ghtext 		 (opt) - GitHubtext
        doclink 	 (opt) - DocumentationLink
        doctext 	 (opt) - Documentationtext
        forumlink    (opt) - forumlink
        forumtext    (opt) - forumtext
        homepagetext (opt) - Display text for the script website
        homepagelink (opt) - Href link to that points to the scripts
        website (for pretty links and utm campaing codes)
        donateLink   (opt) - Link to a donation site
        email        (opt) - Developer email

        Notes:
        - Intended to be used after calling the methods .loadCredits() and .loadMeta()
        - these output a raw file-string to this.credits and this.meta respectively
        but do not format it.
        - Values from this.<Field> take precedence over values created by this.credits
        if they already exist when this method is called.
        The function will try to infer the paramters if they are blank by checking
        the class variables if provided. This allows you to set all information once
        when instatiating the class, and the about GUI will be filled out automatically.

        */
        static doc, 
        /*

        html =
        (
        <!DOCTYPE html>
        <html lang="en" dir="ltr">
        <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <style media="screen">
        .top {
        text-align:center;
        }
        .top h2 {
        color:#2274A5;
        margin-bottom: 5px;
        }
        .donate {
        color:#E83F6F;
        text-align:center;
        font-weight:bold;
        font-size:small;
        margin: 20px;
        }
        p {
        margin: 0px;
        }
        </style>
        </head>
        <body>
        <div class="top">
        <h2>scriptName</h2>
        <p>vversion</p>
        <hr>
        <p>by author</p>

        )
        */
        if !this.HasKey("metadata") {
            scriptName := scriptName ? scriptName : this.name
                , version := version ? version : this.version
                , author := author ? author : this.author
                , credits := credits ? credits : this.credits
                , creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
                , ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
                , ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
                , doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
                , doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
                , offdoclink := offdoclink ? offdoclink : this.offdoclink
                , forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
                , forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
                , homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
                , homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
                , donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
                , email := email ? email : this.email
        }
        MetadataArray:=this.metadataArr
        About_template:=""

        gui aboutScript:new, +HWNDscriptAbout +alwaysontop +toolwindow, % "About " this.name
        gui margin, 2
        gui color, white
        gui add, activex, w600 r29 vdoc, htmlFile
        hasKey:=this.HasKey("AboutPath")
        FE:=FileExist(this.AboutPath)
        if (hasKey && !FE) || !hasKey || bGenerateOnly {

            if (MetadataArray.creditslink and MetadataArray.credits) || IsObject(MetadataArray.credits) || RegexMatch(MetadataArray.credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
            {
                credits:=MetadataArray.credits
                if RegexMatch(credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
                {
                    CreditsLines:=strsplit(credits,"`n")
                    credits:={}
                    for _,v in CreditsLines
                    {
                        if ((InStr(v,"author1") && InStr(v,"snippetName1") && InStr(v,"URL1")) || (InStr(v,"snippetName2|snippetName3")) || (InStr(v,"author2,author3") && Instr(v, "URL2,URL3")))
                            continue
                        val:=strsplit(strreplace(v,"`t"," ")," - ")
                        credits[Trim(val.2)]:=Trim(val.1) "|" Trim((strlen(val.3)>5?val.3:""))
                    }
                }
                ; Clipboard:=html
                newCredits:={}
                if IsObject(credits)
                {
                    if (credits.Count()>0)
                    {
                        CreditsAssembly:="credits for used code:<br>`n"
                        for author,v in credits
                        {
                            if (author="")
                                continue
                            if (strsplit(v,"|").2="") {
                                CreditsAssembly.="<p>" author " - " strsplit(v,"|").1 "`n`n"
                            } else {
                                Name:=strsplit(v,"|").1
                                Credit_URL:=strsplit(v,"|").2
                                if Instr(author,",") && Instr(Trim(Credit_URL),",")
                                {
                                    tmpAuthors:=""
                                    AllCurrentAuthors:=strsplit(author,",")
                                    for s,w in strsplit(Trim(Credit_URL),",")
                                    {
                                        currentAuthor:=AllCurrentAuthors[s]
                                        tmpAuthors.="<a href=" """" w """" ">" trim(currentAuthor) "</a>"
                                        if (s!=AllCurrentAuthors.MaxIndex())
                                            tmpAuthors.=", "
                                    }
                                    ;CreditsAssembly.=Name " - <p>" tmpAuthors "</p>"  "`n" ;; figure out how to force this to be on one line, instead of the mess it is right now.
                                    CreditsAssembly.="<p>" Name " - " tmpAuthors "</p>" "`n" ;; figure out how to force this to be on one line, instead of the mess it is right now.
                                    if (InStr(Credit_URL,"")) {

                                    }
                                    if (AllCurrentAuthors.Count()>1) {
                                        newCredits[AllCurrentAuthors[1]]:={author:Name,URL:Trim(strsplit(Trim(Credit_URL),",").1),License:Trim(strsplit(Trim(Credit_URL),",").2)}
                                    } else {
                                        newCredits[Name]:={author:Name,URL:strsplit(Trim(Credit_URL),",").1,License:strsplit(Trim(Credit_URL),",").2}
                                    }
                                }
                                else {
                                    CreditsAssembly.="<p><a href=" """" Trim(Credit_URL) """" ">" author " - " Name "</a></p>`n"
                                    newCredits[author]:={author:Name,URL:Trim(Credit_URL)}
                                }
                            }
                        }
                        ; Clipboard:=html
                    }
                }
                else
                {
                    CreditsAssembly=
                    (
                                <p>credits: <a href="https://%creditslink%" target="_blank">%credits%</a></p>
                                <hr>
                    )
                }
                MetadataArray.CreditsAssembly:=CreditsAssembly
                ; Clipboard:=html
            }

            if !FileExist(A_ScriptDir "\res\script_templates\_template.html") {
                SplitPath % A_LineFile, , LibPath ;; then in directory of the class `script` itself
                LibPath.="\script_templates\"
                if !FileExist(LibPath "\_template.html") {
                    LibPath .= "\res\script_templates\"

                } else {
                }
            } else {
                LibPath :=A_ScriptDir "\res\script_templates\"
            }
            for metadata_type, metadata_element in MetadataArray {
                if (metadata_element="") {
                    continue
                }
                ;; search for html formatting files,
                ;; first in ScriptDir
                metadata_element:=Trim(metadata_element)
                if (About_template="") {

                    LibPath:=strreplace(LibPath,"\\","\")
                    About_template_path:=LibPath (InStr(LibPath,"\_template.html")?"":"\_template.html")
                    About_template_path:=Strreplace(About_template_path,"\\","\")
                    fo:=fileopen(About_template_path,"r")
                    About_template:=fo.Read()
                    fo.Close()
                }
                ;MetadataArray := {ghLink: "anonymous1184/some-repo", ghText: "Some Repo (from anonymous1184)", donate: "https://example.com"}

                ; Have a full HTML About_template, in it you can have HTML comments
                ;  where other smalls parts will be inserted if the exist.

                ; Say a link-back to GitHub:
                ; metadata_type
                ; metadata_element

                if !FileExist(A_ScriptDir "\res\script_templates\" metadata_type ".html") {
                    SplitPath % A_LineFile, , About_type_path ;; then in directory of the class `script` itself
                    About_type_path.="\script_templates\"

                    if !FileExist(strreplace(About_type_path "\_template.html","\\","\")) {
                        About_type_path .= "\res\script_templates\"

                    } else {
                    }
                } else {
                    About_type_path :=A_ScriptDir "\res\script_templates\" metadata_type ".html"
                }
                About_type_path:=strreplace(About_type_path,"\\","\")

                if FileExist(About_type_path) {

                    fo:=fileopen(About_type_path,"r")
                    html:=fo.Read()
                    fo.Close()
                    About_template := StrReplace(About_template, "<!-- $" metadata_type " -->", html)

                }
            }
            About_template := script_FormatEx(About_template, MetadataArray)
            AHKVARIABLES:={"A_ScriptDir":A_ScriptDir,"A_ScriptName":A_ScriptName,"A_ScriptFullPath":A_ScriptFullPath,"A_ScriptHwnd":A_ScriptHwnd,"A_LineNumber":A_LineNumber,"A_LineFile":A_LineFile,"A_ThisFunc":A_ThisFunc,"A_ThisLabel":A_ThisLabel,"A_AhkVersion":A_AhkVersion,"A_AhkPath":A_AhkPath,"A_IsUnicode":A_IsUnicode,"A_IsCompiled":A_IsCompiled,"A_ExitReason":A_ExitReason,"A_YYYY":A_YYYY,"A_MM":A_MM,"A_DD":A_DD,"A_MMMM":A_MMMM,"A_MMM":A_MMM} ;"A_DDDD","A_DDD","A_WDay","A_YDay","A_YWeek","A_Hour","A_Min","A_Sec","A_MSec","A_Now","A_NowUTC","A_TickCount","A_IsSuspended","A_IsPaused","A_IsCritical","A_BatchLines","A_ListLines","A_TitleMatchMode","A_TitleMatchModeSpeed","A_DetectHiddenWindows","A_DetectHiddenText","A_AutoTrim","A_StringCaseSense","A_FileEncoding","A_FormatInteger","A_FormatFloat","A_SendMode","A_SendLevel","A_StoreCapsLockMode","A_KeyDelay","A_KeyDuration","A_KeyDelayPlay","A_KeyDurationPlay","A_WinDelay","A_ControlDelay","A_MouseDelay","A_MouseDelayPlay","A_DefaultMouseSpeed","A_CoordModeToolTip","A_CoordModePixel","A_CoordModeMouse","A_CoordModeCaret","A_CoordModeMenu","A_RegView","A_IconHidden","A_IconTip","A_IconFile","A_IconNumber","A_TimeIdle","A_TimeIdlePhysical","A_TimeIdleKeyboard","A_TimeIdleMouse","A_DefaultGUI","A_DefaultListView","A_DefaultTreeView","A_Gui","A_GuiControl","A_GuiWidth","A_GuiHeight","A_GuiX","A_GuiY","A_GuiEvent","A_GuiControlEvent","A_EventInfo","A_ThisMenuItem","A_ThisMenu","A_ThisMenuItemPos","A_ThisHotkey","A_PriorHotkey","A_PriorKey","A_TimeSinceThisHotkey","A_TimeSincePriorHotkey","A_EndChar","A_ComSpec","A_Temp","A_OSType","A_OSVersion","A_Is64bitOS","A_PtrSize","A_Language","A_ComputerName","A_UserName","A_WinDir","A_ProgramFiles","A_AppData","A_AppDataCommon","A_Desktop","A_DesktopCommon"]
            About_template := script_FormatEx(About_template,AHKVARIABLES)

            fo:=FileOpen(this.AboutPath, 0x1, "UTF-8-RAW").Write(About_template)
            fo.close()
            FileDelete % this.AboutPath
        } else if (this.HasKey("AboutPath")) {
            fo:=fileopen(this.AboutPath,"r","UTF-8-RAW")
            About_template:=fo.Read()
            fo.Close()
        }

        doc.write(About_template)
        this.creditsArr:=newCredits
        this.metadataArr:=MetadataArray
        if (bGenerateOnly) {
            fo:=FileOpen(this.AboutPath, 0x1, "UTF-8-RAW").Write(About_template)
            fo.close()
            return
        }
        ;clipboard:=About_template
        children := doc.body.children
        maxBottom := 0
        Loop % children.length {
            rect := children[A_Index - 1].getBoundingClientRect()
            (rect.bottom > maxBottom && maxBottom := rect.bottom)
        }

        maxBottom *= 96/A_ScreenDPI
        maxBottom += 15 ; some value you want for the padding-bottom
        maxBottomClose:=maxBottom+9
        maxBottom:=maxBottom+35
        GuiControl Move, doc, h%maxBottom%
        gui add, button, w75 x300 y%maxBottomClose% hidden hwndAboutCloseButton gcloseAboutScript, % "&Close"
        Hotkey IfWinActive, % "ahk_id " scriptAbout
        Hotkey Escape, closeAboutScript
        hotkey if
        gui Show,
        WinGetPos ,,y,w,h, % "Ahk_id" scriptAbout
        ControlGetPos ,,,cw,,, % "Ahk_id" AboutCloseButton
        SysGet sizeframe, 33
        GuiControl move, % AboutCloseButton, % "x" w/2-(cw/2+sizeframe)
        Return

        closeAboutScript:
        gui aboutScript:destroy
        return
    }

    setIcon(Param:=true) {

        /*
        Function: SetIcon
        TO BE DONE: Sets iconfile as tray-icon if applicable

        Parameters:
        Option - Option to execute
        Set 'true' to set this.res "\" this.iconfile as icon
        Set 'false' to hide tray-icon
        Set '-1' to set icon back to ahk's default icon
        Set 'pathToIconFile' to specify an icon from a specific path
        Set 'dll,iconNumber' to use the icon extracted from the given dll - NOT IMPLEMENTED YET.

        Examples:
        script.SetIcon(0) 									;; hides icon
        ttip("custom from script.iconfile",5)
        script.SetIcon(1)										;; custom from script.iconfile
        ttip("reset ahk's default",5)
        script.SetIcon(-1)									;; ahk's default icon
        ttip("set from path",5)
        script.SetIcon(PathToSpecificIcon)					;; sets icon specified by path as icon

        */
        if (!Instr(Param,":/")) { ;; assume not a path because not a valid drive letter
            script_TraySetup(Param)
        }
        else if (Param=true)
        { ;; set script.iconfile as icon, shows icon
            Menu Tray, Icon,% this.resfolder "\" this.iconfile ;; this does not work for unknown reasons
            menu tray, Icon
            ; menu, tray, icon, hide
            ;; menu, taskbar, icon, % this.resfolder "/" this.iconfilea
        }
        else if (Param=false)
        { ;; set icon to default ahk icon, shows icon

            ; ttip("Figure out how to hide autohotkey's icon mid-run")
            menu tray, NoIcon
        }
        else if (Param=-1)
        { ;; hide icon
            Menu Tray, Icon, *

        }
        else ;; Param=path to custom icon, not set up as script.iconfile
        { ;; set "Param" as path to iconfile
            ;; check out GetWindowIcon & SetWindowIcon in AHK_Library
            if !FileExist(Param)
            {
                try
                    throw exception("Invalid Icon-Path '" Param "'. Check the path provided.","script.SetIcon()","T")
                Catch, e
                    msgbox 8240,% this.Name " > scriptObj - Invalid ressource-path", % e.Message "`n`nPlease provide a valid path to an existing file. Resuming normal operation."
            }

            Menu Tray, Icon,% Param
            menu tray, Icon
        }
        return
    }
    loadCredits(Path:="\credits.txt") {
        /*
        Function: readCredits
        helper-function to read a credits-file in supported format into the class

        Parameters:
        Path -  Path to the credits-file.
        If the path begins with "\", it will be relative to the script-directory (aka, it will be processed as %A_ScriptDir%\%Path%)
        */
        if (SubStr(Path,1,1)="\") {
            Path:=A_ScriptDir . Path
        }
        fo:=fileopen(Path,"r")
        text:=fo.Read()
        fo.Close()
        this.credits:=text
    }
    loadMetadata(Path:="\credits.txt") {
        /*
        Function: readCredits
        helper-function to read a credits-file in supported format into the class

        Parameters:
        Path -  Path to the credits-file.
        If the path begins with "\", it will be relative to the script-directory (aka, it will be processed as %A_ScriptDir%\%Path%)
        */
        if (1) {
            if (Path ~= "^\\") {
                Path := A_ScriptDir Path
            }
            fo:=fileopen(Path,"r","utf-8")
            text:=fo.Read()
            fo.Close()
            text := Trim(text, "`r")
            if (InStr(text,"`r`n")) {
                text:=strsplit(text, "`r`n")
            } else if (InStr(text,"`n")) {
                text:=StrSplit(text, "`n")
            }
            meta := {}
            this.metadata:=text
            this.metadataArr := {}
            for _, Line in text {
                parts := StrSplit(Line, " - ", "`t ", 2)
                parts[2] := RegexReplace(parts[2], "i)^https?:\/\/")
                ObjRawSet(meta, parts*)
                ObjRawSet(this.metadataArr, parts*) ; Add the same key/values to the instancec of the class
            }
            this.metadataArr.credits:=this.credits
            this.metadataArr.Scriptname:=regexreplace(A_ScriptName, "\.\w+")
            this.metadataArr.version:=this.version
        } else {
            if (SubStr(Path,1,1)="\") {
                Path:=A_ScriptDir . Path
            }
            fo:=fileopen(Path,"r")
            text:=fo.Read()
            fo.Close()
            this.metadata:=text
            if this.HasKey("metadata") {
                Lines:=strsplit(this.metadata,"`n")
                MetadataArray:={}
                for _, Line in Lines {
                    Key:=Trim(strsplit(Line, " - ",,2).1)
                    Value:=Trim(strsplit(Line," - ",,2).2)
                    if RegexMatch(Value,"http(s)?:\/\/") {
                        Value:=RegexReplace(Value,"http(s)?:\/\/")
                    }
                    MetadataArray[Key]:=RegexReplace(Value,"\r")
                }
                MetadataArray.Scriptname:=(MetadataArray.Scriptname!=""
                    ? MetadataArray.Scriptname :( regexreplace(A_ScriptName, "\.\w+")))
                MetadataArray.version:=(MetadataArray.version!=""
                    ? MetadataArray.version :( this.version))
                MetadataArray.author :=(MetadataArray.author!=""
                    ? MetadataArray.author :this.author)
                MetadataArray.credits :=(MetadataArray.credits!=""
                    ? MetadataArray.credits :this.credits)
                MetadataArray.ghtext :=(MetadataArray.ghtext!=""
                    ? MetadataArray.ghtext :RegExReplace(this.ghtext, "http(s)?:\/\/"))
                MetadataArray.ghlink :=(MetadataArray.ghlink!=""
                    ? MetadataArray.ghlink :RegExReplace(this.ghlink, "http(s)?:\/\/"))
                MetadataArray.doctext :=(MetadataArray.doctext!=""
                    ? MetadataArray.doctext :RegExReplace(this.doctext, "http(s)?:\/\/"))
                MetadataArray.doclink :=(MetadataArray.doclink!=""
                    ? MetadataArray.doclink :RegExReplace(this.doclink, "http(s)?:\/\/"))
                MetadataArray.offdoclink :=(MetadataArray.offdoclink!=""
                    ? MetadataArray.offdoclink :this.offdoclink)
                MetadataArray.forumtext :=(MetadataArray.forumtext!=""
                    ? MetadataArray.forumtext :RegExReplace(this.forumtext, "http(s)?:\/\/"))
                MetadataArray.forumlink :=(MetadataArray.forumlink!=""
                    ? MetadataArray.forumlink :RegExReplace(this.forumlink, "http(s)?:\/\/"))
                MetadataArray.homepagetext :=(MetadataArray.homepagetext!=""
                    ? MetadataArray.homepagetext :RegExReplace(this.homepagetext, "http(s)?:\/\/"))
                MetadataArray.homepagelink :=(MetadataArray.homepagelink!=""
                    ? MetadataArray.homepagelink :RegExReplace(this.homepagelink, "http(s)?:\/\/"))
                MetadataArray.donateLink :=(MetadataArray.donateLink!=""
                    ? MetadataArray.donateLink :RegExReplace(this.donateLink, "http(s)?:\/\/"))
                MetadataArray.email :=(MetadataArray.email!=""
                    ? MetadataArray.email :this.email)
                ;for Key, Value in MetadataArray {
                ;    html:=strreplace(html, Key, Trim(Value))
                ;    Value=%Value%
                ;    %key%:=Value ;; please forgive me, for this is a sin. but need them for testing rn
                ;
                ;}
                Key:=Value:=""
                ;;#todo: mirror the html template below to an external file, and insert a <creditshere>-thingie to ingest the credits-loop content itself.

            } else {
                scriptName := scriptName ? scriptName : this.name
                    , version := version ? version : this.version
                    , author := author ? author : this.author
                    , credits := credits ? credits : this.credits
                    , creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
                    , ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
                    , ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
                    , doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
                    , doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
                    , offdoclink := offdoclink ? offdoclink : this.offdoclink
                    , forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
                    , forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
                    , homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
                    , homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
                    , donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
                    , email := email ? email : this.email
            }
            this.metadataArr:=MetadataArray
        }
    }

    __Init() {

    }
    requiresInternet(URL:="https://autohotkey.com/boards/",Overwrite:=false) { 	;-- Returns true if there is an available internet connection
        if ((this.reqInternet) || Overwrite) {
            return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
        }
        else { ;; we don't care about internet connectivity, so we always return true
            return TRUE

        }
    }
    Load(INI_File:="", bSilentReturn:=0)
    {
        if (INI_File="")
            INI_File:=this.configfile
        Result := []
            , OrigWorkDir:=A_WorkingDir
        if (d_fWriteINI_st_count(INI_File,".ini")>0)
        {
            INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ;; reduce number of ".ini"-patterns to 1
            if (d_fWriteINI_st_count(INI_File,".ini")>0)
                INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ;		 and remove the last instance
        }
        if !FileExist(INI_File ".ini") ;; create new INI_File if not existing
        {
            if !bSilentReturn
                msgbox 8240,% this.Name " > scriptObj -  No Save File found", % "No save file was found.`nPlease reinitialise settings if possible."
            return false
        }
        SplitPath INI_File, INI_File_File, INI_File_Dir
        if !Instr(FileExist(INI_File_Dir),"D:")
            FileCreateDir % INI_File_Dir
        if !FileExist(INI_File_File ".ini") ;; check for ini-file file ending
            FileAppend,, % INI_File ".ini"
        SetWorkingDir INI-Files
        IniRead SectionNames, % INI_File ".ini"
        for _, Section in StrSplit(SectionNames, "`n") {
            IniRead OutputVar_Section, % INI_File ".ini", %Section%
            for __, Haystack in StrSplit(OutputVar_Section, "`n")
            {
                If (Instr(Haystack,"="))
                {
                    RegExMatch(Haystack, "(.*?)=(.*)", $)
                        , Result[Section, $1] := $2
                }
                else
                    Result[Section, Result[Section].MaxIndex()+1]:=Haystack
            }
        }
        if A_WorkingDir!=OrigWorkDir
            SetWorkingDir %OrigWorkDir%
        this.config:=Result
        return (this.config.Count()?true:-1) ; returns true if this.config contains values. returns -1 otherwhise to distinguish between a missing config file and an empty config file
    }
    Save(INI_File:="",Object:="",SeparateWrites:=false)
    {
        if (INI_File="")
            INI_File:=this.configfile
        SplitPath INI_File, INI_File_File, INI_File_Dir
        if (d_fWriteINI_st_count(INI_File,".ini")>0)
        {
            INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
            if (d_fWriteINI_st_count(INI_File,".ini")>0)
                INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance
        }
        if !Instr(FileExist(INI_File_Dir),"D:")
            FileCreateDir % INI_File_Dir
        if !FileExist(INI_File_File ".ini") ; check for ini-file file ending
            FileAppend,, % INI_File ".ini"
        if IsObject(Object) {
            for SectionName, Entry in Object
            {
                Pairs := ""
                for Key, Value in Entry
                {
                    if (!SeparateWrites) {
                        if !Instr(Pairs,Key "=" Value "`n")
                            Pairs .= Key "=" Value "`n"
                    } else {
                        IniWrite % Value, % INI_File ".ini", % SectionName, % Key
                    }
                }
                if (!SeparateWrites) {
                    IniWrite %Pairs%, % INI_File ".ini", %SectionName%
                }
            }
        } else {
            for SectionName, Entry in this.config
            {
                Pairs := ""
                for Key, Value in Entry
                {
                    if (!SeparateWrites) {
                        if !Instr(Pairs,Key "=" Value "`n")
                            Pairs .= Key "=" Value "`n"
                    } else {
                        IniWrite % Value, % INI_File ".ini", % SectionName, % Key
                    }
                }
                if (!SeparateWrites) {
                    IniWrite %Pairs%, % INI_File ".ini", %SectionName%
                }
            }
        }
    }

    Update(vfile:="", rfile:="",bSilentCheck:=false,Backup:=true,DataOnly:=false,CheckOnly:=false)
    {
        dfg:=A_DefaultGui
        ; Error Codes
        static ERR_INVALIDVFILE := 1
            ,ERR_INVALIDRFILE       := 2
            ,ERR_NOCONNECT          := 3
            ,ERR_NORESPONSE         := 4
            ,ERR_INVALIDVER         := 5
            ,ERR_CURRENTVER         := 6
            ,ERR_MSGTIMEOUT         := 7
            ,ERR_USRCANCEL          := 8
        vfile:=(vfile=="")?this.vfile:vfile
            ,rfile:=(rfile=="")?this.rfile:rfile
        if RegexMatch(vfile,"^\d+$") || RegexMatch(rfile,"^\d+$")	 ;; allow skipping of the routine by simply returning here
            return
        ; Error Codes
        if (vfile="") 											;; disregard empty vfiles
            return
        if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
            exception({code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."})
        if  (regexmatch(vfile, "(REPOSITORY_NAME|BRANCH_NAME)"))
            Return												;; let's not throw an error when this happens because fixing it is irrelevant to development in 95% of all cases

        ; This function expects a ZIP file
        if (!regexmatch(rfile, "\.zip"))
            exception({code: ERR_INVALIDRFILE, msg: "Invalid Zip`n`nThe remote file parameter must point to a zip file."})

        ; Check if we are connected to the internet
        try {

            http := comobjcreate("WinHttp.WinHttpRequest.5.1")
                , http.Open("GET", "https://www.google.com", true)
                , http.Send()
        } catch e {
            MsgBox 0x14,% this.name " - No internet connection",% "No internet connection could be established. `n`nAs " this.name " requires an active internet connection`, Do you want to the program to shut down now?"

            IfMsgBox OK, {
                ExitApp
            } Else IfMsgBox Cancel, {
                reload
            }
        }
        try
            http.WaitForResponse(25)
        catch e
        {
            bScriptObj_IsConnected:=this.reqInternet(vfile)
            if !bScriptObj_IsConnected && !this.reqInternet && (this.reqInternet!="") ;; if internet not required - just abort update checl
            { ;; TODO: replace with msgbox-query asking to start script or not - 
                script_ttip(script.name ": No internet connection established - aborting update check. Continuing Script Execution",,,,,,,,18)
                return
            }
            if !bScriptObj_IsConnected && this.reqInternet ;; if internet is required - abort script
            {
                MsgBox 0x11,% this.name " - No internet connection",% "No internet connection could be established. `n`nAs " this.name " requires an active internet connection`, the program will shut down now.`n`n`n`nExiting."

                IfMsgBox OK, {
                    ExitApp
                } Else IfMsgBox Cancel, {
                    reload
                }
            }


        }
        ; throw {code: ERR_NOCONNECT, msg: e.message} ;; TODO: detect if offline
        if (!bSilentCheck)

            Progress 50, 50/100, % "Checking for updates", % "Updating"

        ; Download remote version file
        http.Open("GET", vfile, true)
        http.Send()
        try
            http.WaitForResponse(1)
        catch
        {
            bScriptObj_IsConnected:=this.reqInternet(vfile)
            if !bScriptObj_IsConnected && !this.reqInternet && (this.reqInternet!="") ;; if internet not required - just abort update checl
            { ;; TODO: replace with msgbox-query asking to start script or not - 
                script_ttip(script.name ": No internet connection established - aborting update check. Continuing Script Execution",,,,,,,,18)
                return
            }
            if (!bScriptObj_IsConnected && this.reqInternet) { ;; if internet is required - abort script
                MsgBox 0x14,% this.name " - connection timeout",% "No internet connection could be established. `n`nAs " this.name " requires an active internet connection`, the program will shut down now.`n`n`n`nExiting."

                IfMsgBox OK, {
                    ExitApp
                } Else IfMsgBox Cancel, {
                    return false
                }
            } 
        }

        if !(http.responseText) {

            Progress OFF
            try
                throw exception("There was an error trying to download the ZIP file for the update.`n","script.Update()","The server did not respond.")
            Catch, e 
                msgbox 8240,% this.Name " > Update() - No response from server", % e.Message "`n`nCheck again later`, or contact the author/provider. Script will resume normal operation.", 3.5
            gui %dfg%: Default
            return
        }
        regexmatch(this.version, "\d+\.\d+\.\d+", loVersion)		;; as this.version is not updated automatically, instead read the local version file

        ; FileRead, loVersion,% A_ScriptDir "\version.ini"
        if (InStr(http.responseText,"404")) {

            Progress OFF
            try
                throw exception("The remote file containing the version to compare against could not be found.`n","script.Update()","Server not found.")
            Catch, e 
                msgbox 8240,% this.Name " > Update() - remote not found", % e.Message "`n`nCheck again later`, or contact the author/provider. Script will resume normal operation.",3.5
            gui %dfg%: Default
            return
        }
        regexmatch(http.responseText, "\d+\.\d+\.\d+", remVersion)
        if (!bSilentCheck)
        {

            Progress 100, 100/100, % "Checking for updates", % "Updating"
            sleep 500 	; allow progress to update
        }

        Progress OFF

        ; Make sure SemVer is used
        if (!loVersion || !remVersion)
        {
            try
                throw exception("Invalid version.`n The update-routine of this script works with SemVer.","script.Update()","For more information refer to the documentation in the file`n" )
            catch, e 
                msgbox 8240,% " > scriptObj - Invalid Version", % e.What ":" e.Message "`n`n" e.Extra "'" e.File "'.`n`nlocal version: " loVersion "`nremote version: " remVersion
        }
        ; Compare against current stated version
        ver1 := strsplit(loVersion, ".")
            , ver2 := strsplit(remVersion, ".")
            , bRemoteIsGreater:=[0,0,0]
            , newversion:=false
        for i1,num1 in ver1
        {
            for i2,num2 in ver2
            {
                if (i1 == i2)
                {
                    if (num2 > num1)
                    {
                        bRemoteIsGreater[i1]:=true
                        break
                    }
                    else if (num2 = num1)
                        bRemoteIsGreater[i1]:=false
                    else if (num2 < num1)
                        bRemoteIsGreater[i1]:=-1
                }
            }
        }
        if (!bRemoteIsGreater[1] && !bRemoteIsGreater[2]) ;; denotes in which position (remVersion>loVersion) â†’ 1, (remVersion=loVersion) â†’ 0, (remVersion<loVersion) â†’ -1 
            if (bRemoteIsGreater[3] && bRemoteIsGreater[3]!=-1)
                newversion:=true
        if (bRemoteIsGreater[1] || bRemoteIsGreater[2])
            newversion:=true
        if (bRemoteIsGreater[1]=-1)
            newversion:=false
        if (bRemoteIsGreater[2]=-1) && (bRemoteIsGreater[1]!=1)
            newversion:=false
        if (!newversion)
        {
            if (!bSilentCheck)
                msgbox 8256, No new version available, You are using the latest version.`n`nScript will continue running.,2.5
            return
        }
        else
        {
            ; If new version ask user what to do				"C:\Users\CLAUDI~1\AppData\Local\Temp\AHK_LibraryGUI
            ; Yes/No | Icon Question | System Modal
            msgbox % 0x4 + 0x20 + 0x1000
                , % "New Update Available"
                , % "There is a new update available for this application.`n"
                . "Do you wish to upgrade to v" remVersion "?"
                , 10	; timeout

            ifmsgbox timeout
            {
                try
                    throw exception("The message box timed out.","script.Update()","Script will not be updated.")
                Catch, e
                    msgbox 4144,% this.Name " - " "New Update Available" ,   % e.Message "`nNo user-input received.`n`n" e.Extra "`nResuming normal operation now.`n"
                return
            }
            ifmsgbox no
            {		;; decide if you want to have this or not. 
                ; try
                ; 	throw exception("The user pressed the cancel button.","script.Update()","Script will not be updated.") ;{code: ERR_USRCANCEL, msg: "The user pressed the cancel button."}
                ; catch, e
                ; 	msgbox, 4144,% this.Name " - " "New Update Available" ,   % e.Message "`n`n" e.Extra "`nResuming normal operation now.`n"
                return
            }
            if (CheckOnly) {
                run % "www." script.metadataArr["GH-Tags"]
                Gui +OwnDialogs
                MsgBox 0x40, `% this.name " - New Update Available", Please download the following release from the 'Releases'-section.`n`nThe script will exit. To update`, simply install the new version in the appropriate place.
                ExitApp

            }
            ; Create temporal dirs
            filecreatedir % Update_Temp := a_temp "\" regexreplace(a_scriptname, "\..*$")
            filecreatedir % Update_Temp "\uzip"

            ; ; Create lock file
            ; fileappend % a_now, % lockFile := Update_Temp "\lock"

            ; Download zip file
            urldownloadtofile % rfile, % file:=Update_Temp "\temp.zip"

            ; Extract zip file to temporal folder
            shell := ComObjCreate("Shell.Application")

            ; Make backup of current folder
            if !Instr(FileExist(Backup_Temp:= A_Temp "\Backup " regexreplace(a_scriptname, "\..*$") " - " StrReplace(loVersion,".","_")),"D")
                FileCreateDir % Backup_Temp
            else
            {
                FileDelete % Backup_Temp
                FileCreateDir % Backup_Temp
            }
            MsgBox 0x34, % this.Name " - " "New Update Available", Last Chance to abort Update.`n`n(also remove this once you're done debugging the updater)`nDo you want to continue the Update?
            IfMsgBox Yes 
            {
                CopyFolderAndContainingFiles(A_ScriptDir, Backup_Temp,1) 		;; backup current folder with all containing files to the backup pos. 
                CopyFolderAndContainingFiles(Backup_Temp ,A_ScriptDir,0) 	;; and then copy over the backup into the script folder as well
                items1 := shell.Namespace(file).Items								;; and copy over any files not contained in a subfolder
                for item_ in items1 
                {
                    ;; if DataOnly ;; figure out how to detect and skip files based on directory, so that one can skip updating script and settings and so on, and only query the scripts' data-files 
                    root := item_.Path
                        , items:=shell.Namespace(root).Items
                    for item in items
                        shell.NameSpace(A_ScriptDir).CopyHere(item, 0x14)
                }
                MsgBox 0x40040,,Update Finished
                FileRemoveDir % Backup_Temp,1
                FileRemoveDir % Update_Temp,1
                return true
            }
            Else IfMsgBox No
            {	; no update, cleanup the previously downloaded files from the tmp
                MsgBox 0x40040,,Update Aborted
                FileRemoveDir % Backup_Temp,1
                FileRemoveDir % Update_Temp,1
                return false
            }
            if (err1 || err2)
            {
                ;; todo: catch error
            }
        }

    }

}


CopyFolderAndContainingFiles(SourcePattern, DestinationFolder, DoOverwrite = false) {
    ; Copies all files and folders matching SourcePattern into the folder named DestinationFolder and
    ; returns the number of files/folders that could not be copied.
    ; First copy all the files (but not the folders):
    ; FileCopy, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ; ErrorCount := ErrorLevel
    ; Now copy all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileCopyDir % A_LoopFileFullPath, % DestinationFolder "\" A_LoopFileName , % DoOverwrite
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox % "0x40010",% "Could not copy " A_LoopFileFullPath " into " DestinationFolder "."
    }
    return ErrorCount
}
; --uID:3703205295
script_FormatEx(FormatStr, Values*) {
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
            FormatStr := StrReplace(FormatStr, "{" search "}", "{" ++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}

script_TraySetup(IconString) {
    hICON := script_Base64PNG_to_HICON( IconString ) ; Create a HICON for Tray
    menu tray, nostandard
    if (FileExist(IconString)) {
        Menu tray, icon,% A_ScriptDir "\res\icon.png"
    } else {

        Menu Tray, Icon, HICON:*%hICON% ; AHK makes a copy of HICON when * is used
        Menu Tray, Icon
        DllCall( "DestroyIcon", "Ptr",hICON ) ; Destroy original HICON
    }
    f:=Func("restoredefaultConfig")
    f2:=Func("RunAsAdmin")
    f3:=Func("script_reload")
    f4:=Func("script_exit")
    Menu Tray, Add, Restore default config, % f
    Menu Tray, Add, Restart as Administrator, % f2
    menu tray, Add, Reload, % f3
    menu tray, add, Exit Program, % f4
    return
}
script_reload() {
    reload
}
script_exit() {
    ExitApp
}

; #region:script_Base64PNG_to_HICON (2942823315)
; #region:Metadata:
; Snippet: script_Base64PNG_to_HICON;  (v.1.0)
; --------------------------------------------------------------
; Author: SKAN
; License: Custom public domain/conditionless right of use for any purpose
; LicenseURL: https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/
; Source: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36636
; (03.09.2017)
; --------------------------------------------------------------
; Library: Libs
; Section: 23 - Other
; Dependencies: Windows VISTA and above
; AHK_Version: 1.0
; --------------------------------------------------------------
; Keywords: Icon Base64
; #endregion:Metadata

; #region:Description:
; Parameters Width and Height are optional. Either omit them (to load icon in original dimensions) or specify both of them.
; PNG decompression for Icons was introduced in WIN Vista
; ICONs needn't be SQUARE
; Passing fIcon parameter as false to CreateIconFromResourceEx() function, should create a hCursor (not tested)
; Thanks to @Helgef and @just me me in ask-for-help topic: Anybody using Menu, Tray, Icon, HICON:%hIcon% ?
; Thanks to @jeeswg for providing the formula to calculate Base64 data size.
; Related:
;     Base64 encoder/decoder for Binary data - https://autohotkey.com/boards/viewtopic.php?t=35964
;     Base64ToComByteArray() :: Include image in script and display it with WIA 2.0 - https://autohotkey.com/boards/viewtopic.php?t=36124
;
;
; #endregion:Description

; #region:Example
; #NoEnv
; #SingleInstance, Force
;
; Base64PNG := "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAflBMVEXOgwD///+AUQDz5NSTXQD"
; . "j3NSliWe7dwCnagDGtaPnx6Pbp2eGVQDt1rz6+PXRjSTJgADCewCycQCeZADkwJbhuIf58ur06t/qzrDesHirb"
; . "QDw3ci0nILYn1TVlj+KYSSiZwCYYQCOWgDVyby+q5acfFSTbz/u4dTc08jNv7D3Mcn0AAACq0lEQVR42uzaXW/"
; . "aMBSA4WMn4JAQyAff0A5o123//w/OkSallUblSDm4qO9759zYfo4vI0RERERERERERERERERERERERB97Kva5L"
; . "3lX6deroljKXVoWxcpvWCbv2vkP++JJdFvud8nCfFZSrlQP8bwqE/NZiyTfa82hOJqgNrkotd6YoI6FKFSa4LY"
; . "qM1huTXCljN7aGIX9dSbgW8vYJWZIopAZUgIAAADEBHCuigvwy9VRAawvbQ91NICJP8A8zZoqIkDXPIsG8K+Li"
; . "wngu1ZRAXxtXADbxgawTVwAGx0gBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgI8BDBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAD6AFOFHgrAKgQAAAAAAAAAADwegBuphwX4ln+KAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA1AY5mQAsNgIUZ0O/RAQozoJkGQ"
; . "G4GNB0dQNbhE/hjNQBkF/4CT3Z8AFmutkGbv/y0OgDyvNuYgLavP6wGQGdQ5GVy+xCTyezU3V4LoDNY50lyG3/"
; . "yMpt2t1cB6EunvtOsr1u/2RuJQm9T36zv1S/7m+sD2CGJQva/AQDAnQAudkBzUWhuB3SRsXN2QJkolNkBORm9J"
; . "nwCZ1HpHP4CG1GoOlyDNm9rUao+Bw3heqhEqcplbXr7EGmaNbWoVjdZmt7GT9vMVaKf8zVZn/PVcsdq58v6Ds5"
; . "XCRERERER/W0PDgkAAAAABP1/bfQEAAAAAAAL2VmKC7LwdTIAAAAASUVORK5CYII="
;
; Gui, Add, Picture,, % "HICON:" script_Base64PNG_to_HICON(Base64PNG)
; Gui, Show,, script_Base64PNG_to_HICON() DEMO
; Return
;
; ; Copy and paste script_Base64PNG_to_HICON() below
;
; #endregion:Example

; #region:Code
script_Base64PNG_to_HICON(Base64PNG, W:=0, H:=0) {     ;   By SKAN on D094/D357 @ tiny.cc/t-36636
    Local BLen:=StrLen(Base64PNG), Bin:=0,     nBytes:=Floor(StrLen(RTrim(Base64PNG,"="))*3/4)
    Return DllCall("Crypt32.dll\CryptStringToBinary", "Str",Base64PNG, "UInt",BLen, "UInt",1
        ,"Ptr",&(Bin:=VarSetCapacity(Bin,nBytes)), "UIntP",nBytes, "UInt",0, "UInt",0)
        ? DllCall("CreateIconFromResourceEx", "Ptr",&Bin, "UInt",nBytes, "Int",True, "UInt"
        ,0x30000, "Int",W, "Int",H, "UInt",0, "UPtr") : 0
}

; #endregion:Code

; #region:License
; License could not be copied, please retrieve manually from 'https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/'
;
; #endregion:LicenseWarning: Dependency 'Windows VISTA and above' may not be included. In that case, please search for it separately, or refer to the documentation.

; #endregion:script_Base64PNG_to_HICON (2942823315)

d_fWriteINI_st_removeDuplicates(string, delim="`n")
{ ; remove all but the first instance of 'delim' in 'string'
    ; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
    /*
    RemoveDuplicates
    Remove any and all consecutive lines. A "line" can be determined by
    the delimiter parameter. Not necessarily just a `r or `n. But perhaps
    you want a | as your "line".

    string = The text or symbols you want to search for and remove.
    delim  = The string which defines a "line".

    example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
    output:  aaa|bbb|ccc|ddd
    */
    delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
    Return RegExReplace(string, "(" delim ")+", "$1")
}
d_fWriteINI_st_count(string, searchFor="`n")
{ ; count number of occurences of 'searchFor' in 'string'
    ; copy of the normal function to avoid conflicts.
    ; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
    /*
    Count
    Counts the number of times a tolken exists in the specified string.

    string    = The string which contains the content you want to count.
    searchFor = What you want to search for and count.

    note: If you're counting lines, you may need to add 1 to the results.

    example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
    output:  4
    */
    StringReplace string, string, %searchFor%, %searchFor%, UseErrorLevel
    return ErrorLevel
}


; #region:ttip (2588811139)

; #region:Metadata:
; Snippet: ttip;  (v.0.2.2)
;  13.04.2023
; --------------------------------------------------------------
; Author: Gewerd Strauss
; License: MIT
; --------------------------------------------------------------
; Library: Personal Library
; Section: 20 - ToolTips
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: TOOLTIP
; #endregion:Metadata


; #region:Description:
; small tooltip handler
; 
; /*
; 		
; 		Modes:  
; 	                 -1: do not show ttip - useful when you want to temporarily disable it, without having to remove the call every time, but without having to change text every time.
; 		1: remove tt after "to" milliseconds 
; 		2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat 
; 		3: not sure anymore what the plan was lol - remove 
; 		4: shows tooltip slightly offset from current mouse, does not repeat
; 		5: keep that tt until the function is called again  
; 
; 		CoordMode:
; 		-1: Default: currently set behaviour
; 		1: Screen
; 		2: Window
; 
; 		to: 
; 		Timeout in milliseconds
; 		
; 		xp/yp: 
; 		xPosition and yPosition of tooltip. 
; 		"NaN": offset by +50/+50 relative to mouse
; 		IF mode=4, 
; 		----  Function uses tooltip 20 by default, use parameter
; 		"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
; 		separately from each other, hence a removal of ttip20 will not remove tt14 
; 
; 		---
; 		v.0.2.1
; 		- added Obj2Str-Conversion via "ttip_Obj2Str()"
; 		v.0.1.1 
; 		- Initial build, 	no changelog yet
; 	
; 	*/
; #endregion:Description

; #region:Code
script_ttip(text:="TTIP: Test",mode:=1,to_script:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2_script:=1750,Times_script:=20,currTip:=20)
{

    cCoordModeTT:=A_CoordModeToolTip
    if (mode=-1)
        return
    if (text="") || (text=-1)
        gosub, llTTIP_RemoveTTIP_script
    if IsObject(text)
        text:=ScriptObj_Obj2Str(text)
    static ttip_text
    static currTip2
    global ttOnOff_script
    currTip2:=currTip
    cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
    CoordMode % cMode
    tooltip


    ttip_text:=text
    lUnevenTimers:=false 
    MouseGetPos xp1,yp1
    if (mode=4) ; set text offset from cursor
    {
        yp:=yp1+15
        xp:=xp1
    }	
    else
    {
        if (xp="NaN")
            xp:=xp1 + 50
        if (yp="NaN")
            yp:=yp1 + 50
    }
    tooltip % ttip_text,xp,yp,% currTip
    if (mode=1) ; remove after given time
    {
        SetTimer llTTIP_RemoveTTIP_script, % "-" to_script
    }
    else if (mode=2) ; remove, but repeatedly show every "to_script"
    {
        ; gosub,  A
        global to_1_script:=to_script
        global to2_1_script:=to2_script
        global tTimes_script:=Times_script
        Settimer lTTIP_SwitchOnOff_script,-100
    }
    else if (mode=3)
    {
        lUnevenTimers:=true
        SetTimer llTTIP_RepeatedShow_script, %  to_script
    }
    else if (mode=5) ; keep until function called again
    {

    }
    CoordMode % cCoordModeTT
    return text
    lTTIP_SwitchOnOff_script:
    ttOnOff_script++
    if mod(ttOnOff_script,2)	
    {
        gosub, llTTIP_RemoveTTIP_script
        sleep % to_1_script
    }
    else
    {
        tooltip % ttip_text,xp,yp,% currTip
        sleep % to2_1_script
    }
    if (ttOnOff_script>=tTimes_script)
    {
        Settimer lTTIP_SwitchOnOff_script, off
        gosub, llTTIP_RemoveTTIP_script
        return
    }
    Settimer lTTIP_SwitchOnOff_script, -100
    return

    llTTIP_RepeatedShow_script:
    ToolTip % ttip_text,,, % currTip2
    if lUnevenTimers
        sleep % to2_script
    Else
        sleep % to_script
    return
    llTTIP_RemoveTTIP_script:
    ToolTip,,,,currTip2
    return
}

ScriptObj_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
    static String,Blank
    if(FullPath=1)
    String:=FullPath:=Blank:=""
    if(IsObject(Obj)){
        for a,b in Obj{
            if(IsObject(b))
            ScriptObj_Obj2Str(b,FullPath "." a,BottomBlank)
            else{
                if(BottomBlank=0)
                String.=FullPath "." a " = " b "`n"
                else if(b!="")
                    String.=FullPath "." a " = " b "`n"
                else
                    Blank.=FullPath "." a " =`n"
            }
        }}
    return String Blank
}
; #endregion:Code



; #endregion:ttip (2588811139)
; #region:Base64PNG_to_HICON (2942823315)

; #region:Metadata:
; Snippet: Base64PNG_to_HICON;  (v.1.0)
; --------------------------------------------------------------
; Author: SKAN
; License: Custom public domain/conditionless right of use for any purpose
; LicenseURL: https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/
; Source: https://www.autohotkey.com/boards/viewtopic.php?f=6&t=36636
; (03.09.2017)
; --------------------------------------------------------------
; Library: Libs
; Section: 23 - Other
; Dependencies: Windows VISTA and above
; AHK_Version: 1.0
; --------------------------------------------------------------
; Keywords: Icon Base64
; #endregion:Metadata


; #region:Description:
; Parameters Width and Height are optional. Either omit them (to load icon in original dimensions) or specify both of them.
; PNG decompression for Icons was introduced in WIN Vista
; ICONs needn't be SQUARE
; Passing fIcon parameter as false to CreateIconFromResourceEx() function, should create a hCursor (not tested)
; Thanks to @Helgef and @just me me in ask-for-help topic: Anybody using Menu, Tray, Icon, HICON:%hIcon% ?
; Thanks to @jeeswg for providing the formula to calculate Base64 data size.
; Related:
;     Base64 encoder/decoder for Binary data - https://autohotkey.com/boards/viewtopic.php?t=35964
;     Base64ToComByteArray() :: Include image in script and display it with WIA 2.0 - https://autohotkey.com/boards/viewtopic.php?t=36124
;
;
; #endregion:Description

; #region:Example
; #NoEnv
; #SingleInstance, Force
;
; Base64PNG := "iVBORw0KGgoAAAANSUhEUgAAAQAAAAEACAMAAABrrFhUAAAAflBMVEXOgwD///+AUQDz5NSTXQD"
; . "j3NSliWe7dwCnagDGtaPnx6Pbp2eGVQDt1rz6+PXRjSTJgADCewCycQCeZADkwJbhuIf58ur06t/qzrDesHirb"
; . "QDw3ci0nILYn1TVlj+KYSSiZwCYYQCOWgDVyby+q5acfFSTbz/u4dTc08jNv7D3Mcn0AAACq0lEQVR42uzaXW/"
; . "aMBSA4WMn4JAQyAff0A5o123//w/OkSallUblSDm4qO9759zYfo4vI0RERERERERERERERERERERERB97Kva5L"
; . "3lX6deroljKXVoWxcpvWCbv2vkP++JJdFvud8nCfFZSrlQP8bwqE/NZiyTfa82hOJqgNrkotd6YoI6FKFSa4LY"
; . "qM1huTXCljN7aGIX9dSbgW8vYJWZIopAZUgIAAADEBHCuigvwy9VRAawvbQ91NICJP8A8zZoqIkDXPIsG8K+Li"
; . "wngu1ZRAXxtXADbxgawTVwAGx0gBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADgI8BDBQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAD6AFOFHgrAKgQAAAAAAAAAADwegBuphwX4ln+KAgAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
; . "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAPA1AY5mQAsNgIUZ0O/RAQozoJkGQ"
; . "G4GNB0dQNbhE/hjNQBkF/4CT3Z8AFmutkGbv/y0OgDyvNuYgLavP6wGQGdQ5GVy+xCTyezU3V4LoDNY50lyG3/"
; . "yMpt2t1cB6EunvtOsr1u/2RuJQm9T36zv1S/7m+sD2CGJQva/AQDAnQAudkBzUWhuB3SRsXN2QJkolNkBORm9J"
; . "nwCZ1HpHP4CG1GoOlyDNm9rUao+Bw3heqhEqcplbXr7EGmaNbWoVjdZmt7GT9vMVaKf8zVZn/PVcsdq58v6Ds5"
; . "XCRERERER/W0PDgkAAAAABP1/bfQEAAAAAAAL2VmKC7LwdTIAAAAASUVORK5CYII="
;
; Gui, Add, Picture,, % "HICON:" Base64PNG_to_HICON(Base64PNG)
; Gui, Show,, Base64PNG_to_HICON() DEMO
; Return
;
; ; Copy and paste Base64PNG_to_HICON() below
;
; #endregion:Example


; #region:Code
Base64PNG_to_HICON(Base64PNG, W := 0, H := 0) {     ;   By SKAN on D094/D357 @ tiny.cc/t-36636
  Local BLen := StrLen(Base64PNG), Bin := 0, nBytes := Floor(StrLen(RTrim(Base64PNG, "=")) * 3 / 4)
  Return DllCall("Crypt32.dll\CryptStringToBinary", "Str", Base64PNG, "UInt", BLen, "UInt", 1
    , "Ptr", &(Bin := VarSetCapacity(Bin, nBytes)), "UIntP", nBytes, "UInt", 0, "UInt", 0)
    ? DllCall("CreateIconFromResourceEx", "Ptr", &Bin, "UInt", nBytes, "Int", True, "UInt"
      , 0x30000, "Int", W, "Int", H, "UInt", 0, "UPtr") : 0
}

; #endregion:Code


; #region:License
; License could not be copied, please retrieve manually from 'https://www.autohotkey.com/board/topic/75906-about-my-scripts-and-snippets/'
;
; #endregion:LicenseWarning: Dependency 'Windows VISTA and above' may not be included. In that case, please search for it separately, or refer to the documentation.


; #endregion:Base64PNG_to_HICON (2942823315)
Class dynamicGUI {
    __New(Format:="",ConfigFile:="",DDL_ParamDelimiter:="-<>-",SkipGUI:=FALSE) {
        this.type:=Format
            , this.ClassName.= Format ")"
            , this.DDL_ParamDelimiter:=DDL_ParamDelimiter
            , this.SkipGUI:=SkipGUI
            , this.StepsizedGuiShow:=FALSE
        if FileExist(ConfigFile) {
            this.ConfigFile:=ConfigFile
        } else {
            ID:=-1
            this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'") "'" ConfigFile "'" (this.Errors[ID].HasKey("EndString")?this.Errors[ID].EndString:"Fatal: Undefined Error with ID '" ID "'")
            ExitApp
            return
        }
        fo:=fileOpen(ConfigFile,"r")
        Text:=fo.read()
        fo.Close()
        Text:=strreplace(Text,"`n","`r`n")
            , Lines:=strsplit(Text,Format "`r`n").2
            , Lines:=strsplit(Lines,"`r`n`r`n").1
            , Lines:=strsplit(Lines,"`r`n")
        if !Lines.Count() {
            this.Result:=this.type:=Format "()"
                , ID:=+2
                , this.Error:=this.Errors[ID] ;.String
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        for _, Line in Lines {
            Count:=1
                , p := 1
                , regex:="(?<Key>\w+\:)(?<Val>[^|]+)" ;; does not support keys a la 'toc-depth' (as required by quarto)
                , regex:="(?<Key>(\-|\w)+\:)(?<Val>[^|]+)"
            if (SubStr(Trim(Line),1,1)=";") {
                continue
            }
            if (RegexMatch(Line,"^\s+\S+")) {
                while (p := RegExMatch(Line, regex, match, p)) {
                    ; do stuff
                    if !InStr(Line,"|") { ;; not a Parameter being defined. This occurs on lines like `bookdown::word_document2` which should define a new output format instead
                        p+=StrLen(Match)
                    } else {
                        matchKey:=SubStr(matchKey,1,StrLen(matchKey)-1) ;; remove the doublepoint.
                        if (Count<2) { ;; initiate Parameter-Object
                            if (InStr(Line,"renderingpackage")) {
                                This[matchKey]:=StrSplit(Line,"Value:").2
                                    , p+=StrLen(Match)
                                    , Count++
                                continue
                            } else {
                                CurrentParam:=matchKey
                                    , ObjRawSet(This.Arguments,matchKey,{})
                                    , ObjRawSet(This.Arguments[CurrentParam],"Control",matchVal)
                            }
                        }
                        if !(InStr(Line,"renderingpackage")) {
                            ObjRawSet(This.Arguments[CurrentParam],matchKey,matchVal) ;; there ought to be a simpler method than ObjRawSet that I am utterly missing, or tested with bad data and assumed faulty...
                        }
                        p+=StrLen(Match)
                            , Count++
                    }
                }
            } else { ;; we reached the first line of the next output format, indicated by its `package::format`-line
                break
            }
        }
        this.AssumeDefaults()
            , this._Adjust()
    }
    ;@ahk-neko-ignore 1 line; Method too big.
    __Init() {
        this.Errors:={ ;; negative errors are hard failures, which will not let the program continue. positive errors are positive, and allow limited continuation. Functionality may be limited
                -1:{String:"Provided Configfile does not exist:`n`n",EndString:"`n`n---`nExiting Script",Criticality:-100,ID:-1}
                ,0:{String:"Gui got cancelled",EndString:"`n`n---`nReturning to General Selection",Criticality:0,ID:0}
                ,+2:{String:"Format not defined.`nCheck your configfile.`n`nReturning default 'outputformat()'",Criticality:20,ID:+2}}
            , this.ClassName:="ot ("
            , this.GUITitle:="Define output format - "
            , this.Version:="0.1.a"
            , this.type:=""
            , this.ConfigFile:=""
            , this.bClosedNoSubmit:=false
            , ObjRawSet(this,"type","")
            , ObjRawSet(this,"Arguments",{})
    }
    __Get(Param*) {
        ret:={}
        for _,key in Param {
            ret[key]:=this.Arguments[key].Value
        }
        return ret
    }
    _Adjust() {
        This.AdjustMinMax()
            , This.AdjustDDLs()
            , This.AdjustBools()
            , This.AdjustIntegers()
            , This.AdjustNulls()
        return This
    }
    AssembleFormatString() {
        if this.HasKey("renderingpackage_start") {
            if !this.HasKey("renderingpackage_end") {
                MsgBox 0x40031, % "output_type: " this.type " - faulty meta parameter", % "The meta parameter`n'renderingpackage_end'`ndoes not exist. Exiting. Please refer to documentation and fix the file 'DynamicArguments.ini'."
            }
            Str:=this.renderingpackage_start
        } else {

            if InStr(this.type,"::") { ;; start string
                Str:=this.type "(`n" ;; check if format is from a specific package or not
            } else {
                Str:="rmarkdown::" this.type "(`n"  ;; assume rmarkdown-package if not the case
            }
        }
        this._Adjust()
        for Parameter, Value in this.Arguments {
            if Value.Control="meta" {
                continue
            }
            if Value.Value="" && Value.Default="" {
                continue
            }
            if InStr(Parameter,"___") {
                Parameter:="'" StrReplace(Parameter,"___", "-") "'"
            } else if InStr(Parameter,"-") {
                Parameter:="'" Parameter "'"
            }
            if (Parameter="toc_depth" && !this.Arguments["toc"].Value) {
                continue
            }
            if (Value.Type="String") && (Value.Value!="") && (Value.Default!="NULL") {
                Value.Value:=DA_Quote(Value.Value)
            }
            if (InStr(Parameter,"reference_docx") || InStr(Parameter,"reference-doc"))  {
                ParamBackup:=Value.Value
                if Instr(Value.Value,this.DDL_ParamDelimiter) {
                    ParamString:=strsplit(Value.Value,this.DDL_ParamDelimiter).2
                } else {
                    ParamString:=Value.Value
                }
                if Instr(ParamString,"(") {
                    ParamString:=strsplit(ParamString,"(").2
                        , ParamString:=Trim(ParamString,"""")
                    if SubStr(ParamString,0)=")" {
                        tpl_Len:=StrLen(ParamString)-1
                            , ParamString:=SubStr(ParamString, 1, tpl_Len)
                    }
                }
                ParamString:=StrReplace(ParamString, "\", "/")
                    , Value.Value:=DA_Quote(ParamString)
                if (ParamString="") {
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
                }
                if Instr(ParamBackup,this.DDL_ParamDelimiter) {
                    ParamBackup:=Trim(StrSplit(ParamBackup, this.DDL_ParamDelimiter).2)
                }
                if !FileExist(Value.Value) && !FileExist(strreplace(ParamBackup,"\","/")) {
                    Value.Value:=DA_Quote(strreplace(Trim(ParamBackup,""""),"\","/"))
                }
                if !FileExist(Trim(Value.Value,"""")) && !FileExist(strreplace(ParamBackup,"\","/")) {
                    MsgBox 0x40031, % "output_type: " this.type " - faulty reference_docx", % "The given path to the reference docx-file`n'" Value.Value "'`ndoes not exist. Returning."
                    return
                }

            }
            Str.= Parameter " = " Value.Value ",`n"
        }
        for Parameter, Value in this.Arguments {
            if Value.Control="meta" {
                this.Arguments.Remove(Parameter)
                continue
            }
        }
        Str:=SubStr(Str,1,StrLen(Str)-2)
        Str.=(Instr(Str,"`n")?"`n)":"")
        if InStr(Str,this.renderingpackage_start) {
            if this.HasKey("renderingpackage_end") {

                Str:=strreplace(Str,"`n)",this.renderingpackage_end)
            }
        }
        this.AssembledFormatString:=Str
        return
    }

    AdjustDDLs() {
        for Parameter,Value in this.Arguments {
            if (Value.Control!="DDL") && (Value.Control!="DropDownList") {
                continue
            }
        }
    }
    AdjustBools() {
        for Parameter, Value in this.Arguments {
            if (Value.Type="Integer" || Value.Type="Number" || Value.Type="Boolean") {
                Value.Value:=Value.Value+0
            }
            if (Value.Type="boolean") {
                Value.Value:=(Value.Value?"TRUE":"FALSE")
            }
        }
    }
    AdjustIntegers() {
        for Parameter, Value in this.Arguments {
            if (Value.Type="Integer") {
                Value.Value:=Floor(Value.Value)
            }
        }
    }
    AdjustMinMax() {
        for Parameter, Value in this.Arguments {
            if RegexMatch(Value.Other,"gmi)Max\:(?<Max>\d*)",v_) {
                Value.Max:=v_Max+0
            }
            if RegexMatch(Value.Other,"gmi)Min\:(?<Min>\d*)",v_) {
                Value.Min:=v_Min+0
            }
            if Value.HasKey("Max") && Value.Value>Value.Max {
                Value.Value:=Value.Max+0
            }
            if Value.HasKey("Min") && Value.Min>Value.Value {
                Value.Value:=Value.Min+0
            }
            if (Value.HasKey("Max") && Value.HasKey("Max")) {
                if !((Value.Value<=Value.Max) && (Value.Min<=Value.Value)) {
                    Value.Value:=Value.Default
                }
            }
        }
    }
    AdjustNulls() {
        for Parameter, Value in this.Arguments {
            if Value.Value="NULL" {
                Value.Value:=strreplace(Value.Value,"""")
            }
        }
    }
    AssumeDefaults() {
        for _, Value in this.Arguments {
            if Value.HasKey("SearchPath") {
                Value.SearchPath:=strreplace(Value.SearchPath,"""","")
            }
            Value.String:=strreplace(Value.String,"""","")
            if (Value.Type="String") {
                Value.Default:=strreplace(Value.Default,"""","")
            }
            if (Value.Value="") {
                if (Value.Control="File") {
                    if !FileExist(Value.SearchPath Value.Default) {
                        MsgBox 0x40031, % "output_type: " this.type, % "The default File`n'" Value.SearchPath Value.Default "'`ndoes not exist. No default set."
                    } else {
                        Value.Value:=Value.SearchPath Value.Default
                    }
                } else {
                    Value.Value:=Value.Default
                }
            }
        }
    }

    ChooseFile(VarName) {
        VarName:=strreplace(VarName,"___","-")
        FileSelectFile Chosen, 3,% this.Arguments[VarName].SearchPath,% this.Arguments[VarName].String
        this.Arguments[VarName].Value:=Chosen
            , GUI_ID:=this.GUI_ID
        gui %GUI_ID% default
        SplitPath % Chosen,,,,ChosenName
        if (Chosen!="") {

            guicontrol %GUI_ID%,v%VarName%, % ChosenName A_Space this.DDL_ParamDelimiter A_Space Chosen
        }
    }

    OpenFileSelectionFolder(Path) {
        SplitPath % Path,, OutDir
        run % OutDir
    }

    GenerateGUI(x:="",y:="",AttachBottom:=true,GUI_ID:="ParamsGUI:",destroyGUI:=true,Tab3Width:=674,ShowGui:=false,fontsize:=8) {
        global ;; this cannot be made static or this.SubmitDynamicArguments() will not receive modified values (aka it will always assemble the default)
        if (destroyGUI) {
            gui %GUI_ID% destroy
        }
        this.GUI_ID:=GUI_ID
        if this.HasKey("Error") {
            ID:=strsplit(this.Error,A_Space).2
            if !(SubStr(ID,1,1)="-") {
                return this
            }
            MsgBox 0x40031,% this.ClassName " > " A_ThisFunc "()" ,% (this.Errors.HasKey(ID)?this.Errors[ID].String:"Fatal: Undefined Error with ID '" ID "'")
            return this
        }
        if (destroyGUI) {
            gui %GUI_ID% new, +AlwaysOnTop -SysMenu -ToolWindow +caption +Border +LabelotGUI_ +hwndotGUI_
        }
        gui font, % "s" fontsize
        TabHeaders:={}
        for Parameter, Value in this.Arguments {
            if Value.HasKey("Tab3Parent") {
                TabHeaders[Value.Tab3Parent]:={Height:0}
            } else {
                this.Arguments[Parameter,"Tab3Parent"]:="Other"
                TabHeaders[Value.Tab3Parent]:={Height:0}
            }
        }
        Tab3String:=""
            , ind:=0
            , HiddenHeaders:={}
        for Header,_  in TabHeaders {
            HeaderFound:=false
            for Parameter, Value in this.Arguments {
                if (Value.Tab3Parent=Header) {
                    if Value.Control!="meta" {
                        HeaderFound:=true
                            , HiddenHeaders[Header]:=false
                        break
                    } else {
                        HiddenHeaders[Header]:=true
                    }
                }
            }
            if (HeaderFound) {

                Tab3String.=Header
                    , ind++
                if (ind<TabHeaders.Count()) || (ind=1) {
                    Tab3String.="|"
                }
            }
        }
        gui %GUI_ID% add, Tab3,% "vvTab3 hwndhwndDA" " h900 w" Tab3Width, % Tab3String
        if (this.StepsizedGuishow) {
            gui %GUI_ID% show
        }
        for Tab, _ in TabHeaders {
            if HiddenHeaders[Tab] {
                continue
            }
            if (this.StepsizedGuishow) {
                gui %GUI_ID% show
            }
            TabHeight:=0
            gui %GUI_ID% Tab, % Tab,, Exact
            GuiControl Choose, vTab3, % Tab
            for Parameter, Value in this.Arguments {
                if Value.Control="meta" {
                    this[Parameter]:=Value.Value
                    continue
                }
                if InStr(Parameter,"-") {
                    Parameter:=strreplace(Parameter,"-","___") ;; fix "toc-depth"-like formatted parameters for quarto syntax when displaying. Three underscores are used to differentiate it from valid syntax for other packages.
                }
                if InStr(Parameter,"pandoc") {

                }
                if (Value.HasKey("Link")) {
                    Value.Link:=DA_FormatEx(Value.Link,script.metadataArr)
                    Value.Link:=DA_FormatEx(Value.Link,{"Parameter":regexreplace(Parameter,".*","$L0")})
                }
                if (!RegexMatch(Value.String,"^" strreplace(Parameter,"___","-"))) && (Value.Control!="Text") {
                    Value.String:= "" strreplace(Parameter,"___","-") "" ":" A_Space Value.String
                }
                ControlHeight:=0
                if (Tab=Value.Tab3Parent) {
                    Control:=Value.Control
                    if (Value.Control="Edit") {
                        GuiControl Choose, vTab3, % Tab
                        if Value.HasKey("Link") {
                            gui %GUI_ID% add, Link,% "h20 hwndDALink" Parameter, % "<a href=""" Value.Link """>?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,% "h20  hwndDALink" Parameter, % Value.String
                        }
                        ControlHeight+=20
                        if (Value.ctrlOptions="Number") {
                            if (Value.Max!="") && (Value.Min!="") {
                                Value.ctrlOptions.= A_Space
                                gui %GUI_ID% add, Edit,
                                gui %GUI_ID% add, UpDown, % "h20 w80 Range" Value.Min "-" Value.Max " vv" Parameter " hwndDA" Parameter, % Value.Default + 0
                                ControlHeight+=20
                                GuiControl %GUI_ID% Move, vTab3, % "h" TabHeight + ControlHeight + 16
                                TabHeight+=ControlHeight
                                GuiControl %GUI_ID% Move, vTab3, % "h" TabHeight + 16
                                if (this.StepsizedGuishow) {
                                    gui %GUI_ID% show
                                }
                                if Value.HasKey("TTIP") {
                                    if AddToolTip(Deref("%DA" Parameter "%"), strreplace(Value.TTIP,"\n","`n"),,hwndDA) {

                                    }
                                    if AddToolTip(Deref("%DALink" Parameter "%"), strreplace(Value.TTIP,"\n","`n"),,hwndDA) {

                                    }
                                }
                                continue
                            }
                        }
                        if !RegexMatch(Value.ctrlOptions,"w\d*") {
                            Value.ctrlOptions.= " w200"
                        }
                        if RegexMatch(Value.ctrlOptions,"h(?<vH>\d*)",v) {
                            ControlHeight+=vvH + 15
                        } else if !RegexMatch(Value.ctrlOptions,"h(?<vH>\d*)",v) {
                            Value.ctrlOptions.= " h35"
                            ControlHeight+=35
                        }
                        gui %GUI_ID% add, % "edit", % Value.ctrlOptions " vv" Parameter " hwndDA" Parameter, % (Value.Value="NULL"?:Value.Value)
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight + 32
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                        ;GuiControl Move, vTab3, % "h" TabHeight
                    } else if (Value.Control="File") {
                        if Value.HasKey("Link") {
                            gui %GUI_ID% add, Link,% "h20 hwndDALink" Parameter, % "<a href=""" Value.Link """>?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,% TabHeight+20 " hwndDALink" Parameter, % Value.String
                        }
                        ControlHeight+=20
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui %GUI_ID% add, edit, % Value.ctrlOptions " vv" Parameter " hwndDA" Parameter " disabled w200 yp+30 h60", % Value.Value
                        ControlHeight+=90
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui %GUI_ID% add, button, yp+70 hwndSelectFile, % "Select &File"
                        ControlHeight+=30
                        ;GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        gui %GUI_ID% add, button, yp xp+77 hwndOpenFileSelectionFolder, % "Open File Selection Folder"
                        onOpenFileSelectionFolder:=ObjBindMethod(this, "OpenFileSelectionFolder", Value.SearchPath)
                            , onSelectFile := ObjBindMethod(this, "ChooseFile",Parameter)
                        GuiControl %GUI_ID% +g, %SelectFile%, % onSelectFile
                        GuiControl %GUI_ID% +g, %OpenFileSelectionFolder%, % onOpenFileSelectionFolder
                        gui %GUI_ID% add,text, w0 h0 yp+20 xp-77
                        ControlHeight+=20
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                    } else if (Value.Control="DDL") || (Value.Control="ComboBox") {
                        if Value.HasKey("Link") {
                            gui %GUI_ID% add, Link,% "h20 hwndDALink" Parameter, % "<a href=""" Value.Link """>?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,% "h20 hwndDALink" Parameter, % Value.String
                        }
                        if (RegexMatch(Value.ctrlOptions,"^r(?<Rows>\d+)\,.+$",v)) {
                            Value.ctrlOptions2:=vRows
                            Value.ctrlOptions:=RegExReplace(Value.ctrlOptions, "r\d+\,")
                        } else {
                            Value.ctrlOptions2:=0
                        }
                        if Instr(Value.ctrlOptions,",") && !Instr(Value.ctrlOptions,"|") {
                            Value.ctrlOptions:=strreplace(Value.ctrlOptions,",","|")
                        }
                        if !Instr(Value.ctrlOptions,Value.Default) {
                            Value.ctrlOptions.=((SubStr(Value.ctrlOptions,-1)="|")?"":"|") Value.Default
                        }
                        if !Instr(Value.ctrlOptions,Value.Default "|") {
                            Value.ctrlOptions:=RegexReplace(Value.ctrlOptions,Value.Default "\b",Value.Default "|")
                        }
                        if !Instr(Value.ctrlOptions,Value.Default "||") {
                            Value.ctrlOptions:=Regexreplace(Value.ctrlOptions,Value.Default "\b",Value.Default "|")
                        }
                        if !Instr(Value.ctrlOptions,Value.Default "||") {
                            Value.ctrlOptions:=strreplace(Value.ctrlOptions,Value.ctrlOptions "|")
                        }
                        Threshold:=(Value.ctrlOptions2>0?Value.ctrlOptions2:5)
                            , tmpctrlOptions:=LTrim(RTrim(strreplace(Value.ctrlOptions,"||","|"),"|"),"|")
                            , tmpctrlOptions_arr:=strsplit(tmpctrlOptions,"|")
                            , Count:=tmpctrlOptions_arr.Count()
                            , shown_rows:=(Count<=1?1:(Count>Threshold?Threshold:Count))
                        gui %GUI_ID% add, % Value.Control, % "  vv" Parameter " hwndDA" Parameter " r" shown_rows , % Value.ctrlOptions
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                        ControlHeight+=75
                    } else if (Value.Control="DateTime"){
                        if Value.HasKey("Link") {
                            gui %GUI_ID% add, Link,% "h20 hwndDALink" Parameter, % "<a href=""" Value.Link """>?</a>" A_Space Value.String
                        } else {
                            gui %GUI_ID%  add, text,% "h20 hwndDALink" Parameter, % Value.String
                        }
                        AHKVARIABLES := { "A_ScriptDir": A_ScriptDir, "A_ScriptName": A_ScriptName, "A_ScriptFullPath": A_ScriptFullPath, "A_ScriptHwnd": A_ScriptHwnd, "A_LineNumber": A_LineNumber, "A_LineFile": A_LineFile, "A_ThisFunc": A_ThisFunc, "A_ThisLabel": A_ThisLabel, "A_AhkVersion": A_AhkVersion, "A_AhkPath": A_AhkPath, "A_IsUnicode": A_IsUnicode, "A_IsCompiled": A_IsCompiled, "A_ExitReason": A_ExitReason, "A_YYYY": A_YYYY, "A_MM": A_MM, "A_DD": A_DD, "A_MMMM": A_MMMM, "A_MMM": A_MMM, "A_DDDD":A_DDDD,"A_DDD":A_DDD,"A_WDay":A_WDay,"A_YDay":A_YDay,"A_YWeek":A_YWeek,"A_Hour":A_Hour,"A_Min":A_Min,"A_Sec":A_Sec,"A_MSec":A_MSec,"A_Now":A_Now,"A_NowUTC":A_NowUTC,"A_TickCount":A_TickCount,"A_IsSuspended":A_IsSuspended,"A_IsPaused":A_IsPaused,"A_IsCritical":A_IsCritical,"A_BatchLines":A_BatchLines,"A_ListLines":A_ListLines,"A_TitleMatchMode":A_TitleMatchMode,"A_TitleMatchModeSpeed":A_TitleMatchModeSpeed,"A_DetectHiddenWindows":A_DetectHiddenWindows,"A_DetectHiddenText":A_DetectHiddenText,"A_AutoTrim":A_AutoTrim,"A_StringCaseSense":A_StringCaseSense,"A_FileEncoding":A_FileEncoding,"A_FormatInteger":A_FormatInteger,"A_FormatFloat":A_FormatFloat,"A_SendMode":A_SendMode,"A_SendLevel":A_SendLevel,"A_StoreCapsLockMode":A_StoreCapsLockMode,"A_KeyDelay":A_KeyDelay,"A_KeyDuration":A_KeyDuration,"A_KeyDelayPlay":A_KeyDelayPlay,"A_KeyDurationPlay":A_KeyDurationPlay,"A_WinDelay":A_WinDelay,"A_ControlDelay":A_ControlDelay,"A_MouseDelay":A_MouseDelay,"A_MouseDelayPlay":A_MouseDelayPlay,"A_DefaultMouseSpeed":A_DefaultMouseSpeed,"A_CoordModeToolTip":A_CoordModeToolTip,"A_CoordModePixel":A_CoordModePixel,"A_CoordModeMouse":A_CoordModeMouse,"A_CoordModeCaret":A_CoordModeCaret,"A_CoordModeMenu":A_CoordModeMenu,"A_RegView":A_RegView,"A_IconHidden":A_IconHidden,"A_IconTip":A_IconTip,"A_IconFile":A_IconFile,"A_IconNumber":A_IconNumber,"A_TimeIdle":A_TimeIdle,"A_TimeIdlePhysical":A_TimeIdlePhysical,"A_TimeIdleKeyboard":A_TimeIdleKeyboard,"A_TimeIdleMouse":A_TimeIdleMouse,"A_DefaultGUI":A_DefaultGUI,"A_DefaultListView":A_DefaultListView,"A_DefaultTreeView":A_DefaultTreeView,"A_Gui":A_Gui,"A_GuiControl":A_GuiControl,"A_GuiWidth":A_GuiWidth,"A_GuiHeight":A_GuiHeight,"A_GuiX":A_GuiX,"A_GuiY":A_GuiY,"A_GuiEvent":A_GuiEvent,"A_GuiControlEvent":A_GuiControlEvent,"A_EventInfo":A_EventInfo,"A_ThisMenuItem":A_ThisMenuItem,"A_ThisMenu":A_ThisMenu,"A_ThisMenuItemPos":A_ThisMenuItemPos,"A_ThisHotkey":A_ThisHotkey,"A_PriorHotkey":A_PriorHotkey,"A_PriorKey":A_PriorKey,"A_TimeSinceThisHotkey":A_TimeSinceThisHotkey,"A_TimeSincePriorHotkey":A_TimeSincePriorHotkey,"A_EndChar":A_EndChar,"A_ComSpec":A_ComSpec,"A_Temp":A_Temp,"A_OSType":A_OSType,"A_OSVersion":A_OSVersion,"A_Is64bitOS":A_Is64bitOS,"A_PtrSize":A_PtrSize,"A_Language":A_Language,"A_ComputerName":A_ComputerName,"A_UserName":A_UserName,"A_WinDir":A_WinDir,"A_ProgramFiles":A_ProgramFiles,"A_AppData":A_AppData,"A_AppDataCommon":A_AppDataCommon,"A_Desktop":A_Desktop,"A_DesktopCommon":A_DesktopCommon,"A_DesktopCommon":A_DesktopCommon}

                        gui %GUI_ID%  add, DateTime, % Value.ctrlOptions " h30 vv" Parameter " hwndDA" Parameter, % "dd.MM.yyyy"
                        guicontrol %GUI_ID%,v%Parameter%,% DA_DateParse(DA_FormatEx(Value.Value, AHKVARIABLES))
                        if (this.StepsizedGuishow) {
                            gui %GUI_ID% show
                        }
                    } else {
                        if Value.HasKey("Link") {
                            if (Value.Control="Checkbox") { 
                                gui %GUI_ID% add, Link,% "h20 hwndDALink" Parameter, % "<a href=""" Value.Link """>?</a>" A_Space
                                gui %GUI_ID% add, % Value.Control, % Value.ctrlOptions "yp-8 xp+8 h30 vv" Parameter " hwndDA" Parameter, % Value.String
                                gui %GUI_ID% add, text, h0 w0 xp-8 yp+20
                                if (this.StepsizedGuishow) {
                                    gui %GUI_ID% show
                                }
                            }
                            if (Value.Control="Text") {
                                gui %GUI_ID% add, text, % Value.ctrlOptions " h30 vv" Parameter " hwndDALink" Parameter, % Value.String
                            }
                        } else {
                            gui %GUI_ID% add, % Value.Control, % Value.ctrlOptions " h30 vv" Parameter " hwndDA" Parameter, % Value.String
                            if (this.StepsizedGuishow) {
                                gui %GUI_ID% show
                            }
                        }
                        ControlHeight+=30
                    }
                    if Value.HasKey("TTIP") {
                        if AddToolTip(Deref("%DA" Parameter "%"),  strreplace(Value.TTIP,"\n","`n"),,hwndDA) {

                        }
                        if AddToolTip(Deref("%DALink" Parameter "%"),  strreplace(Value.TTIP,"\n","`n"),,hwndDA) {

                        }
                    }
                    if (Value.Control="Checkbox") {

                        guicontrol %GUI_ID% ,v%Parameter%, % Value.Default
                    }

                    if (Control="Edit") {
                        ; V.String:=tmp
                    }
                    if InStr(Parameter,"pandoc") {
                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight

                    } else {

                        GuiControl Move, vTab3, % "h" TabHeight + ControlHeight + 16
                    }
                    TabHeight+=ControlHeight + 3
                }
                GuiControl Move, vTab3, % "h" TabHeight + 32
                ;gui show
            }
            TabHeaders[Tab].Height+=TabHeight+=32
        }
        maxTabHeight:=0
        for _, Tab in TabHeaders {
            if HiddenHeaders[Tab] {
                continue
            }
            if (Tab.Height>maxTabHeight) {
                maxTabHeight:=Tab.Height
            }
        }
        maxTabHeight+=80
        GuiControl Move, vTab3, % "h" maxTabHeight
        maxTabHeight+=25
        GuiControl Choose, vTab3, 1
        gui %GUI_ID% Tab
        if (AttachBottom) {
            gui %GUI_ID% add, button,y%maxTabHeight% xp hwndSubmitButton,&Submit
            onSubmit:=ObjBindMethod(this, "SubmitDynamicArguments")
            GuiControl %GUI_ID% +g,%SubmitButton%, % onSubmit
            gui %GUI_ID% add, button, yp xp+60 hwndEditConfig, Edit Configuration
            onEditConfig:=ObjBindMethod(this, "EditConfig")
            GuiControl %GUI_ID% +g,%EditConfig%, % onEditConfig
            onEscape:=ObjBindMethod(this,"otGUI_Escape2")
            Hotkey IfWinActive, % "ahk_id " otGUI_
            Hotkey Escape,% onEscape
            guiWidth:=692
                , guiHeight:=maxTabHeight+40
        } else {
            guiWidth:=692
                , guiHeight:=maxTabHeight

        }
        ;if (!x || (x="")) {
        currentMonitor:=MWAGetMonitor()+0
        SysGet MonCount, MonitorCount
        if (MonCount>1) {
            SysGet Mon, Monitor,% currentMonitor
        } else {
            SysGet Mon, Monitor, 1
        }
        MonWidth:=(MonLeft?MonLeft:MonRight)
            , MonWidth:=MonRight-MonLeft
        if SubStr(MonWidth, 1,1)="-" {
            MonWidth:=SubStr(MonWidth,2)
        }
        CoordModeMouse:=A_CoordModeMouse
        CoordMode Mouse,Screen
        MouseGetPos MouseX
        CoordMode Mouse, %CoordModeMouse%
        if ((x+guiWidth)>MonRight) {
            x:=MonRight-guiWidth
        } Else {
            x:=MouseX
        } 
        ;  }
        if (this.StepsizedGuishow) || ShowGui {
            if (x!="") && (y!="") {
                gui %GUI_ID% Show,x%x% y%y% w%guiWidth% h%guiHeight%,% GUIName:=this.GUITitle this.type
            } else {
                gui %GUI_ID% Show,w%guiWidth% h%guiHeight%,% GUIName:=this.GUITitle this.type
            }
            WinWait % GUIName
            if this.SkipGUI {
                this.SubmitDynamicArguments() ;; auto-submit the GUI
            } Else {
                WinWaitClose % GUIName
            }
        }
        return this
    }
    EditConfig() {
        static
        GUI_ID:=this.GUI_ID
        gui %GUI_ID% Submit, NoHide
        RunWait % this.ConfigFile,,,PID
        WinWaitClose % "ahk_PID" PID
        Gui +OwnDialogs
        OnMessage(0x44, "DA_OnMsgBox")
        answer := AppError(this.ClassName " > " A_ThisFunc "()", "You modified the configuration for this class.`nReload?", 0x44)
        OnMessage(0x44, "")
        if (answer = "Yes") {
            reload()
        }

    }
    SubmitDynamicArguments(destroy:=true) {
        static
        GUI_ID:=this.GUI_ID
        gui %GUI_ID% Default
        if (destroy) {
            gui %GUI_ID% Submit
        } else {
            gui %GUI_ID% Submit, NoHide
        }
        for Parameter,_ in this.Arguments {

            Parameter:=strreplace(Parameter,"-","___")
            ;k=v%Parameter% ;; i know this is jank, but I can't seem to fix it. just don't touch for now?
            ;a:=%k%
            GuiControlGet val,, v%Parameter%
            Parameter:=strreplace(Parameter,"___","-")
            this["Arguments",Parameter].Value:=val
        }
        if (destroy) {
            gui %GUI_ID% destroy
        }
        return this
    }
    otGUI_Escape2() {
        static
        GUI_ID:=this.GUI_ID
        gui %GUI_ID% Submit
        gui %GUI_ID% destroy
        ID:=0
        this.Error:=this.Errors[ID]
        return this
    }
}

; #region:DA_Quote (4179423054)

; #region:Metadata:
; Snippet: DA_Quote;  (v.1)
; --------------------------------------------------------------
; Author: u/anonymous1184
; Source: https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
; (11.11.2022)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: apostrophe
; #endregion:Metadata

; #region:Description:
; Quotes a string
; #endregion:Description

; #region:Example
; Var:="Hello World"
; msgbox, % DA_Quote(Var . " Test")
;
; #endregion:Example

; #region:Code
DA_Quote(String) { ; u/anonymous1184 https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
    return """" String """"
}
; #endregion:Code

; #endregion:DA_Quote (4179423054)

DA_OnMsgBox() {
    DetectHiddenWindows On
    Process Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Reload
        ControlSetText Button2, Continue with old
    }
}


; #region:DateParse (3465982675)

; #region:Metadata:
; Snippet: DateParse;  (v.1.05)
; --------------------------------------------------------------
; Author: polythene
; License: GNU GPL2
; LicenseURL: https://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
; Source: https://www.autohotkey.com/board/topic/18760-date-parser-convert-any-date-format-to-yyyymmddhh24miss/?p=124324
; NOTE Gewerd Strauss:: I could track down polythene's linked post above as the oldest found 
; post mentioning this post, wherein the need to link to their ahknet-site is required.
; However, since ahknet has been offline long before I needed to use this.
; (01 August 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 26 - Date or Time
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: date, parsing, iso, YYYYMMDDHH24MISS
; #endregion:Metadata


; #region:Description:
; convert almost any date format to a YYYYMMDDHH24MISS value.
; Parameters:
; 	str - a date/time stamp as a string
; Returns:
; 	A valid YYYYMMDDHH24MISS value which can be used by FormatTime, EnvAdd and other time commands.
; License:
; 	- Version 1.05 <http://www.autohotkey.net/~polyethene/#dateparse>
; 	- Dedicated to the public domain (CC0 1.0) <http://creativecommons.org/publicdomain/zero/1.0/>
; #endregion:Description

; #region:Example
; time := DA_DateParse("2:35 PM, 27 November, 2007")
; #endregion:Example


; #region:Code
/*

*/
DA_DateParse(str) {
    static e2 = "i)(?:(\d{1,2}+)[\s\.\-\/,]+)?(\d{1,2}|(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\w*)[\s\.\-\/,]+(\d{2,4})"
    str := RegExReplace(str, "((?:" . SubStr(e2, 42, 47) . ")\w*)(\s*)(\d{1,2})\b", "$3$2$1", "", 1)
    If RegExMatch(str, "i)^\s*(?:(\d{4})([\s\-:\/])(\d{1,2})\2(\d{1,2}))?"
        . "(?:\s*[T\s](\d{1,2})([\s\-:\/])(\d{1,2})(?:\6(\d{1,2})\s*(?:(Z)|(\+|\-)?"
        . "(\d{1,2})\6(\d{1,2})(?:\6(\d{1,2}))?)?)?)?\s*$", i)
    d3 := i1, d2 := i3, d1 := i4, t1 := i5, t2 := i7, t3 := i8
    Else If !RegExMatch(str, "^\W*(\d{1,2}+)(\d{2})\W*$", t)
        RegExMatch(str, "i)(\d{1,2})\s*:\s*(\d{1,2})(?:\s*(\d{1,2}))?(?:\s*([ap]m))?", t)
        , RegExMatch(str, e2, d)
    f := A_FormatFloat

    SetFormat Float, 02.0
    d := (d3 ? (StrLen(d3) = 2 ? 20 : "") . d3 : A_YYYY)
        . ((d2 := d2 + 0 ? d2 : (InStr(e2, SubStr(d2, 1, 3)) - 40) // 4 + 1.0) > 0
        ? d2 + 0.0 : A_MM) . ((d1 += 0.0) ? d1 : A_DD) . t1
        + (t1 = 12 ? t4 = "am" ? -12.0 : 0.0 : t4 = "am" ? 0.0 : 12.0) . t2 + 0.0 . t3 + 0.0

    SetFormat Float, % f
    Return, d
}

; #endregion:Code




; #region:License
;                     GNU GENERAL PUBLIC LICENSE
;                        Version 2, June 1991
; 
;  Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
;  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
;  Everyone is permitted to copy and distribute verbatim copies
;  of this license document, but changing it is not allowed.
; 
;                             Preamble
; 
;   The licenses for most software are designed to take away your
; freedom to share and change it.  By contrast, the GNU General Public
; License is intended to guarantee your freedom to share and change free
; software--to make sure the software is free for all its users.  This
; General Public License applies to most of the Free Software
; Foundation's software and to any other program whose authors commit to
; using it.  (Some other Free Software Foundation software is covered by
; the GNU Lesser General Public License instead.)  You can apply it to
; your programs, too.
; 
;   When we speak of free software, we are referring to freedom, not
; price.  Our General Public Licenses are designed to make sure that you
; have the freedom to distribute copies of free software (and charge for
; this service if you wish), that you receive source code or can get it
; if you want it, that you can change the software or use pieces of it
; in new free programs; and that you know you can do these things.
; 
;   To protect your rights, we need to make restrictions that forbid
; anyone to deny you these rights or to ask you to surrender the rights.
; These restrictions translate to certain responsibilities for you if you
; distribute copies of the software, or if you modify it.
; 
;   For example, if you distribute copies of such a program, whether
; gratis or for a fee, you must give the recipients all the rights that
; you have.  You must make sure that they, too, receive or can get the
; source code.  And you must show them these terms so they know their
; rights.
; 
;   We protect your rights with two steps: (1) copyright the software, and
; (2) offer you this license which gives you legal permission to copy,
; distribute and/or modify the software.
; 
;   Also, for each author's protection and ours, we want to make certain
; that everyone understands that there is no warranty for this free
; software.  If the software is modified by someone else and passed on, we
; want its recipients to know that what they have is not the original, so
; that any problems introduced by others will not reflect on the original
; authors' reputations.
; 
;   Finally, any free program is threatened constantly by software
; patents.  We wish to avoid the danger that redistributors of a free
; program will individually obtain patent licenses, in effect making the
; program proprietary.  To prevent this, we have made it clear that any
; patent must be licensed for everyone's free use or not licensed at all.
; 
;   The precise terms and conditions for copying, distribution and
; modification follow.
; 
;                     GNU GENERAL PUBLIC LICENSE
;    TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
; 
;   0. This License applies to any program or other work which contains
; a notice placed by the copyright holder saying it may be distributed
; under the terms of this General Public License.  The "Program", below,
; refers to any such program or work, and a "work based on the Program"
; means either the Program or any derivative work under copyright law:
; that is to say, a work containing the Program or a portion of it,
; either verbatim or with modifications and/or translated into another
; language.  (Hereinafter, translation is included without limitation in
; the term "modification".)  Each licensee is addressed as "you".
; 
; Activities other than copying, distribution and modification are not
; covered by this License; they are outside its scope.  The act of
; running the Program is not restricted, and the output from the Program
; is covered only if its contents constitute a work based on the
; Program (independent of having been made by running the Program).
; Whether that is true depends on what the Program does.
; 
;   1. You may copy and distribute verbatim copies of the Program's
; source code as you receive it, in any medium, provided that you
; conspicuously and appropriately publish on each copy an appropriate
; copyright notice and disclaimer of warranty; keep intact all the
; notices that refer to this License and to the absence of any warranty;
; and give any other recipients of the Program a copy of this License
; along with the Program.
; 
; You may charge a fee for the physical act of transferring a copy, and
; you may at your option offer warranty protection in exchange for a fee.
; 
;   2. You may modify your copy or copies of the Program or any portion
; of it, thus forming a work based on the Program, and copy and
; distribute such modifications or work under the terms of Section 1
; above, provided that you also meet all of these conditions:
; 
;     a) You must cause the modified files to carry prominent notices
;     stating that you changed the files and the date of any change.
; 
;     b) You must cause any work that you distribute or publish, that in
;     whole or in part contains or is derived from the Program or any
;     part thereof, to be licensed as a whole at no charge to all third
;     parties under the terms of this License.
; 
;     c) If the modified program normally reads commands interactively
;     when run, you must cause it, when started running for such
;     interactive use in the most ordinary way, to print or display an
;     announcement including an appropriate copyright notice and a
;     notice that there is no warranty (or else, saying that you provide
;     a warranty) and that users may redistribute the program under
;     these conditions, and telling the user how to view a copy of this
;     License.  (Exception: if the Program itself is interactive but
;     does not normally print such an announcement, your work based on
;     the Program is not required to print an announcement.)
; 
; These requirements apply to the modified work as a whole.  If
; identifiable sections of that work are not derived from the Program,
; and can be reasonably considered independent and separate works in
; themselves, then this License, and its terms, do not apply to those
; sections when you distribute them as separate works.  But when you
; distribute the same sections as part of a whole which is a work based
; on the Program, the distribution of the whole must be on the terms of
; this License, whose permissions for other licensees extend to the
; entire whole, and thus to each and every part regardless of who wrote it.
; 
; Thus, it is not the intent of this section to claim rights or contest
; your rights to work written entirely by you; rather, the intent is to
; exercise the right to control the distribution of derivative or
; collective works based on the Program.
; 
; In addition, mere aggregation of another work not based on the Program
; with the Program (or with a work based on the Program) on a volume of
; a storage or distribution medium does not bring the other work under
; the scope of this License.
; 
;   3. You may copy and distribute the Program (or a work based on it,
; under Section 2) in object code or executable form under the terms of
; Sections 1 and 2 above provided that you also do one of the following:
; 
;     a) Accompany it with the complete corresponding machine-readable
;     source code, which must be distributed under the terms of Sections
;     1 and 2 above on a medium customarily used for software interchange; or,
; 
;     b) Accompany it with a written offer, valid for at least three
;     years, to give any third party, for a charge no more than your
;     cost of physically performing source distribution, a complete
;     machine-readable copy of the corresponding source code, to be
;     distributed under the terms of Sections 1 and 2 above on a medium
;     customarily used for software interchange; or,
; 
;     c) Accompany it with the information you received as to the offer
;     to distribute corresponding source code.  (This alternative is
;     allowed only for noncommercial distribution and only if you
;     received the program in object code or executable form with such
;     an offer, in accord with Subsection b above.)
; 
; The source code for a work means the preferred form of the work for
; making modifications to it.  For an executable work, complete source
; code means all the source code for all modules it contains, plus any
; associated interface definition files, plus the scripts used to
; control compilation and installation of the executable.  However, as a
; special exception, the source code distributed need not include
; anything that is normally distributed (in either source or binary
; form) with the major components (compiler, kernel, and so on) of the
; operating system on which the executable runs, unless that component
; itself accompanies the executable.
; 
; If distribution of executable or object code is made by offering
; access to copy from a designated place, then offering equivalent
; access to copy the source code from the same place counts as
; distribution of the source code, even though third parties are not
; compelled to copy the source along with the object code.
; 
;   4. You may not copy, modify, sublicense, or distribute the Program
; except as expressly provided under this License.  Any attempt
; otherwise to copy, modify, sublicense or distribute the Program is
; void, and will automatically terminate your rights under this License.
; However, parties who have received copies, or rights, from you under
; this License will not have their licenses terminated so long as such
; parties remain in full compliance.
; 
;   5. You are not required to accept this License, since you have not
; signed it.  However, nothing else grants you permission to modify or
; distribute the Program or its derivative works.  These actions are
; prohibited by law if you do not accept this License.  Therefore, by
; modifying or distributing the Program (or any work based on the
; Program), you indicate your acceptance of this License to do so, and
; all its terms and conditions for copying, distributing or modifying
; the Program or works based on it.
; 
;   6. Each time you redistribute the Program (or any work based on the
; Program), the recipient automatically receives a license from the
; original licensor to copy, distribute or modify the Program subject to
; these terms and conditions.  You may not impose any further
; restrictions on the recipients' exercise of the rights granted herein.
; You are not responsible for enforcing compliance by third parties to
; this License.
; 
;   7. If, as a consequence of a court judgment or allegation of patent
; infringement or for any other reason (not limited to patent issues),
; conditions are imposed on you (whether by court order, agreement or
; otherwise) that contradict the conditions of this License, they do not
; excuse you from the conditions of this License.  If you cannot
; distribute so as to satisfy simultaneously your obligations under this
; License and any other pertinent obligations, then as a consequence you
; may not distribute the Program at all.  For example, if a patent
; license would not permit royalty-free redistribution of the Program by
; all those who receive copies directly or indirectly through you, then
; the only way you could satisfy both it and this License would be to
; refrain entirely from distribution of the Program.
; 
; If any portion of this section is held invalid or unenforceable under
; any particular circumstance, the balance of the section is intended to
; apply and the section as a whole is intended to apply in other
; circumstances.
; 
; It is not the purpose of this section to induce you to infringe any
; patents or other property right claims or to contest validity of any
; such claims; this section has the sole purpose of protecting the
; integrity of the free software distribution system, which is
; implemented by public license practices.  Many people have made
; generous contributions to the wide range of software distributed
; through that system in reliance on consistent application of that
; system; it is up to the author/donor to decide if he or she is willing
; to distribute software through any other system and a licensee cannot
; impose that choice.
; 
; This section is intended to make thoroughly clear what is believed to
; be a consequence of the rest of this License.
; 
;   8. If the distribution and/or use of the Program is restricted in
; certain countries either by patents or by copyrighted interfaces, the
; original copyright holder who places the Program under this License
; may add an explicit geographical distribution limitation excluding
; those countries, so that distribution is permitted only in or among
; countries not thus excluded.  In such case, this License incorporates
; the limitation as if written in the body of this License.
; 
;   9. The Free Software Foundation may publish revised and/or new versions
; of the General Public License from time to time.  Such new versions will
; be similar in spirit to the present version, but may differ in detail to
; address new problems or concerns.
; 
; Each version is given a distinguishing version number.  If the Program
; specifies a version number of this License which applies to it and "any
; later version", you have the option of following the terms and conditions
; either of that version or of any later version published by the Free
; Software Foundation.  If the Program does not specify a version number of
; this License, you may choose any version ever published by the Free Software
; Foundation.
; 
;   10. If you wish to incorporate parts of the Program into other free
; programs whose distribution conditions are different, write to the author
; to ask for permission.  For software which is copyrighted by the Free
; Software Foundation, write to the Free Software Foundation; we sometimes
; make exceptions for this.  Our decision will be guided by the two goals
; of preserving the free status of all derivatives of our free software and
; of promoting the sharing and reuse of software generally.
; 
;                             NO WARRANTY
; 
;   11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
; FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
; OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
; PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
; OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
; MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
; TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
; PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
; REPAIR OR CORRECTION.
; 
;   12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
; WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
; REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
; INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
; OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
; TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
; YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
; PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGES.
; 
;                      END OF TERMS AND CONDITIONS
; 
;             How to Apply These Terms to Your New Programs
; 
;   If you develop a new program, and you want it to be of the greatest
; possible use to the public, the best way to achieve this is to make it
; free software which everyone can redistribute and change under these terms.
; 
;   To do so, attach the following notices to the program.  It is safest
; to attach them to the start of each source file to most effectively
; convey the exclusion of warranty; and each file should have at least
; the "copyright" line and a pointer to where the full notice is found.
; 
;     <one line to give the program's name and a brief idea of what it does.>
;     Copyright (C) <year>  <name of author>
; 
;     This program is free software; you can redistribute it and/or modify
;     it under the terms of the GNU General Public License as published by
;     the Free Software Foundation; either version 2 of the License, or
;     (at your option) any later version.
; 
;     This program is distributed in the hope that it will be useful,
;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;     GNU General Public License for more details.
; 
;     You should have received a copy of the GNU General Public License along
;     with this program; if not, write to the Free Software Foundation, Inc.,
;     51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
; 
; Also add information on how to contact you by electronic and paper mail.
; 
; If the program is interactive, make it output a short notice like this
; when it starts in an interactive mode:
; 
;     Gnomovision version 69, Copyright (C) year name of author
;     Gnomovision comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
;     This is free software, and you are welcome to redistribute it
;     under certain conditions; type `show c' for details.
; 
; The hypothetical commands `show w' and `show c' should show the appropriate
; parts of the General Public License.  Of course, the commands you use may
; be called something other than `show w' and `show c'; they could even be
; mouse-clicks or menu items--whatever suits your program.
; 
; You should also get your employer (if you work as a programmer) or your
; school, if any, to sign a "copyright disclaimer" for the program, if
; necessary.  Here is a sample; alter the names:
; 
;   Yoyodyne, Inc., hereby disclaims all copyright interest in the program
;   `Gnomovision' (which makes passes at compilers) written by James Hacker.
; 
;   <signature of Ty Coon>, 1 April 1989
;   Ty Coon, President of Vice
; 
; This General Public License does not permit incorporating your program into
; proprietary programs.  If your program is a subroutine library, you may
; consider it more useful to permit linking proprietary applications with the
; library.  If this is what you want to do, use the GNU Lesser General
; Public License instead of this License.
; 
; #endregion:License

; #endregion:DateParse (3465982675)
DA_FormatEx(FormatStr, Values*) {
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
            FormatStr := StrReplace(FormatStr, "{" search "}", "{" ++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}
sink() {

}
IsDebug() {
    static _ := !!(DllCall("GetCommandLine", "Str") ~= "i) \/Debug(=\H+)? ")
    return _
}
MWAGetMonitor(Mx := "", My := "") { ; Maestr0 | fetched from https://www.autohotkey.com/boards/viewtopic.php?p=342716#p342716
    if (!Mx or !My) {
        ; if Mx or My is empty, revert to the mouse cursor placement
        Coordmode Mouse, Screen	; use Screen, so we can compare the coords with the sysget information`
        MouseGetPos Mx, My
    }

    SysGet MonitorCount, 80	; monitorcount, so we know how many monitors there are, and the number of loops we need to do
    Loop, %MonitorCount%{
        SysGet mon%A_Index%, Monitor, %A_Index%	; "Monitor" will get the total desktop space of the monitor, including taskbars

        if (Mx >= mon%A_Index%left) && (Mx < mon%A_Index%right) && (My >= mon%A_Index%top) && (My < mon%A_Index%bottom) {
            ActiveMon := A_Index
            break
        }
    }
    return ActiveMon
}
fonExit(DebugState) {
    /*
    
    */
    if (DebugState) {

    }
    ; TODO: write in extensive CodeTimer-calls for every step, push all times and their names to an array
    ; and write that to the log when the program exits
    ; or encounters an error
}
; #region:Quote (4179423054)

; #region:Metadata:
; Snippet: Quote;  (v.1)
; --------------------------------------------------------------
; Author: u/anonymous1184
; Source: https://www.reddit.com/r/AutoHotkey/comments/p2z9co/comment/h8oq1av/?utm_source=share&utm_medium=web2x&context=3
; (11.11.2022)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: apostrophe
; #endregion:Metadata

; #region:Description:
; Quotes a string
; #endregion:Description

; #region:Example
; Var:="Hello World"
; msgbox, % Quote(Var . " Test")
;
; #endregion:Example

; #region:Code
Quote(String) {
  return "" "" String "" ""
}
; #endregion:Code

; #endregion:Quote (4179423054)
; --uID:2849897047
; Metadata:
; Snippet: st_count  ;  (v.2.6)
; --------------------------------------------------------------
; Author: tidbit et al
; License: none
; Source: https://www.autohotkey.com/boards/viewtopic.php?t=53
;
; --------------------------------------------------------------
; Library: Libs
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: string things,

;; Description:
;;
;; Count
;;    Counts the number of times a tolken exists in the specified string.
;;
;;    string    = The string which contains the content you want to count.
;;    searchFor = What you want to search for and count.
;;
;;    note: If you're counting lines, you may need to add 1 to the results.
;;
;;
;; Name: String Things - Common String & Array Functions
;; Version 2.6 (Fri May 30, 2014)
;; Created: Sat March 02, 2013
;; Author: tidbit
;; Credit:
;;    AfterLemon  --- st_insert(), st_overwrite() bug fix. st_strip(), and more.
;;    Bon         --- word(), leftOf(), rightOf(), between() - These have been replaced
;;    faqbot      --- jumble()
;;    Lexikos     --- flip()
;;    MasterFocus --- Optimizing LineWrap and WordWrap.
;;    rbrtryn     --- group()
;;    Rseding91   --- Optimizing LineWrap and WordWrap.
;;    Verdlin     --- st_concat(), A couple nifty forum-only functions.
;;
;; Description:
;;    A compilation of commonly needed function for strings and arrays.

;;; Example:
;;; msgbox, % st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
;;; ;; output: 4

st_count(string, searchFor="`n") {
   StringReplace string, string, %searchFor%, %searchFor%, UseErrorLevel
   return ErrorLevel
}

; --uID:2849897047

st_concat(delim,final_delim, as*)
{
   s:=""
   if (as.Length()=1) {
      as:=as[1]
   }
   for k, v in as {
      if (k<(as.Count()-1)) {
         s .= v . delim
      } else {
         s .= v . final_delim
      }
   }
   return subStr(s,1,-strLen(delim))
}
st_removeDuplicates(string, delim="`n")
{
   delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
   Return RegExReplace(string, "(" delim ")+", "$1")
}


/*
Pad
Add character(s) to either side of the input string.

string = What text you want to add stuff to either side.
left   = The text you want to add to the left side.
right  = The text you want to add to the right side.
Lcount = How many times do you want to repeat adding to the left side.
Rcount = How many times do you want to repeat adding to the right side.

example: st_pad("aaa", "+", "-^", 5)
output: +++++aaa-^
*/
st_pad(string, left="0", right="", LCount=1, RCount=1)
{
   Lout:=ROut:=""
   if (LCount>0)
   {
      if (LCount>1)
         loop, %LCount%
            Lout.=left
         Else
            Lout:=left
   }
   if (RCount>0)
   {
      if (RCount>1)
         loop, %RCount%
            ROut.=right
         Else
            ROut.=right
   }
   Return Lout string ROut
}
; --uID:2340782430
; Metadata:
; Snippet: ttip  ;  (v.0.2.1)
; --------------------------------------------------------------
; Author: Gewerd Strauss
; License: WTFPL
; --------------------------------------------------------------
; Library: Personal Library
; Section: 21 - ToolTips
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: TOOLTIP

;; Description:
;; small tooltip handler
;;
;; /*
;;
;; 		Modes:
;; 	                 -1: do not show ttip - useful when you want to temporarily disable it, without having to remove the call every time, but without having to change text every time.
;; 		1: remove tt after "to" milliseconds
;; 		2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat
;; 		3: not sure anymore what the plan was lol - remove
;; 		4: shows tooltip slightly offset from current mouse, does not repeat
;; 		5: keep that tt until the function is called again
;;
;; 		CoordMode:
;; 		-1: Default: currently set behaviour
;; 		1: Screen
;; 		2: Window
;;
;; 		to:
;; 		Timeout in milliseconds
;;
;; 		xp/yp:
;; 		xPosition and yPosition of tooltip.
;; 		"NaN": offset by +50/+50 relative to mouse
;; 		IF mode=4,
;; 		----  Function uses tooltip 20 by default, use parameter
;; 		"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
;; 		separately from each other, hence a removal of ttip20 will not remove tt14
;;
;; 		---
;; 		v.0.2.1
;; 		- added Obj2Str-Conversion via "ttip_Obj2Str()"
;; 		v.0.1.1
;; 		- Initial build, 	no changelog yet
;;
;; 	*/

ttip(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2:=1750,Times:=20,currTip:=20)
{

	cCoordModeTT:=A_CoordModeToolTip
	if (mode=-1)
		return
	if (text="") || (text=-1) {
		gosub, llTTIP_RemoveTTIP
		return
	}
	if IsObject(text)
		text:=ttip_Obj2Str(text)
	static ttip_text
		, currTip2
	global ttOnOff
	currTip2:=currTip
		, cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
	CoordMode % cMode
	tooltip

	ttip_text:=text
		, lUnevenTimers:=false
	MouseGetPos xp1,yp1
	if (mode=4) ; set text offset from cursor
	{
		yp:=yp1+15
		xp:=xp1
	}
	else
	{
		if (xp="NaN")
			xp:=xp1 + 50
		if (yp="NaN")
			yp:=yp1 + 50
	}
	tooltip % ttip_text,xp,yp,% currTip
	if (mode=1) ; remove after given time
	{
		SetTimer llTTIP_RemoveTTIP, % "-" to
	}
	else if (mode=2) ; remove, but repeatedly show every "to"
	{
		; gosub,  A
		global to_1:=to
			, to2_1:=to2
		global tTimes:=Times
		Settimer lTTIP_SwitchOnOff,-100
	}
	else if (mode=3)
	{
		lUnevenTimers:=true
		SetTimer llTTIP_RepeatedShow, % to
	}
	else if (mode=5) ; keep until function called again
	{

	}
	CoordMode % cCoordModeTT
	return text
	lTTIP_SwitchOnOff:
	ttOnOff++
	if mod(ttOnOff,2)
	{
		gosub, llTTIP_RemoveTTIP
		sleep % to_1
	}
	else
	{
		tooltip % ttip_text,xp,yp,% currTip
		sleep % to2_1
	}
	if (ttOnOff>=ttimes)
	{
		Settimer lTTIP_SwitchOnOff, off
		gosub, llTTIP_RemoveTTIP
		return
	}
	Settimer lTTIP_SwitchOnOff, -100
	return

	llTTIP_RepeatedShow:
	ToolTip % ttip_text,,, % currTip2
	if lUnevenTimers
		sleep % to2
	Else
		sleep % to
	return
	llTTIP_RemoveTTIP:
	ToolTip,,,,currTip2
	return
}

ttip_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
	String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		for a,b in Obj{
			if(IsObject(b))
			String:= ttip_Obj2Str(b,FullPath "." a,BottomBlank) A_Space
			else{
				if(BottomBlank=0)
				String.=FullPath "." a " = " b "`n"
				else if(b!="")
					String.=FullPath "." a " = " b "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
		}}
	return String Blank
}

; --uID:2340782430
; #region:writeFile (3352591673)

; #region:Metadata:
; Snippet: writeFile;  (v.1.0)
;  10 April 2023
; --------------------------------------------------------------
; Author: Gewerd Strauss
; License: MIT
; --------------------------------------------------------------
; Library: Personal Library
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: encoding, UTF-8/UTF-8-RAW
; #endregion:Metadata

; #region:Description:
; Small function for writing files to disk in a safe manner when requiring specific file encodings or flags.
; Allows f.e. UTF-8 filewrites
; #endregion:Description

; #region:Example
; Loop, Files, % Folder "\*." script.config.Config.filetype, F
;         {
;             scriptWorkingDir:=renameFile(A_LoopFileFullPath,Arr[A_Index],true,A_Index,TrueNumberOfFiles)
;             writeFile(scriptWorkingDir "\gfa_renamer_log.txt",Files, "UTF-8-RAW","w",true)
;         }
; #endregion:Example

; #region:Code
writeFile(Path,Content,Encoding:="",Flags:=0x2,bSafeOverwrite:=false) {
    if (bSafeOverwrite && FileExist(Path)) {
        ; if we want to ensure nonexistance.
        FileDelete % Path
    }
    try {
        if (Encoding!="") {
            if (fObj:=FileOpen(Path,Flags,Encoding)) {
                fObj.Write(Content) ;; insert contents
                    , fObj.Close() ;; close file
            }
            else {

                throw Exception("File could not be opened. Flags:`n" Flags, -1, myFile)
            }
        } else {
            if (fObj:=FileOpen(Path,Flags)) {
                fObj.Write(Content) ;; insert contents
                    , fObj.Close() ;; close file
            } else {
                throw Exception("File could not be opened. Flags:`n" Flags, -1, myFile)
            }
        }
    }
    return
}
; #endregion:Code

; #endregion:writeFile (3352591673)
class gfcGUI extends dynamicGUI {
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
                guicontrol % "GC:" "ChooseString",% "v" StrReplace(Parameter,"-","___") , % Value.Value
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

fEditSettings() {
    ; A_ThisHotkey
    gui GC: -AlwaysOnTop
    if ((!globalLogicSwitches.bIsAuthor & !globalLogicSwitches.bIsDebug) || (globalLogicSwitches.bIsAuthor & !globalLogicSwitches.bIsDebug)) {
        if ACS_InisettingsEditor(script.Name,script.scriptconfigfile,0,1,0) {
            OnMessage(0x44, "OnMsgBox_ChangedSettings")
            answer := AppError(script.name " > Editing program settings", "You changed settings. In order for these settings to take effect`, you need to reload the program. `n`nDoing so will discard any changes which are not yet saved. `n`nDo you want to reload the program with the updated settings now`, or use the previous settings to continue working?", 0x44)
            OnMessage(0x44, "")
            if (answer = "Yes") {
                reload()
            }
        } else {
            gui % "GC: "((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
        }
    } else if ACS_InisettingsEditor(script.Name,script.scriptconfigfile,0,1,1) {
        OnMessage(0x44, "OnMsgBox_ChangedSettings")
        answer := AppError(script.name " > Editing program settings", "You changed settings. In order for these settings to take effect`, you need to reload the program. `n`nDoing so will discard any changes which are not yet saved. `n`nDo you want to reload the program with the updated settings now`, or use the previous settings to continue working?", 0x44)
        OnMessage(0x44, "")
        if (answer = "Yes") {
            reload()
        }
    } else {
        gui % "GC: " ((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
    }
    return
}
OnMsgBox_ChangedSettings() {
    DetectHiddenWindows On
    Process Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Reload
        ControlSetText Button2, Keep settings
    }
}
restoredefaultConfig() {

}
setupdefaultconfig(Switch) {
    DefaultConfig=
        (LTrim

            [Version]
            ;Version Type: Text
            ;Version Hidden:
            build=130
            GFC_version=1.5.45
            [Configurator_settings]
            bDebugSwitch=0
            ;bDebugSwitch hidden:
            ;bDebugSwitch Type: Checkbox
            ;bDebugSwitch CheckboxName: Enable Debugging-Mode?
            ;bDebugSwitch Allow extended logging of various information to be output in the program's directory.
            ;bDebugSwitch Furthermore allows modifying hidden configuration keys, although it is not suggested to do so.
            ;bDebugSwitch Pressing Alt+Escape while in debug-mode will discard all data and restart the program. THIS CAN LEAD TO DATA-LOSS.
            ;bDebugSwitch Default: 0
            AlwaysOnTop=0
            ;AlwaysOnTop Type: Checkbox
            ;AlwaysOnTop CheckboxName: Set the GUI to be always on top?
            ;AlwaysOnTop This will keep the gui front and center on your screen. You can still hide the GUI via the tray-menu item.
            ;AlwaysOnTop Default: 0
            SizeSetting=1080p
            ;SizeSetting Determine how to scale the GUI: Auto will calculate the GUI-dimensions based on your main monitor's size. '1080p' and '1440p' will force a scaling based on that assumption.
            ;SizeSetting Type: DropDown 1080p|1440p||auto
            ;SizeSetting Default: auto
            ConfigHistoryLimit=25
            ;ConfigHistoryLimit Type: Integer
            ;ConfigHistoryLimit How many previous config files do you want to keep in your history?
            ;ConfigHistoryLimit Files that got moved are automatically removed
            ;ConfigHistoryLimit Default: 25
            bRunAsAdmin=0
            ;bRunAsAdmin Do you want to always start the script with Administrator-privileges?
            ;bRunAsAdmin Type: Checkbox
            ;bRunAsAdmin CheckboxName: Always start as Administrator? (Requires restart to take effect.)
            ;bRunAsAdmin Default: 0
            GFA_Evaluation_InstallationPath=%A_ScriptDir%\GFA_Evaluation.R
            ;GFA_Evaluation_InstallationPath Type: File
            ;GFA_Evaluation_InstallationPath Please select the location of your 'GFA_Evaluation.R'-Script.
            ;GFA_Evaluation_InstallationPath By default, this utility is shipped with a copy on hand, so you can use this.
            ;GFA_Evaluation_InstallationPath
            ;GFA_Evaluation_InstallationPath
            UseRelativeConfigPaths=0
            ;UseRelativeConfigPaths CheckboxName: Use relative paths to the starter-R-Script?
            ;UseRelativeConfigPaths Type: Checkbox
            ;UseRelativeConfigPaths Do you want to use relative configuration-paths when calling GFA_main()?
            ;UseRelativeConfigPaths This will make the script less reliant on the user's setup, but REQUIRES 
            ;UseRelativeConfigPaths that the r-script is located in the same folder as the configuration file.
            ;UseRelativeConfigPaths The configuration file must still remain at the top of the folder structure
            ;UseRelativeConfigPaths which contains all input data files.
            ;UseRelativeConfigPaths which contains all input data files.
            ;UseRelativeConfigPaths NOTE: The source-function loading the 'GFA_Evaluation.R'-script must be an absolute path.
            ;UseRelativeConfigPaths Default: 0
            INI_Encoding=UTF-16
            ;INI_Encoding Type: DropDown UTF-8|UTF-16||UTF-8-RAW
            ;INI_Encoding Select which encoding to use when generating the configuration-files for the R-Script.
            ;INI_Encoding 
            ;INI_Encoding MODIFYING FILE-ENCODINGS IS NOT TRIVIAL, and it is not recommended to change this setting unless you absolutely must.
            ;INI_Encoding 
            ;INI_Encoding 
            ;INI_Encoding You should KNOW WHAT YOU ARE DOING, and absolutely make a backup of any config-file you want to edit after changing encodings.
            ;INI_Encoding Note that 'UTF-8' specifically is 'UTF-8 with BOM', whereas 'UTF-8-RAW' is a BOM-less UTF-8-encoding. 
            ;INI_Encoding 
            ;INI_Encoding Default: UTF-16
            Custom_R_Script_Template=
            ;Custom_R_Script_Template Type: File
            ;Custom_R_Script_Template Default: <.R-File>
            ;Custom_R_Script_Template You can use a custom RCode template, instead of the default one given by this script. 
            ;Custom_R_Script_Template Once selected, the script will try to load it in, but may discard it and use its own if either of the following is true:
            ;Custom_R_Script_Template - the file the path points towards does not exist
            ;Custom_R_Script_Template - certain keywords are not present in the file
            ;Custom_R_Script_Template - %A_Tab% {GFA_EVALUATIONUTILITY}
            ;Custom_R_Script_Template - %A_Tab% {GFA_CONFIGLOCATIONFOLDER_WINDOWS}
            ;Custom_R_Script_Template - %A_Tab% {GFA_CONFIGLOCATIONFOLDER_MAC}
            ;Custom_R_Script_Template As a rule of thumb, your template should not change this default portion of it. 
            ;Custom_R_Script_Template You may add additional lines above or below.
            ;Custom_R_Script_Template Be aware that clearing the workspace after the lines sourcing 'GFA_Evaluation.R' will cause the script to fail.
            CheckUpdatesOnScriptStart=1
            ;CheckUpdatesOnScriptStart Type: Checkbox
            ;CheckUpdatesOnScriptStart CheckboxName: Do you want to always check for updates when running the program?
            ;CheckUpdatesOnScriptStart Default:1
            UpdateChannel=stable
            ;UpdateChannel Do you want to check for updates to the stable release, or keep up to date with the development-version?
            ;UpdateChannel Type: DropDown development||stable
            ;UpdateChannel Default: stable
            ;UpdateChannel 
            [GFA_Renamer_settings]

            filetype=jpg
            ;filetype Type: DropDown png||jpg
            ;filetype Set the image filetype that the Image-renamer considers.
            ;filetype You cannot choose multiple filetypes at once
            ;filetype Default: JPG

            PutFilesOnClipboard=1
            ;PutFilesOnClipboard Type: Checkbox
            ;PutFilesOnClipboard CheckboxName: Put renamed files onto the clipboard?
            ;PutFilesOnClipboard This allows you to f.e. directly paste them onto a stick so you can transfer them for analysis.
            ;PutFilesOnClipboard Default: 1

            CopyFiles=1
            ;CopyFiles Type: Checkbox
            ;CopyFiles CheckboxName: copy Files to the clipboard instead of cutting them?
            ;CopyFiles If you want to copy ("Ctrl+C") the resulting files, set this to 1. If you want to cut them ("Ctrl+X"), set this to 0.
            ;CopyFiles This has no effect if you set 'PutFilesOnClipboard' to 0.
            ;CopyFiles Default: 1

            CopyParentDirectory=1
            ;CopyParentDirectory Type: Checkbox
            ;CopyParentDirectory CheckboxName: Put the parent directory containing the resulting files on the clipboard instead?
            ;CopyParentDirectory This makes it easier to copy the images to a stick all-together because you do not need to create a folder for them first
            ;CopyParentDirectory Default: 1
            [TestSet]
            ;TestSet Hidden:
            ; only edit this if you know what you are doing.
            ;; The URL below points to the newest version of the gist. If this may ever change in a way you do not want, you can replace it with
            ; "https://gist.github.com/Gewerd-Strauss/d944d8abc295253ced401493edd377f2/archive/0d46c65c3993b1e8eef113776b68190e0802deb5.zip"
            ; to grab the first set that was published for this.
            URL=https://gist.github.com/Gewerd-Strauss/d944d8abc295253ced401493edd377f2/archive/main.zip
            Names= G14,G21,G28,G35,G42,UU
            PlantsPerGroup= 7
            [LastConfigsHistory]
            ;LastConfigsHistory Hidden:
            1=%A_ScriptDir%\res\Examples\Example 1 - keine Behandlung\GFA_conf.ini
            2=%A_ScriptDir%\res\Examples\Example 2 - 1 Behandlung\Beispiel-Konfiguration für Veersuch mit Behandlung.ini
            3=%A_ScriptDir%\res\Examples\Example 3 - Analog zum Tomaten-Verlauf\GFA_Evaluation_Example\Beispiel-Konfiguration für Veersuch mit Behandlung.ini
            4=%A_ScriptDir%\res\Examples\Example 4 - Establishment Drought Stress in Cornetto Exp2.1\GFA_conf.ini
            5=%A_ScriptDir%\res\Examples\Example 5 - Refinement Drought Stress in Cornetto Exp2.3\GFA_conf.ini
            [LastRScriptHistory]
            ;LastRScriptHistory Hidden:
            1=%A_ScriptDir%\res\Examples\Example 1 - keine Behandlung\EX1 RScript.R
            2=%A_ScriptDir%\res\Examples\Example 2 - 1 Behandlung\EX2 RScript.R
            3=%A_ScriptDir%\res\Examples\Example 3 - Analog zum Tomaten-Verlauf\GFA_Evaluation_Example\EX3 RScript.R
            4=%A_ScriptDir%\res\Examples\Example 4 - Establishment Drought Stress in Cornetto Exp2.1\EX4 RScript.R
            5=%A_ScriptDir%\res\Examples\Example 5 - Refinement Drought Stress in Cornetto Exp2.3\EX5 RScript.R
        )
    gfcGUIconfig=
        (LTRIM
            Experiment::blank
            %A_Tab%;; 1. Grouping
            %A_Tab%PotsPerGroup:Edit|Type:Integer|Default:7|String:"Set the number of pots per group/combination"|TTIP:[Facet2D==TRUE]\nHere, combination is a combination of a member of 'UniqueGroups' and a member of 'Facet2DVar'|ctrlOptions:number|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%UniqueGroups:Edit|Type:String|Default:""|String:"Set the comma-separated list of all unique group names, AS ORDERED IN THE DATA-FILES"|TTIP:It is required to ensure that groups are located at the same indeces across all data files.\n\nIf you set 'Facet2D' to TRUE, this must have as many entries as 'Facet2DVar'|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%GroupsOrderX:Edit|Type:String|Default:""|String:"Set the comma-separated order of groups in the plots along X-axis"|TTIP:Order the Groups along the X-Axis. Groups are ordered left to right|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%GroupsOrderY:Edit|Type:String|Default:""|String:"Set the comma-separated order of groups in the plots along Y-Axis (only for facetting)"|TTIP:[Facet2D==TRUE]\nOrder the Groups along the Y-Axis. Groups are ordered top to bottom.|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%RefGroup:Edit|Type:String|Default:""|String:"Set the reference group for all statistical tests"|TTIP:\n[Facet2D==FALSE]\nFor a normal plot, this must be a member of 'UniqueGroups'\n\n[Facet2D==TRUE]\nFor a facetted plot, this must be a combination of 1 member of 'Facet2DVar' and 'UniqueGroups', separated by a dot (.).\nThe order is always '[UniqueGroups_Member].[Facet2DVar_Member]'\nExample:\n'Ungestresst.Unbehandelt'|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Facet2D:Checkbox|Type:boolean|Default:0|String:"Do you want to facet the plot, f.e. over a treatment?"|TTIP:Clarification: Facetting here refers to the segmentation of the plots along the Y-Axis, NOT along the X-Axis.\nFor segmenting along the X-Axis, refer to 'UniqueGroups' and 'GroupsOrderX'.|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Facet2DVar:Edit|Type:String|Default:""|String:"Set the comma-separated list of facet-members to assing to the 'UniqueGroups'"|TTIP:[Facet2D==TRUE]\nClarification: The entries you specified for 'UniqueGroups' must each match a single entry in this list as well|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;
            %A_Tab%Palette_Boxplot:Edit|Type:String|Default:"yellow","orange","orangered","red","darkred","black","white"|String:Set the colors for the Summaryplot|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the overview plot|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%Palette_Lines:Edit|Type:String|Default:"yellow","orange","orangered","red","darkred","black","black"|String:Set the colors for the Summaryplot|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the overview plot|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%Palette_Boxplot2:Edit|Type:String|Default:"white","yellow","orange","orangered","red","darkred","black"|String:Set the colors for the daily plots|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the daily plots|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%Palette_Lines2:Edit|Type:String|Default:"black","yellow","orange","orangered","red","darkred","black"|String:Set the colors for the daily plots|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the daily plots|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;
            %A_Tab%;; 2. General Configuration
            %A_Tab%T0:DateTime|Type:String|Default:{A_Now}|String:"Set the T0-date for calculating 'plant-age' for your experiment, in format dd.MM.yyyy (24.12.2023)"|TTIP:This is relevant mostly for calculating the plant-age plotted on the y-axis.|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Normalise:Checkbox|Type:boolean|Default:1|String:"Do you want to normalise your leaf area?"|TTIP:This accesses the data-column 'plant_area_normalised'. For more info, check the documentation.|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%language:DDL|Type:String|Default:"English"|String:"Select language for auto-generated labels"|ctrlOptions:English,German|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%used_filesuffix:DDL|Type:String|Default:"xlsx"|String:"Select the filetype you want to ingest"|ctrlOptions:xlsx,csv|TTIP:'xlsx' is recommended. 'csv' was tested, but not as adamantly as xlsx. It should not make any difference, but that is not guaranteed.|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Filename_Prefix:Edit|Type:String|Default:"GF"|TTIP:Decide the file-prefix used when saving figures and statistical results.\n\nATTENTION:\nChanging this if files have been generated before will result in those files not\nbeing overwritten so you will end up with an old and a current set of result-\nfiles (images/excel-sheets/RData-files)|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%filename_date_format:Combobox|Type:String|Default:"`%Y-`%m-`%d"|String:"Select the date format for saved files. Editing allowed"|TTIP:Does not control the date format on the figure. For that, see option 'figure_date_format'.|ctrlOptions:r5,`%d.`%m.`%Y,`%Y-`%m-`%d|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Debug:Checkbox|Type:boolean|Default:0|String:"Do you want to print debug information?"|Tab3Parent:2. GeneralConfiguration|Link:Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}f|Linktext:?|ConfigSection:General
            %A_Tab%used_plant_area:Combobox|Type:String|Default:"plant_area"|String:"Select the name of the column which contains the area you are trying to plot. Editing allowed"|TTIP:Examples:\n- 'plant_area'\n- 'plant_area_green'\n- 'plant_area_complete'\n- 'plant_area_drought'.|ctrlOptions:plant_area,plant_area_green,plant_area_complete,plant_area_drought|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;; figure
            %A_Tab%Name:Edit|Type:String|Default:"Experiment X"|String:"Set the name of the Experiment as seen in the figure title"|Tab3Parent:3. Figure|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%PlotMeanLine:Checkbox|Type:boolean|Default:1|String:"Do you want to plot the line connecting the means of each group's boxplots?"|Tab3Parent:3. Figure|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Theme:Edit|Type:Integer|Default:7|String:"Choose your default theme."|Max:99|Min:1|ctrlOptions:Number|Tab3Parent:3. Figure|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
        )
    gfcGUIconfig2=
        (LTRIM
            %A_Tab%;;; axes
            %A_Tab%RelativeColnames:Checkbox|Type:boolean|Default:1|String:"Do you want to display the X-positions as 'days since T0'?"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowBothColnames:Checkbox|Type:boolean|Default:0|String:"Do you want to display the X-positions as 'days since T0 - date'?"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ForceAxes:Checkbox|Type:boolean|Default:0|String:"Do you want to force the Y-Axis scaling? This requires setting 'YLimits'"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%YLimits:Edit|Type:String|Default:"0,150"|String:"Set the minimum and maximum limit for the Y-Axis. Does not take effect if 'ForceAxes' is false. Used for all plots"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%BreakStepSize:Edit|Type:number|Default:25|String:Set the spacing between numbered breaks on the Y-Axis. Requires ForceAxes=T"|ctrlOptions: gcheckDecimalsOnEdit|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%axis_units_x:Edit|Type:String|Default:Tage,days|String:"Set the unit of the X-axis (for the Overview-plot)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%axis_units_y:Edit|Type:String|Default:cm^2,cm^2|String:"Set the unit of the Y-axis (for the Overview-plot)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%axis_units_x_Daily:Edit|Type:String|Default:/,/|String:"Set the unit of the X-axis (for the daily plots)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%axis_units_y_Daily:Edit|Type:String|Default:cm^2,cm^2|String:"Set the unit of the Y-axis (for the daily plots)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%figure_date_format:Combobox|Type:String|Default:"`%d.`%m.`%Y"|String:"Select the date format for dates on the x-axis or in titles. Editing allowed"|TTIP:[RelativeColNames==TRUE]\nDoes not take effect\n\n\n[RelativeColNames==FALSE]\nSet the format for dates on the x-axis\n\nDoes not control the date format for the saved files. For that, see option 'filename_date_format'.|ctrlOptions:`%d.`%m.`%Y,`%Y-`%m-`%d|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%XLabel:Edit|Type:String|Default:"Time since repotting"|String:"Set the xlabel-string for the summary plot."|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%XLabel_Daily:Edit|Type:String|Default:"Treatment Groups"|String:"Set the xlabel-string for the daily analyses."|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%YLabel:Edit|Type:String|Default:"green plant area"|String:"Set the ylabel-string for the summary plot and daily analyses."|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;
            %A_Tab%;;; Statistics on Plot
            %A_Tab%ShowNAtallboxplots:Checkbox|Type:boolean|Default:0|String:"Do you want to print 'n=XX' above every boxplot in the daily plots?"|TTIP:[ShowNAtallboxplot==TRUE]:\nThe Sample size is printed above every day.\nThis is generally not recommended as it will become cluttered with increasing number of days.\n\n[ShowNAtallboxplot==FALSE]\nDo not print sample sizes above every day. Sample size is displayed via the plot_subtitle element instead (but only if you enable rr)|Tab3Parent:5. Statistics and its displaying|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%PlotSampleSize:Checkbox|Type:boolean|Default:1|String:"Do you want to plot the sample size of each group's boxplots?"|Tab3Parent:5. Statistics and its displaying|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowOnlyIrregularN:Checkbox|Type:boolean|Default:1|String:"Do you want to only plot sample sizes which differ from 'PotsPerGroup'?|TTIP:Requires also ticking 'PlotSampleSize'|Tab3Parent:5. Statistics and its displaying|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%;;
            %A_Tab%;;; Fontsizes
            %A_Tab%Fontsize_General:Edit|Type:number|Default:10.0|String:"Set the general fontsize text elements on all plots."|TTIP:Default is 10.0. Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_XAxisLabel:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis names/titles"|TTIP:That is, the dates/plant ages.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_YAxisLabel:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis names/titles"|TTIP:That is, plant area values, '25','50','75',...\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_XAxisTicks:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis ticks"|TTIP:That is, the numerical/date-scaling on the x-axis.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_YAxisTicks:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis ticks"|TTIP:That is, the numerical scaling on the y-axis.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_LegendText:Edit|Type:number|Default:10.0|String:"Set the fontsize for the legend entries"|TTIP:That is, the group names in the legend itself.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_LegendTitle:Edit|Type:number|Default:10.0|String:"Set the fontsize for the legend title"|TTIP:That is, the 'title' of the legend.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_PValue:Edit|Type:number|Default:2.5|String:"Set the fontsize for the p-values in the daily plots"|TTIP:Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_SampleSize:Edit|Type:number|Default:2.5|String:"Set the fontsize for the sample size in the daily plots"|TTIP:Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%;;
            %A_Tab%;;; Titles
            %A_Tab%DebugText:Text|Type:text|Default:"Setting [DEBUG==TRUE]" in section '2. General Configuration' will overwrite any settings made in this section"|String:"Setting [DEBUG==TRUE]" in section '2. General Configuration' will overwrite any settings made in this section"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitle:Checkbox|Type:boolean|Default:0|String:"Do you want to show the title above the summary plot?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitleSub:Checkbox|Type:boolean|Default:0|String:"Do you want to show the sub-title above the summary plot?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitle_Daily:Checkbox|Type:boolean|Default:0|String:"Do you want to show the title above the daily plots?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitleSub_Daily:Checkbox|Type:boolean|Default:0|String:"Do you want to show the sub-title above the daily plots?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitleDateWhere:DDL|Type:String|Default:"SubTitle"|String:"Select if the date (range) should be appended to the end of the title- or subtitle-element.|TTIP:For date-format, see key 'figure_date_format' under section '4. Axes'\n\n[ShowTitle==FALSE]\nNo effect.|ctrlOptions:Title,SubTitle,nowhere|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Title:Edit|Type:String|Default:""|String:"Enter the title you want to use for the summary plot. Leave empty to use the default title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Title_Daily:Edit|Type:String|Default:""|String:"Enter the title you want to use for the daily plots. Leave empty to use the default title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%TitleSub:Edit|Type:String|Default:""|String:"Enter the sub-title you want to use for the summary plot. Leave empty to use the default sub-title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%TitleSub_Daily:Edit|Type:String|Default:""|String:"Enter the sub-title you want to use for the daily plots. Leave empty to use the default sub-title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhereA'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General

        )
    gfcGUIconfig.="`n" gfcGUIconfig2
    if (Switch=1) {
        if (!FileExist(script.scriptconfigfile) || globalLogicSwitches.DEBUG ) {
            SplitPath % script.scriptconfigfile,,configDirectory
            if (!FileExist(configDirectory)) {
                FileCreateDir % configDirectory
            }
            DefaultConfig:=DerefAHKVariables(DefaultConfig)
            writeFile(script.scriptconfigfile,DefaultConfig,"UTF-16",,true)
            return
        }
    } else if (Switch=2) {
        if (!FileExist(script.gfcGUIconfigfile) || globalLogicSwitches.DEBUG ) {
            SplitPath % script.gfcGUIconfigfile,,configDirectory
            if (!FileExist(configDirectory)) {
                FileCreateDir % configDirectory
            }
            gfcGUIconfig:=LTrim(gfcGUIconfig)
                , gfcGUIconfig:=DerefAHKVariables(gfcGUIconfig)
            writeFile(script.gfcGUIconfigfile,gfcGUIconfig,"UTF-16",,true)
            return
        }
    }
    return
}



;#############   Edit ini file settings in a GUI   #############################
;  A function that can be used to edit settings in an ini file within it's own
;  GUI. Just plug this function into your script.
;
;  by Rajat, mod by toralf
;  www.autohotkey.com/forum/viewtopic.php?p=69534#69534
;
;   Tested OS: Windows XP Pro SP2
;   AHK_version= 1.0.44.09     ;(http://www.autohotkey.com/download/)
;   Language: English
;   Date: 2006-08-23
;
;   Version: 6
;
; changes since 5:
; - add key type "checkbox" with custom control name
; - added key field options (will only apply in Editor window)
; - whole sections can be set hidden
; - reorganized code in Editor and Creator
; - some fixes and adjustments
; changes since 1.4
; - Creator and Editor GUIs are resizeable (thanks Titan). The shortened Anchor function
;    is added with a long name, to avoid nameing conflicts and avoid dependencies.
; - switched from 1.x version numbers to full integer version numbers
; - requires AHK version 1.0.44.09
; - fixed blinking of description field
; changes since 1.3:
; - added field option "Hidden" (thanks jballi)
; - simplified array naming
; - shorted the code
; changes since 1.2:
; - fixed a bug in the description (thanks jaballi and robiandi)
; changes since 1.1:
; - added statusbar (thanks rajat)
; - fixed a bug in Folder browsing
; changes since 1.0:
; - added default value (thanks rajat)
; - fixed error with DisableGui=1 but OwnedBy=0 (thanks kerry)
; - fixed some typos
;  
; format:
; =======
;   IniSettingsEditor(ProgName, IniFile[, OwnedBy = 0, DisableGui = 0])
;
; with
;   ProgName - A string used in the GUI as text to describe the program 
;   IniFile - that ini file name (with path if not in script directory)
;   OwnedBy - GUI ID of the calling GUI, will make the settings GUI owned
;   DisableGui - 1=disables calling GUI during editing of settings
;
; example to call in script:
;   IniSettingsEditor("Hello World", "Settings.ini", 0, 0)
;
; Include function with:
;   #Include Func_IniSettingsEditor_v6.ahk
;
; No global variables needed.
;
; features:
; =========
; - the calling script will wait for the function to end, thus till the settings
;     GUI gets closed. 
; - Gui ID for the settings GUI is not hard coded, first free ID will be used 
; - multiple description lines (comments) for each key and section possible 
; - all characters are allowed in section and key names
; - when settings GUI is started first key in first section is pre-selected and
;     first section is expanded
; - tree branches expand when items get selected and collapse when items get
;     unselected
; - key types besides the default "Text" are supported 
;    + "File" and "Folder", will have a browse button and its functionality 
;    + "Float" and "Integer" with consistency check 
;    + "Hotkey" with its own hotkey control 
;    + "DateTime" with its own datetime control and custom format, default is
;        "dddd MMMM d, yyyy HH:mm:ss tt"
;    + "DropDown" with its own dropdown control, list of choices has to be given
;        list is pipe "|" separated 
;    + "Checkbox" where the name of the checkbox can be customized
; - default value can be specified for each key 
; - keys can be set invisible (hidden) in the tree
; - to each key control additional AHK specific options can be assigned  
;
; format of ini file:
; ===================
;     (optional) descriptions: to help the script's users to work with the settings 
;     add a description line to the ini file following the relevant 'key' or 'section'
;     line, put a semi-colon (starts comment), then the name of the key or section
;     just above it and a space, followed by any descriptive helpful comment you'd
;     like users to see while editing that field. 
;     
;     e.g.
;     [SomeSection]
;     ;somesection This can describe the section. 
;     Somekey=SomeValue 
;     ;somekey Now the descriptive comment can explain this item. 
;     ;somekey More then one line can be used. As many as you like.
;     ;somekey [Type: key type] [format/list] 
;     ;somekey [Default: default key value] 
;     ;somekey [Hidden:] 
;     ;somekey [Options: AHK options that apply to the control] 
;     ;somekey [CheckboxName: Name of the checkbox control] 
;     
;     (optional) key types: To limit the choice and get correct input a key type can
;     be set or each key. Identical to the description start an extra line put a
;     semi-colon (starts comment), then the name of the key with a space, then the
;     string "Type:" with a space followed by the key type. See the above feature
;     list for available key types. Some key types have custom formats or lists,
;     they are written after the key type with a space in-between.
;     
;     (optional) default key value: To allow a easy and quick way back to a 
;     default value, you can specify a value as default. If no default is given,
;     users can go back to the initial key value of that editing session.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Default:" with a space followed by the default value.
;
;     (optional) hide key in tree: To hide a key from the user, a key can be set 
;     hidden.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Hidden:".
;
;     (optional) add additional AHK options to key controls. To limit the input
;     or enforce a special input into the key controls in the GUI, additional 
;     AHK options can be specified for each control.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Options" with a space followed by a list of AHK options for that
;     AHK control (all separated with a space).
;
;     (optional) custom checkbox name: To have a more relavant name then e.g.
;     "status" a custom name for the checkbox key type can be specified.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "CheckboxName:" with a space followed by the name of the checkbox.
;
;
; limitations:
; ============
; - ini file has to exist and created manually or with the IniFileCreator script
; - section lines have to start with [ and end with ]. No comments allowed on
;     same line
; - ini file must only contain settings. Scripts can't be used to store setting,
;     since the file is read and interpret as a whole. 
; - code: can't use g-labels for tree or edit fields, since the arrays are not
;     visible outside the function, hence inside the g-label subroutines. 
; - code: can't make GUI resizable, since this is only possible with hard
;     coded GUI ID, due to %GuiID%GuiSize label

;@ahk-neko-ignore 1 line; Function too big
ACS_IniSettingsEditor(ProgName,IniFile,OwnedBy = 0,DisableGui = 0, ShowHidden = 0) {
    static Pos
    global bSettingsChanged:=false
    ;Find a GUI ID that does not exist yet 
    Loop, 99 { 
        Gui %A_Index%:+LastFoundExist
        If !WinExist() { 
            SettingsGuiID := A_Index
            break 
        }Else If (A_Index = 99){ 
            MsgBox 4112, Error in IniSettingsEditor function, Can't open settings dialog,`nsince no GUI ID was available.
            Return 0   
        } 
    } 
    Gui %SettingsGuiID%:Default

    ;apply options to settings GUI 
    If OwnedBy { 
        Gui +ToolWindow +Owner%OwnedBy%
        If DisableGui 
            Gui %OwnedBy%:+Disabled
    }Else
        DisableGui := False 

    Gui +Resize +LabelGuiIniSettingsEditor
    vCheckOldSizes:=0
    ;create GUI (order of the two edit controls is crucial, since ClassNN is order dependent) 
    if vCheckOldSizes
    {
        ;; OLD VERSION - more compact. I prefer a bigger gui when editing, as I often have much longer variable names and texts
        Gui Add, Statusbar
        Gui Add, TreeView, x16 y75 w180 h242 0x400
        Gui Add, Edit, x215 y114 w340 h20,                           ;ahk_class Edit1
        Gui Add, Edit, x215 y174 w340 h100 ReadOnly,                 ;ahk_class Edit2
        Gui Add, Button, x250 y335 w70 h30 gExitSettings , E&xit     ;ahk_class Button1
        Gui Add, Button, x505 y88 gBtnBrowseKeyValue Hidden, B&rowse ;ahk_class Button2
        Gui Add, Button, x215 y274 gBtnDefaultValue, &Restore        ;ahk_class Button3
        Gui Add, DateTime, x215 y114 w340 h20 Hidden,                ;ahk_class SysDateTimePick321
        Gui Add, Hotkey, x215 y114 w340 h20 Hidden,                  ;ahk_class msctls_hotkey321
        Gui Add, DropDownList, x215 y114 w340 h120 Hidden,           ;ahk_class ComboBox1
        Gui Add, CheckBox, x215 y114 w340 h20 Hidden,                ;ahk_class Button4
        Gui Add, GroupBox, x4 y63 w560 h263 ,                        ;ahk_class Button5
        Gui Font, Bold
        Gui Add, Text, x215 y93, Value                               ;ahk_class Static1
        Gui Add, Text, x215 y154, Description                        ;ahk_class Static2
        Gui Add, Text, x45 y48 w480 h20 +Center, ( All changes are Auto-Saved )
        Gui Font, S16 CDefault Bold, Verdana
        Gui Add, Text, x45 y13 w600 h25 +Center, Settings for %ProgName%

    }
    Else
    {
        Gui Add, Statusbar
        Gui Add, TreeView, x16 y75 w320 h484 0x400                                                       ; w180 h284 â†’ w+140, h+242
        ; Gui, Add, Edit, x360 y114 w340 h20,                           ;ahk_class Edit1
        Gui Add, Edit, x360 y114 w340 h20,                           ;ahk_class Edit1
        Gui Add, Edit, x360 y174 w340 h355 ReadOnly,                 ;ahk_class Edit2
        Gui Add, Button, x390 y533 w70 h30 gExitSettings , E&xit     ;ahk_class Button1
        Gui Add, Button, x505 y88 gBtnBrowseKeyValue Hidden, B&rowse ;ahk_class Button2
        Gui Add, Button, x505 y533 w70 h30 gBtnDefaultValue, &Restore        ;ahk_class Button3
        Gui Add, DateTime, x360 y114 w340 h20 Hidden,                ;ahk_class SysDateTimePick321
        Gui Add, Hotkey, x360 y114 w340 h20 Hidden,                  ;ahk_class msctls_hotkey321
        Gui Add, DropDownList, x360 y114 w340 h120 Hidden,           ;ahk_class ComboBox1
        Gui Add, CheckBox, x360 y114 w340 h20 Hidden,                ;ahk_class Button4
        Gui Add, GroupBox, x4 y63 w712 h504 ,                        ;ahk_class Button5
        Gui Font, Bold
        Gui Add, Text, x360 y93, Value                               ;ahk_class Static1
        Gui Add, Text, x360 y154, Description                        ;ahk_class Static2
        Gui Add, Text, x45 y48 w480 h20 +Center, ( All changes are Auto-Saved )
        Gui Font, S16 CDefault Bold, Verdana
        Gui Add, Text, x45 y13 w600 h25 +Center, Settings for %ProgName%

    }



    ;read data from ini file, build tree and store values and description in arrays 
    Loop, Read, %IniFile% 
    { 
        CurrLine := A_LoopReadLine
        CurrLineLength := StrLen(CurrLine) 

        ;blank line 
        If CurrLine is space 
            Continue 

        ;description (comment) line 
        If ( InStr(CurrLine,";") = 1 ){
            StringLeft chk2, CurrLine, % CurrLength + 2
            StringTrimLeft Des, CurrLine, % CurrLength + 2 ; create the description.
            ;description of key
            If ( %CurrID%Sec = False AND ";" CurrKey A_Space = chk2){ 
                ;handle key types  
                If ( InStr(Des,"Type: ") = 1 ){ 
                    StringTrimLeft Typ, Des, 6
                    Typ := Typ
                    Des := "`n" Des     ;add an extra line to the type definition in the description control

                    ;handle format or list  
                    If (InStr(Typ,"DropDown ") = 1) {
                        StringTrimLeft Format, Typ, 9
                        %CurrID%For := Format
                        Typ := "DropDown"
                        Des := ""
                    }Else If (InStr(Typ,"DateTime") = 1) {
                        StringTrimLeft Format, Typ, 9
                        If Format is space
                            Format := "dddd MMMM d, yyyy HH:mm:ss tt" 
                        %CurrID%For := Format
                        Typ := "DateTime"
                        Des := ""
                    }
                    ;set type
                    %CurrID%Typ := Typ 
                    ;remember default value
                }Else If ( InStr(Des,"Default: ") = 1 ){ 
                    StringTrimLeft Def, Des, 9
                    %CurrID%Def := Def
                    ;remember custom options  
                }Else If ( InStr(Des,"Options: ") = 1 ){ 
                    StringTrimLeft Opt, Des, 9
                    %CurrID%Opt := Opt
                    Des := ""
                    ;remove hidden keys from tree
                }Else If ( InStr(Des,"Hidden:") = 1 ) and (!ShowHidden){   ; allow override of invisible keys/sections if variable is specified - such as a developer wanting to edit hidden variables easier.
                    TV_Delete(CurrID)
                    Des := ""
                    CurrID := ""
                    ;handle checkbox name
                }Else If ( InStr(Des,"CheckboxName: ") = 1 ){  
                    StringTrimLeft ChkN, Des, 14
                    %CurrID%ChkN := ChkN
                    Des := ""
                } 
                %CurrID%Des := %CurrID%Des "`n" Des 
                ;; testing code
                ; d:=%CurrID%Des
                ; tooltip, % d
                ;; testing code end - remove at end.
                ;description of section 
            } Else If ( %CurrID%Sec = True AND ";" CurrSec A_Space = chk2 ){
                ;remove hidden section from tree
                If ( InStr(Des,"Hidden:") = 1 ) and (!ShowHidden) {  
                    TV_Delete(CurrID)
                    Des := ""
                    CurrSecID := ""
                }
                ;set description
                %CurrID%Des := %CurrID%Des "`n" Des 
            } 
            ;remove leading and trailing whitespaces and new lines
            If ( InStr(%CurrID%Des, "`n") = 1 )
                StringTrimLeft %CurrID%Des, %CurrID%Des, 1
            Continue 
        } 

        ;section line 
        If ( InStr(CurrLine, "[") = 1 And InStr(CurrLine, "]", "", 0) = CurrLineLength) { 
            ;extract section name
            StringTrimLeft CurrSec, CurrLine, 1
            StringTrimRight CurrSec, CurrSec, 1
            CurrSec := CurrSec
            CurrLength := StrLen(CurrSec)  ;to easily trim name off of following comment lines

            ;add to tree
            CurrSecID := TV_Add(CurrSec)
            CurrID := CurrSecID
            %CurrID%Sec := True
            CurrKey := ""
            Continue 
        } 

        ;key line 
        Pos := InStr(CurrLine,"=") 
        If ( Pos AND CurrSecID ){ 
            ;extract key name and its value
            StringLeft CurrKey, CurrLine, % Pos - 1
            StringTrimLeft CurrVal, CurrLine, %Pos%
            CurrKey := CurrKey             ;remove whitespace
            CurrVal := CurrVal
            CurrLength := StrLen(CurrKey)

            ;add to tree and store value
            CurrID := TV_Add(CurrKey,CurrSecID) 
            %CurrID%Val := CurrVal
            %CurrID%Sec := False

            ;store initial value as default for restore function
            ;will be overwritten if default is specified later on comment line
            %CurrID%Def := CurrVal 
        } 
    } 

    ;select first key of first section and expand section
    TV_Modify(TV_GetChild(TV_GetNext()), "Select")

    ;show Gui and get UniqueID
    ; Gui, Show, w570 h400, %ProgName% Settings 
    Gui Show,, %ProgName% Settings
    Gui +LastFound
    GuiID := WinExist() 

    ;check for changes in GUI 
    Loop { 
        ;get current tree selection 
        CurrID := TV_GetSelection() 

        If SetDefault { 
            %CurrID%Val := %CurrID%Def 
            LastID := 0
            SetDefault := False
            SetDefault_Checkbox:=true
            ValChanged := True
        } 

        MouseGetPos,,, AWinID, ACtrl
        If ( AWinID = GuiID){ 
            If ( ACtrl = "Button3")  
                SB_SetText("Restores Value to default (if specified), else restores it to initial value before change")
        } Else 
            SB_SetText("") 

        ;change GUI content if tree selection changed 
        If (CurrID <> LastID) {
            ;remove custom options from last control
            Loop, Parse, InvertedOptions, %A_Space%
                GuiControl %A_Loopfield%, %ControlUsed%

            ;hide/show browse button depending on key type
            Typ := %CurrID%Typ 
            If Typ in File,Folder 
                GuiControl Show , Button2,
            Else 
                GuiControl Hide , Button2,

            ;set the needed value control depending on key type
            If (Typ = "DateTime")
                ControlUsed := "SysDateTimePick321"
            Else If ( Typ = "Hotkey" )
                ControlUsed := "msctls_hotkey321"
            Else If ( Typ = "DropDown")
                ControlUsed := "ComboBox1"
            Else If ( Typ = "CheckBox")
                ControlUsed := "Button4"
            Else                    ;e.g. Text,File,Folder,Float,Integer or No Tyo (e.g. Section) 
                ControlUsed := "Edit1"

            ;hide/show the value controls
            Controls := "SysDateTimePick321,msctls_hotkey321,ComboBox1,Button4,Edit1"
            Loop, Parse, Controls, `,
                If ( ControlUsed = A_LoopField )
                    GuiControl Show , %A_LoopField%,
            Else
                GuiControl Hide , %A_LoopField%,

            If ( ControlUsed = "Button4" )
                GuiControl,  , Button4, % %CurrID%ChkN

            ;get current options
            CurrOpt := %CurrID%Opt
            ;apply current custom options to current control and memorize them inverted
            InvertedOptions := ""
            Loop, Parse, CurrOpt, %A_Space%
            {
                ;get actual option name
                StringLeft chk, A_LoopField, 1
                StringTrimLeft chk2, A_LoopField, 1
                If chk In +,-
                {
                    GuiControl %A_LoopField%, %ControlUsed%
                    If (chk = "+")
                        InvertedOptions := InvertedOptions -chk2
                    Else
                        InvertedOptions := InvertedOptions +chk2
                }Else {
                    GuiControl +%A_LoopField%, %ControlUsed%
                    InvertedOptions := InvertedOptions - A_LoopField
                }
            }

            If %CurrID%Sec {                      ;section got selected
                CurrVal := ""
                GuiControl, , Edit1,
                GuiControl Disable , Edit1,
                GuiControl Disable , Button3,
            }Else {                               ;new key got selected
                CurrVal := %CurrID%Val   ;get current value
                GuiControl, , Edit1, %CurrVal%   ;put current value in all value controls
                GuiControl Text, SysDateTimePick321, % %CurrID%For
                GuiControl, , SysDateTimePick321, %CurrVal%
                GuiControl, , msctls_hotkey321, %CurrVal%
                GuiControl, , ComboBox1, % "|" %CurrID%For
                GuiControl ChooseString, ComboBox1, %CurrVal%
                GuiControl, , Button4 ,     ;; Untested Hotfix for the Checkbox not clearing correctly. This means you cannot give anymore direct prompts, but you can use the description-edit field for that instead.
                guicontrol, ,Button4, %CurrVal%
                ; anchor here 
                if (ControlUsed="Button4") ;; Tested Hotfix for the Checkbox string not displaying after using the above hotfix to alway clear it. Allows direct checkbox prompts to be given again, this time without clearing-issues.
                {
                    CurrVal:=%CurrID%ChkN
                    GuiControl, , Button4 , %CurrVal%
                    ; GuiControl,  
                }
                Else
                    GuiControl, , Button4 , %CurrVal%
                GuiControl Enable , Edit1,
                GuiControl Enable , Button3,
                ; GuiControl, Chec

                ;;; There doesn't seem to be code to clear the description out from the previous type 
                ;;; when selecting 'CheckBox' as your next type. 


            } 
            If  !(%CurrID%Sec) 	; normal key was selected
            {                      
                GuiControl, , Edit2, ; clear out the description-field to avoid larger previous texts from "ghosting" behind the new entry.
                GuiControl, , Edit2, % %CurrID%Des
            }
            if (%CurrID%Sec) 	; section got selected
            {
                GuiControl, , Edit2,
                GuiControl, , Edit2, % %CurrID%Des
            }
        }
        LastID := CurrID                   ;remember last selection

        ;sleep to reduce CPU load
        Sleep 100

        ;exit endless loop, when settings GUI closes 
        If !WinExist("ahk_id" GuiID) 
            Break 

        ;if key is selected, get value
        If (%CurrID%Sec = False){
            ; if (%CurrID%Typ!="Checkbox")
            GuiControlGet NewVal, , %ControlUsed%  ; get the new value from the recent input
            ;save key value when it has been changed 
            If ( NewVal <> CurrVal OR ValChanged ) {
                ValChanged := False
                if (Typ= "Checkbox")
                {
                    ;  d:=%CurrID%Val
                    ; GuiControl, , Edit1, %NewVal%
                    ; guicontrol, ,Button4, %d%
                    if SetDefault_Checkbox
                    {
                        SetDefault_Checkbox:= !SetDefault_Checkbox
                        RestoredVal:=%CurrID%Def ;;; this is a functional hotfix if you want to restore to DEF. Not sure how to implement restoring to previous entry though.
                        guicontrol, ,Button4, %RestoredVal%
                    }
                }
                ; 	GuiControl
                ;consistency check if type is integer or float
                If (Typ = "Integer")
                    If NewVal is not space
                        If NewVal is not Integer
                        {
                            GuiControl, , Edit1, %CurrVal%
                            Continue
                        }
                    If (Typ = "Float")
                        If NewVal is not space
                            If NewVal is not Integer
                                If (NewVal <> ".")
                                    If NewVal is not Float
                                    {
                                        GuiControl, , Edit1, %CurrVal%
                                        Continue
                                    }

                                ;set new value and save it to INI      
                                if (%CurrID%Val!=NewVal)
                                    bSettingsChanged:=true
                %CurrID%Val := NewVal 
                CurrVal := NewVal
                PrntID := TV_GetParent(CurrID)
                TV_GetText(SelSec, PrntID) 
                TV_GetText(SelKey, CurrID) 
                If (SelSec AND SelKey) 
                    IniWrite %NewVal%, %IniFile%, %SelSec%, %SelKey%
            } 
        } 
    } 

    ;Exit button got pressed 
    ExitSettings: 
    ;re-enable calling GUI 
    If DisableGui { 
        Gui %OwnedBy%:-Disabled
        Gui %OwnedBy%:,Show
    } 
    Gui Destroy
    ;exit function 
    Return bSettingsChanged ; inform the script if settings have been changed or not.

    ;browse button got pressed
    BtnBrowseKeyValue: 
    ;get current value
    GuiControlGet StartVal, , Edit1
    Gui +OwnDialogs

    ;Select file or folder depending on key type
    If (Typ = "File"){ 
        ;get StartFolder
        if (FileExist(A_ScriptDir "\" StartVal))
            StartFolder := A_ScriptDir 
        Else if (FileExist(StartVal))
            SplitPath StartVal, , StartFolder
        Else 
            StartFolder := ""

        ;select file
        FileSelectFile Selected,, %StartFolder%, Select file for %SelSec% - %SelKey%, Any file (*.*)
    }Else If (Typ = "Folder"){ 
        ;get StartFolder
        if (FileExist(A_ScriptDir "\" StartVal))
            StartFolder := A_ScriptDir "\" StartVal
        Else if (FileExist(StartVal))
            StartFolder := StartVal
        Else 
            StartFolder := ""

        ;select folder
        FileSelectFolder Selected, *%StartFolder% , 3, Select folder for %SelSec% - %SelKey%

        ;remove last backslash "\" if any
        StringRight LastChar, Selected, 1
        If (LastChar="\") 
            StringTrimRight Selected, Selected, 1
    } 
    ;If file or folder got selected, remove A_ScriptDir (since it's redundant) and set it into GUI
    If Selected { 
        Selected:=StrReplace(Selected,A_ScriptDir "\")
        GuiControl, , Edit1, %Selected%
        %CurrID%Val := Selected 
    } 
    Return  ;end of browse button subroutine

    ;default button got pressed
    BtnDefaultValue: 
    SetDefault := True 
    Return  ;end of default button subroutine

    ;gui got resized, adjust control sizes
    GuiIniSettingsEditorSize:
    GuiIniSettingsEditorAnchor("SysTreeView321"      , "wh") 
    GuiIniSettingsEditorAnchor("Edit1"               , "x")
    GuiIniSettingsEditorAnchor("Edit2"               , "xh")
    GuiIniSettingsEditorAnchor("Button1"             , "xy",true)
    GuiIniSettingsEditorAnchor("Button2"             , "x",true)
    GuiIniSettingsEditorAnchor("Button3"             , "xy",true)
    GuiIniSettingsEditorAnchor("Button4"             , "x",true)
    GuiIniSettingsEditorAnchor("Button5"             , "wh",true)
    GuiIniSettingsEditorAnchor("SysDateTimePick321"  , "x")
    GuiIniSettingsEditorAnchor("msctls_Hotkey321"    , "x")
    GuiIniSettingsEditorAnchor("ComboBox1"           , "x")
    GuiIniSettingsEditorAnchor("Static1"             , "x")
    GuiIniSettingsEditorAnchor("Static2"             , "x")
    GuiIniSettingsEditorAnchor("Static3"             , "x")
    GuiIniSettingsEditorAnchor("Static4"             , "x")
    Return 
}  ;end of function

GuiIniSettingsEditorAnchor(ctrl, a, draw = false) { ; v3.2 by Titan (shortened)
    static pos
    sig := "`n" ctrl "="
    If !InStr(pos, sig) {
        GuiControlGet p, pos, %ctrl%

        pos := pos . sig . pX - A_GuiWidth . "/" . pW  - A_GuiWidth . "/"

            . pY - A_GuiHeight . "/" . pH - A_GuiHeight . "/"
    }

    StringTrimLeft p, pos, InStr(pos, sig) - 1 + StrLen(sig)


    StringSplit p, p, /
    c := "xwyh"
    Loop, Parse, c
        If InStr(a, A_LoopField) {
            If A_Index < 3
                e := p%A_Index% + A_GuiWidth
            Else e := p%A_Index% + A_GuiHeight
            m := m A_LoopField e
        }
    If draw
        d := "Draw"
    GuiControl Move%d%, %ctrl%, %m%
}
/*           ,---,                                          ,--,    
,--.' |                                        ,--.'|    
|  |  :                      .--.         ,--, |  | :    
.--.--.  :  :  :                    .--,`|       ,'_ /| :  : '    
/  /    ' :  |  |,--.  ,--.--.       |  |.   .--. |  | : |  ' |    
|  :  /`./ |  :  '   | /       \      '--`_ ,'_ /| :  . | '  | |    
|  :  ;_   |  |   /' :.--.  .-. |     ,--,'||  ' | |  . . |  | :    
\  \    `.'  :  | | | \__\/: . .     |  | '|  | ' |  | | '  : |__  
`----.   \  |  ' | : ," .--.; |     :  | |:  | : ;  ; | |  | '.'| 
/  /`--'  /  :  :_:,'/  /  ,.  |   __|  : ''  :  `--'   \;  :    ; 
'--'.     /|  | ,'   ;  :   .'   \.'__/\_: |:  ,      .-./|  ,   /  
`--'---' `--''     |  ,     .-./|   :    : `--`----'     ---`-'   
`--`---'     \   \  /                         
`--`-'  
------------------------------------------------------------------
Function: To check if the user has Administrator rights and elevate it if needed by the script
URL: http://www.autohotkey.com/forum/viewtopic.php?t=50448
------------------------------------------------------------------
*/

RunAsAdmin() {
  Loop, %0%  ; For each parameter:
  {
    param := %A_Index%  ; Fetch the contents of the variable whose name is contained in A_Index.
    params .= A_Space . param
  }
  ShellExecute := A_IsUnicode ? "shell32\ShellExecute":"shell32\ShellExecuteA"

  if not A_IsAdmin
  {
    If A_IsCompiled
      DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_ScriptFullPath, str, params , str, A_WorkingDir, int, 1)
    Else
      DllCall(ShellExecute, uint, 0, str, "RunAs", str, A_AhkPath, str, """" . A_ScriptFullPath . """" . A_Space . params, str, A_WorkingDir, int, 1)
    ExitApp
  }
}
; #region:AddToolTip() (2878031207)

; #region:Metadata:
; Snippet: AddToolTip();  (v.1.0)
; --------------------------------------------------------------
; Author: Rseding91
; Source: https://www.autohotkey.com/boards/viewtopic.php?t=2584
; (04.03.2014)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 20 - ToolTips
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: multi-line, gui control, control
; #endregion:Metadata


; #region:Description:
; 	/*                              	DESCRIPTION
; 
; 			 Adds Multi-line ToolTips to any Gui Control
; 			 AHK basic, AHK ANSI, Unicode x86/x64 compatible
; 
; 			 Thanks Superfraggle & Art: http://www.autohotkey.com/forum/viewtopic.php?p=188241
; 			 Heavily modified by Rseding91 3/4/2014:
; 			 Version: 1.0
; 			   * Fixed 64 bit support
; 			   * Fixed multiple GUI support
; 			   * Changed the _Modify parameter
; 					   * blank/0/false:                                	Create/update the tool tip.
; 					   * -1:                                           		Delete the tool tip.
; 					   * any other value:                             Update an existing tool tip - same as blank/0/false
;                                                         						but skips unnecessary work if the tool tip already
;                                                         						exists - silently fails if it doesn't exist.
; 			   * Added clean-up methods:
; 					   * AddToolTip(YourGuiHwnd, "Destroy", -1):       		Cleans up and erases the cached tool tip data created
;                                                                                     					for that GUI. Meant to be used in conjunction with
;                                                                                     					GUI, Destroy.
; 					   * AddToolTip(YourGuiHwnd, "Remove All", -1):	   	Removes all tool tips from every control in the GUI.
;                                                                                     					Has the same effect as "Destroy" but first removes
;                                                                                     					every tool tip from every control. This is only used
;                                                                                     					when you want to remove every tool tip but not destroy
;                                                                                     					the entire GUI afterwords.
; 					   * NOTE: Neither of the above are required if
;                             	your script is closing.
; 
; 			 - 'Text' and 'Picture' Controls requires a g-label to be defined.
; 			 - 'ComboBox' = Drop-Down button + Edit (Get hWnd of the 'Edit'   control using "ControlGet" command).
; 			 - 'ListView' = ListView + Header       (Get hWnd of the 'Header' control using "ControlGet" command).
; 
; 	*/
; #endregion:Description

; #region:Code
AddToolTip(_CtrlHwnd, _TipText, _Modify = 0,GuiHwnd:="") {                                                        			;-- very easy to use function to add a tooltip to a control

    Static TTHwnds := ""
        , GuiHwnds := ""
        , LastGuiHwnd := ""
        , LastTTHwnd := ""
        , TTM_DELTOOLA := 1029
        , TTM_DELTOOLW := 1075
        , TTM_ADDTOOLA := 1028
        , TTM_ADDTOOLW := 1074
        , TTM_UPDATETIPTEXTA := 1036
        , TTM_UPDATETIPTEXTW := 1081
        , TTM_SETMAXTIPWIDTH := 1048
        , WS_POPUP := 0x80000000
        , BS_AUTOCHECKBOX = 0x3
        , CW_USEDEFAULT := 0x80000000
        , Ptr := A_PtrSize ? "Ptr" : "UInt"

    /*                              	NOTE

    This is used to remove all tool tips from a given GUI and to clean up references used
    This can be used if you want to remove every tool tip but not destroy the GUI
    When a GUI is destroyed all Windows tool tip related data is cleaned up.
    The cached Hwnd's in this function will be removed automatically if the caching code
    ever matches them to a new GUI that doesn't actually own the Hwnd's.
    It's still possible that a new GUI could have the same Hwnd as a previously destroyed GUI
    If such an event occurred I have no idea what would happen. Either the tool tip
    To avoid that issue, do either of the following:
    * Don't destroy a GUI once created
    NOTE: You do not need to do the above if you're exiting the script Windows will clean up
    all tool tip related data and the cached Hwnd's in this function are lost when the script
    exits anyway.AtEOF
    */

    If (_TipText = "Destroy" Or _TipText = "Remove All" And _Modify = -1)
    {
        ; Check if the GuiHwnd exists in the cache list of GuiHwnds
        ; If it doesn't exist, no tool tips can exist for the GUI.
        ;
        ; If it does exist, find the cached TTHwnd for removal.
        Loop, Parse, GuiHwnds, |
            If (A_LoopField = _CtrlHwnd)
            {
                TTHwnd := A_Index
                    , TTExists := True
                Loop, Parse, TTHwnds, |
                    If (A_Index = TTHwnd)
                        TTHwnd := A_LoopField
            }

        If (TTExists)
        {
            If (_TipText = "Remove All")
            {
                WinGet ChildHwnds, ControlListHwnd, ahk_id %_CtrlHwnd%

                Loop, Parse, ChildHwnds, `n
                    AddToolTip(A_LoopField, "", _Modify) ;Deletes the individual tooltip for a given control if it has one

                DllCall("DestroyWindow", Ptr, TTHwnd)
            }

            GuiHwnd := _CtrlHwnd
            ; This sub removes 'GuiHwnd' and 'TTHwnd' from the cached list of Hwnds
            GoSub, RemoveCachedHwnd
        }

        Return
    }
    if (GuiHwnd="") {
        If (!GuiHwnd := DllCall("GetParent", Ptr, _CtrlHwnd, Ptr))
            Return "Invalid control Hwnd: """ _CtrlHwnd """. No parent GUI Hwnd found for control."
    }

    ; If this GUI is the same one as the potential previous one
    ; else look through the list of previous GUIs this function
    ; has operated on and find the existing TTHwnd if one exists.
    TTHwnd := 0
    If (GuiHwnd = LastGuiHwnd)
        TTHwnd := LastTTHwnd
    Else
    {
        Loop, Parse, GuiHwnds, |
            If (A_LoopField = GuiHwnd)
            {
                TTHwnd := A_Index
                Loop, Parse, TTHwnds, |
                    If (A_Index = TTHwnd)
                        TTHwnd := A_LoopField
            }
    }

    ; If the TTHwnd isn't owned by the controls parent it's not the correct window handle
    If (TTHwnd And GuiHwnd != DllCall("GetParent", Ptr, TTHwnd, Ptr))
    {
        GoSub, RemoveCachedHwnd
        TTHwnd := ""
    }

    ; Create a new tooltip window for the control's GUI - only one needs to exist per GUI.
    ; The TTHwnd's are cached for re-use in any subsequent calls to this function.
    If (!TTHwnd)
    {
        TTHwnd := DllCall("CreateWindowEx"
            , "UInt", 0                             ;dwExStyle
            , "Str", "TOOLTIPS_CLASS32"             ;lpClassName
            , "UInt", 0                             ;lpWindowName
            , "UInt", WS_POPUP | BS_AUTOCHECKBOX    ;dwStyle
            , "UInt", CW_USEDEFAULT                 ;x
            , "UInt", 0                             ;y
            , "UInt", 0                             ;nWidth
            , "UInt", 0                             ;nHeight
            , "UInt", GuiHwnd                       ;hWndParent
            , "UInt", 0                             ;hMenu
            , "UInt", 0                             ;hInstance
            , "UInt", 0)                            ;lpParam

        ; TTM_SETWINDOWTHEME
        DllCall("uxtheme\SetWindowTheme"
            , Ptr, TTHwnd
            , Ptr, 0
            , Ptr, 0)

        ; Record the TTHwnd and GuiHwnd for re-use in any subsequent calls.
        TTHwnds .= (TTHwnds ? "|" : "") TTHwnd
            , GuiHwnds .= (GuiHwnds ? "|" : "") GuiHwnd
    }

    ; Record the last-used GUIHwnd and TTHwnd for re-use in any immediate future calls.
    LastGuiHwnd := GuiHwnd
        , LastTTHwnd := TTHwnd
    /*
    *TOOLINFO STRUCT*

    UINT        cbSize
    UINT        uFlags
    HWND        hwnd
    UINT_PTR    uId
    RECT        rect
    HINSTANCE   hinst
    LPTSTR      lpszText
    #if (_WIN32_IE >= 0x0300)
    LPARAM    lParam;
    #endif
    #if (_WIN32_WINNT >= Ox0501)
    void      *lpReserved;
    #endif
    */

        , TInfoSize := 4 + 4 + ((A_PtrSize ? A_PtrSize : 4) * 2) + (4 * 4) + ((A_PtrSize ? A_PtrSize : 4) * 4)
        , Offset := 0
        , Varsetcapacity(TInfo, TInfoSize, 0)
        , Numput(TInfoSize, TInfo, Offset, "UInt"), Offset += 4                         ; cbSize
        , Numput(1 | 16, TInfo, Offset, "UInt"), Offset += 4                            ; uFlags
        , Numput(GuiHwnd, TInfo, Offset, Ptr), Offset += A_PtrSize ? A_PtrSize : 4      ; hwnd
        , Numput(_CtrlHwnd, TInfo, Offset, Ptr), Offset += A_PtrSize ? A_PtrSize : 4    ; UINT_PTR
        , Offset += 16                                                                  ; RECT (not a pointer but the entire RECT)
        , Offset += A_PtrSize ? A_PtrSize : 4                                           ; hinst
        , Numput(&_TipText, TInfo, Offset, Ptr)                                         ; lpszText
    ; The _Modify flag can be used to skip unnecessary removal and creation if
    ; the caller follows usage properly but it won't hurt if used incorrectly.
    If (!_Modify Or _Modify = -1)
    {
        If (_Modify = -1)
        {
            ; Removes a tool tip if it exists - silently fails if anything goes wrong.
            DllCall("SendMessage"
                , Ptr, TTHwnd
                , "UInt", A_IsUnicode ? TTM_DELTOOLW : TTM_DELTOOLA
                , Ptr, 0
                , Ptr, &TInfo)

            Return
        }

        ; Adds a tool tip and assigns it to a control.
        DllCall("SendMessage"
            , Ptr, TTHwnd
            , "UInt", A_IsUnicode ? TTM_ADDTOOLW : TTM_ADDTOOLA
            , Ptr, 0
            , Ptr, &TInfo)

        ; Sets the preferred wrap-around width for the tool tip.
        DllCall("SendMessage"
            , Ptr, TTHwnd
            , "UInt", TTM_SETMAXTIPWIDTH
            , Ptr, 0
            , Ptr, A_ScreenWidth)
    }

    ; Sets the text of a tool tip - silently fails if anything goes wrong.
    DllCall("SendMessage"
        , Ptr, TTHwnd
        , "UInt", A_IsUnicode ? TTM_UPDATETIPTEXTW : TTM_UPDATETIPTEXTA
        , Ptr, 0
        , Ptr, &TInfo)

    Return
    RemoveCachedHwnd:
    NewGuiHwnds := NewTTHwnds := ""
    Loop, Parse, GuiHwnds, |
        NewGuiHwnds .= (A_LoopField = GuiHwnd ? "" : ((NewGuiHwnds = "" ? "" : "|") A_LoopField))

    Loop, Parse, TTHwnds, |
        NewTTHwnds .= (A_LoopField = TTHwnd ? "" : ((NewTTHwnds = "" ? "" : "|") A_LoopField))

    GuiHwnds := NewGuiHwnds
        , TTHwnds := NewTTHwnds
        , LastGuiHwnd := ""
        , LastTTHwnd := ""
    Return
}
; #endregion:Code



; #endregion:AddToolTip() (2878031207)
/*
class GC_RichCode({"TabSize": 4     ; Width of a tab in characters
, "Indent": "`t"             ; What text to insert on indent
, "FGColor": 0xRRGGBB        ; Foreground (text) color
, "BGColor": 0xRRGGBB        ; Background color
, "Font"                     ; Font to use
: {"Typeface": "Courier New" ; Name of the typeface
, "Size": 12             ; Font size in points
, "Bold": False}         ; Bolded (True/False)


; Whether to use the highlighter, or leave it as plain text
, "UseHighlighter": True

; Delay after typing before the highlighter is run
, "HighlightDelay": 200

; The highlighter function (FuncObj or name)
; to generate the highlighted RTF. It will be passed
; two parameters, the first being this settings array
; and the second being the code to be highlighted
, "Highlighter": Func("HighlightR")

; The colors to be used by the highlighter function.
; This is currently used only by the highlighter, not at all by the
; GC_RichCode class. As such, the RGB ordering is by convention only.
; You can add as many colors to this array as you want.
, "Colors"
: [0xRRGGBB
, 0xRRGGBB
, 0xRRGGBB,
, 0xRRGGBB]})
*/

class GC_RichCode
{
    static Msftedit := DllCall("LoadLibrary", "Str", "Msftedit.dll")
    static IID_ITextDocument := "{8CC497C0-A1DF-11CE-8098-00AA0047BE5D}"
    static MenuItems := ["Cut", "Copy", "Paste", "Delete", "", "Select All", ""
            , "UPPERCASE", "lowercase", "TitleCase"]

    _Frozen := False

    ; --- Static Methods ---

    BGRFromRGB(RGB)
    {
        return RGB>>16&0xFF | RGB&0xFF00 | RGB<<16&0xFF0000
    }

    ; --- Properties ---

    Value[]
    {
        get {
            GuiControlGet Code,, % this.hWnd
            return Code
        }

        set {
            this.Highlight(Value)
            return Value
        }
    }

    ; TODO: reserve and reuse memory
    Selection[i:=0]
    {
        get {
            VarSetCapacity(CHARRANGE, 8, 0)
            this.SendMsg(0x434, 0, &CHARRANGE) ; EM_EXGETSEL
            Out := [NumGet(CHARRANGE, 0, "Int"), NumGet(CHARRANGE, 4, "Int")]
            return i ? Out[i] : Out
        }

        set {
            if i
                Temp := this.Selection, Temp[i] := Value, Value := Temp
            VarSetCapacity(CHARRANGE, 8, 0)
            NumPut(Value[1], &CHARRANGE, 0, "Int") ; cpMin
            NumPut(Value[2], &CHARRANGE, 4, "Int") ; cpMax
            this.SendMsg(0x437, 0, &CHARRANGE) ; EM_EXSETSEL
            return Value
        }
    }

    SelectedText[]
    {
        get {
            Selection := this.Selection, Length := Selection[2] - Selection[1]
            VarSetCapacity(Buffer, (Length + 1) * 2) ; +1 for null terminator
            if (this.SendMsg(0x43E, 0, &Buffer) > Length) ; EM_GETSELTEXT
                throw Exception("Text larger than selection! Buffer overflow!")
            Text := StrGet(&Buffer, Selection[2]-Selection[1], "UTF-16")
            return StrReplace(Text, "`r", "`n")
        }

        set {
            this.SendMsg(0xC2, 1, &Value) ; EM_REPLACESEL
            this.Selection[1] -= StrLen(Value)
            return Value
        }
    }

    EventMask[]
    {
        get {
            return this._EventMask
        }

        set {
            this._EventMask := Value
            this.SendMsg(0x445, 0, Value) ; EM_SETEVENTMASK
            return Value
        }
    }

    UndoSuspended[]
    {
        get {
            return this._UndoSuspended
        }

        set {
            try ; ITextDocument is not implemented in WINE
            {
                if Value
                    this.ITextDocument.Undo(-9999995) ; tomSuspend
                else
                    this.ITextDocument.Undo(-9999994) ; tomResume
            }
            return this._UndoSuspended := !!Value
        }
    }

    Frozen[]
    {
        get {
            return this._Frozen
        }

        set {
            if (Value && !this._Frozen)
            {
                try ; ITextDocument is not implemented in WINE
                    this.ITextDocument.Freeze()
                catch
                    GuiControl -Redraw, % this.hWnd
            }
            else if (!Value && this._Frozen)
            {
                try ; ITextDocument is not implemented in WINE
                    this.ITextDocument.Unfreeze()
                catch
                    GuiControl +Redraw, % this.hWnd
            }
            return this._Frozen := !!Value
        }
    }

    Modified[]
    {
        get {
            return this.SendMsg(0xB8, 0, 0) ; EM_GETMODIFY
        }

        set {
            this.SendMsg(0xB9, Value, 0) ; EM_SETMODIFY
            return Value
        }
    }

    ; --- Construction, Destruction, Meta-Functions ---

    __New(Settings, Options:="")
    {
        this.Settings := Settings
            , FGColor := this.BGRFromRGB(Settings.FGColor)
            , BGColor := this.BGRFromRGB(Settings.BGColor)

        Gui Add, Custom, ClassRichEdit50W hWndhWnd +0x5031b1c4 +E0x20000 %Options%
        this.hWnd := hWnd

        ; Enable WordWrap in RichEdit control ("WordWrap" : true)
        if this.Settings.WordWrap
            SendMessage 0x0448, 0, 0, , % "ahk_id " . This.HWND

        ; Register for WM_COMMAND and WM_NOTIFY events
        ; NOTE: this prevents garbage collection of
        ; the class until the control is destroyed
        this.EventMask := 1 ; ENM_CHANGE
            , CtrlEvent := this.CtrlEvent.Bind(this)
        GuiControl +g, %hWnd%, %CtrlEvent%

        ; Set background color
        this.SendMsg(0x443, 0, BGColor) ; EM_SETBKGNDCOLOR

        ; Set character format
            , VarSetCapacity(CHARFORMAT2, 116, 0)
            , NumPut(116,                    CHARFORMAT2, 0,  "UInt")       ; cbSize      = sizeof(CHARFORMAT2)
            , NumPut(0xE0000000,             CHARFORMAT2, 4,  "UInt")       ; dwMask      = CFM_COLOR|CFM_FACE|CFM_SIZE
            , NumPut(FGColor,                CHARFORMAT2, 20, "UInt")       ; crTextColor = 0xBBGGRR
            , NumPut(Settings.Font.Size*20,  CHARFORMAT2, 12, "UInt")       ; yHeight     = twips
            , StrPut(Settings.Font.Typeface, &CHARFORMAT2+26, 32, "UTF-16") ; szFaceName  = TCHAR
            , this.SendMsg(0x444, 0, &CHARFORMAT2) ; EM_SETCHARFORMAT

        ; Set tab size to 4 for non-highlighted code
            , VarSetCapacity(TabStops, 4, 0), NumPut(Settings.TabSize*4, TabStops, "UInt")
            , this.SendMsg(0x0CB, 1, &TabStops) ; EM_SETTABSTOPS

        ; Change text limit from 32,767 to max
            , this.SendMsg(0x435, 0, -1) ; EM_EXLIMITTEXT

        ; Bind for keyboard events
        ; Use a pointer to prevent reference loop
            , this.OnMessageBound := this.OnMessage.Bind(&this)
            , OnMessage(0x100, this.OnMessageBound) ; WM_KEYDOWN
            , OnMessage(0x205, this.OnMessageBound) ; WM_RBUTTONUP

        ; Bind the highlighter
            , this.HighlightBound := this.Highlight.Bind(&this)

        ; Create the right click menu
            , this.MenuName := this.__Class . &this
            , RCMBound := this.RightClickMenu.Bind(&this)
        for _, Entry in this.MenuItems
            Menu % this.MenuName, Add, %Entry%, %RCMBound%

        ; Get the ITextDocument object
        VarSetCapacity(pIRichEditOle, A_PtrSize, 0)
            , this.SendMsg(0x43C, 0, &pIRichEditOle) ; EM_GETOLEINTERFACE
            , this.pIRichEditOle := NumGet(pIRichEditOle, 0, "UPtr")
            , this.IRichEditOle := ComObject(9, this.pIRichEditOle, 1), ObjAddRef(this.pIRichEditOle)
            , this.pITextDocument := ComObjQuery(this.IRichEditOle, this.IID_ITextDocument)
            , this.ITextDocument := ComObject(9, this.pITextDocument, 1), ObjAddRef(this.pITextDocument)
    }


    RightClickMenu(ItemName, ItemPos, MenuName)
    {
        if !IsObject(this)
            this := Object(this)

        if (ItemName == "Cut")
            Clipboard := this.SelectedText, this.SelectedText := ""
        else if (ItemName == "Copy")
            Clipboard := this.SelectedText
        else if (ItemName == "Paste")
            this.SelectedText := Clipboard
        else if (ItemName == "Delete")
            this.SelectedText := ""
        else if (ItemName == "Select All")
            this.Selection := [0, -1]
        else if (ItemName == "UPPERCASE")
            this.SelectedText := Format("{:U}", this.SelectedText)
        else if (ItemName == "lowercase")
            this.SelectedText := Format("{:L}", this.SelectedText)
        else if (ItemName == "TitleCase")
            this.SelectedText := Format("{:T}", this.SelectedText)
    }

    __Delete()
    {
        ; Release the ITextDocument object
        this.ITextDocument := "", ObjRelease(this.pITextDocument)
            , this.IRichEditOle := "", ObjRelease(this.pIRichEditOle)

        ; Release the OnMessage handlers
        OnMessage(0x100, this.OnMessageBound, 0) ; WM_KEYDOWN
        OnMessage(0x205, this.OnMessageBound, 0) ; WM_RBUTTONUP

        ; Destroy the right click menu
        Menu % this.MenuName, Delete

        HighlightBound := this.HighlightBound
        if CtrlEvent_TimerActive
            SetTimer %HighlightBound%, Delete
    }

    ; --- Event Handlers ---


    OnMessage(wParam, lParam, Msg, hWnd)
    {
        if !IsObject(this)
            this := Object(this)
        if (hWnd != this.hWnd)
            return

        if (Msg == 0x100) ; WM_KEYDOWN
        {
            if (wParam == GetKeyVK("Tab"))
            {
                ; Indentation
                Selection := this.Selection
                if GetKeyState("Shift")
                    this.IndentSelection(True) ; Reverse
                else if (Selection[2] - Selection[1]) ; Something is selected
                    this.IndentSelection()
                else
                {
                    ; TODO: Trim to size needed to reach next TabSize
                    this.SelectedText := this.Settings.Indent
                        , this.Selection[1] := this.Selection[2] ; Place cursor after
                }
                return False
            }
            else if (wParam == GetKeyVK("Escape")) ; Normally closes the window
                return False
            else if (wParam == GetKeyVK("v") && GetKeyState("Ctrl"))
            {
                this.SelectedText := Clipboard ; Strips formatting
                    , this.Selection[1] := this.Selection[2] ; Place cursor after
                return False
            }
        }
        else if (Msg == 0x205) ; WM_RBUTTONUP
        {
            Menu % this.MenuName, Show
            return False
        }
    }


    CtrlEvent(CtrlHwnd, GuiEvent, EventInfo, _ErrorLevel:="")
    {
        if (GuiEvent == "Normal" && EventInfo == 0x300) ; EN_CHANGE
        {
            ; Delay until the user is finished changing the document
            HighlightBound := this.HighlightBound
            global CtrlEvent_TimerActive:=true
            SetTimer %HighlightBound%, % -Abs(this.Settings.HighlightDelay)
        }
    }

    ; --- Methods ---

    ; First parameter is taken as a replacement value
    ; Variadic form is used to detect when a parameter is given,
    ; regardless of content
    Highlight(NewVal*)
    {
        if !IsObject(this)
            this := Object(this)
        if !(this.Settings.UseHighlighter && this.Settings.Highlighter)
        {
            if NewVal.Length()
                GuiControl,, % this.hWnd, % NewVal[1]
            return
        }

        ; Freeze the control while it is being modified, stop change event
        ; generation, suspend the undo buffer, buffer any input events
        PrevFrozen := this.Frozen, this.Frozen := True
            , PrevEventMask := this.EventMask, this.EventMask := 0 ; ENM_NONE
            , PrevUndoSuspended := this.UndoSuspended, this.UndoSuspended := True
            , PrevCritical := A_IsCritical
        Critical, 1000

        ; Run the highlighter
        Highlighter := this.Settings.Highlighter
        RTF := %Highlighter%(this.Settings, NewVal.Length() ? NewVal[1] : this.Value)

        ; "TRichEdit suspend/resume undo function"
        ; https://stackoverflow.com/a/21206620

        ; Save the rich text to a UTF-8 buffer
        VarSetCapacity(Buf, StrPut(RTF, "UTF-8"), 0)
            , StrPut(RTF, &Buf, "UTF-8")

        ; Set up the necessary structs
        VarSetCapacity(ZOOM,      8, 0) ; Zoom Level
            , VarSetCapacity(POINT,     8, 0) ; Scroll Pos
            , VarSetCapacity(CHARRANGE, 8, 0) ; Selection
            , VarSetCapacity(SETTEXTEX, 8, 0) ; SetText Settings
            , NumPut(1, SETTEXTEX, 0, "UInt") ; flags = ST_KEEPUNDO

        ; Save the scroll and cursor positions, update the text,
        ; then restore the scroll and cursor positions
        MODIFY := this.SendMsg(0xB8, 0, 0)    ; EM_GETMODIFY
            , this.SendMsg(0x4E0, &ZOOM, &ZOOM+4)   ; EM_GETZOOM
            , this.SendMsg(0x4DD, 0, &POINT)        ; EM_GETSCROLLPOS
            , this.SendMsg(0x434, 0, &CHARRANGE)    ; EM_EXGETSEL
            , this.SendMsg(0x461, &SETTEXTEX, &Buf) ; EM_SETTEXTEX
            , this.SendMsg(0x437, 0, &CHARRANGE)    ; EM_EXSETSEL
            , this.SendMsg(0x4DE, 0, &POINT)        ; EM_SETSCROLLPOS
            , this.SendMsg(0x4E1, NumGet(ZOOM, "UInt")
            , NumGet(ZOOM, 4, "UInt"))        ; EM_SETZOOM
            , this.SendMsg(0xB9, MODIFY, 0)         ; EM_SETMODIFY

        ; Restore previous settings
        Critical, %PrevCritical%
        this.UndoSuspended := PrevUndoSuspended
            , this.EventMask := PrevEventMask
            , this.Frozen := PrevFrozen
    }

    IndentSelection(Reverse:=False, Indent:="")
    {
        ; Freeze the control while it is being modified, stop change event
        ; generation, buffer any input events
        PrevFrozen := this.Frozen, this.Frozen := True
            , PrevEventMask := this.EventMask, this.EventMask := 0 ; ENM_NONE
            , PrevCritical := A_IsCritical
        Critical, 1000

        if (Indent == "")
            Indent := this.Settings.Indent
        IndentLen := StrLen(Indent)

        ; Select back to the start of the first line
            , Min := this.Selection[1]
            , Top := this.SendMsg(0x436, 0, Min) ; EM_EXLINEFROMCHAR
            , TopLineIndex := this.SendMsg(0xBB, Top, 0) ; EM_LINEINDEX
            , this.Selection[1] := TopLineIndex

        ; TODO: Insert newlines using SetSel/ReplaceSel to avoid having to call
        ; the highlighter again
            , Text := this.SelectedText
        if Reverse
        {
            ; Remove indentation appropriately
            Loop, Parse, Text, `n, `r
            {
                if (InStr(A_LoopField, Indent) == 1)
                {
                    Out .= "`n" SubStr(A_LoopField, 1+IndentLen)
                    if (A_Index == 1)
                        Min -= IndentLen
                }
                else
                    Out .= "`n" A_LoopField
            }
            this.SelectedText := SubStr(Out, 2)

            ; Move the selection start back, but never onto the previous line
            this.Selection[1] := Min < TopLineIndex ? TopLineIndex : Min
        }
        else
        {
            ; Add indentation appropriately
            Trailing := (SubStr(Text, 0) == "`n")
                , Temp := Trailing ? SubStr(Text, 1, -1) : Text
            Loop, Parse, Temp, `n, `r
                Out .= "`n" Indent . A_LoopField
            this.SelectedText := SubStr(Out, 2) . (Trailing ? "`n" : "")

            ; Move the selection start forward
                , this.Selection[1] := Min + IndentLen
        }

        this.Highlight()

        ; Restore previous settings
        Critical, %PrevCritical%
        this.EventMask := PrevEventMask

        ; When content changes cause the horizontal scrollbar to disappear,
        ; unfreezing causes the scrollbar to jump. To solve this, jump back
        ; after unfreezing. This will cause a flicker when that edge case
        ; occurs, but it's better than the alternative.
            , VarSetCapacity(POINT, 8, 0)
            , this.SendMsg(0x4DD, 0, &POINT) ; EM_GETSCROLLPOS
            , this.Frozen := PrevFrozen
            , this.SendMsg(0x4DE, 0, &POINT) ; EM_SETSCROLLPOS
    }

    ; --- Helper/Convenience Methods ---

    SendMsg(Msg, wParam, lParam)
    {
        SendMessage Msg, wParam, lParam,, % "ahk_id" this.hWnd
        return ErrorLevel
    }
}



HighlightINI(Settings, ByRef Code)
{
    static Flow := "break|byref|catch|class|continue|else|exit|exitapp|finally|for|global|gosub|goto|if|ifequal|ifexist|ifgreater|ifgreaterorequal|ifinstring|ifless|iflessorequal|ifmsgbox|ifnotequal|ifnotexist|ifnotinstring|ifwinactive|ifwinexist|ifwinnotactive|ifwinnotexist|local|loop|onexit|pause|return|settimer|sleep|static|suspend|throw|try|until|var|while"
        , Commands := "autotrim|blockinput|clipwait|control|controlclick|controlfocus|controlget|controlgetfocus|controlgetpos|controlgettext|controlmove|controlsend|controlsendraw|controlsettext|coordmode|critical|detecthiddentext|detecthiddenwindows|drive|driveget|drivespacefree|edit|envadd|envdiv|envget|envmult|envset|envsub|envupdate|fileappend|filecopy|filecopydir|filecreatedir|filecreateshortcut|filedelete|fileencoding|filegetattrib|filegetshortcut|filegetsize|filegettime|filegetversion|fileinstall|filemove|filemovedir|fileread|filereadline|filerecycle|filerecycleempty|fileremovedir|fileselectfile|fileselectfolder|filesetattrib|filesettime|formattime|getkeystate|groupactivate|groupadd|groupclose|groupdeactivate|gui|guicontrol|guicontrolget|hotkey|imagesearch|inidelete|iniread|iniwrite|input|inputbox|keyhistory|keywait|listhotkeys|listlines|listvars|menu|mouseclick|mouseclickdrag|mousegetpos|mousemove|msgbox|outputdebug|pixelgetcolor|pixelsearch|postmessage|process|progress|random|regdelete|regread|regwrite|reload|run|runas|runwait|send|sendevent|sendinput|sendlevel|sendmessage|sendmode|sendplay|sendraw|setbatchlines|setcapslockstate|setcontroldelay|setdefaultmousespeed|setenv|setformat|setkeydelay|setmousedelay|setnumlockstate|setregview|setscrolllockstate|setstorecapslockmode|settitlematchmode|setwindelay|setworkingdir|shutdown|sort|soundbeep|soundget|soundgetwavevolume|soundplay|soundset|soundsetwavevolume|splashimage|splashtextoff|splashtexton|splitpath|statusbargettext|statusbarwait|stringcasesense|stringgetpos|stringleft|stringlen|stringlower|stringmid|stringreplace|stringright|stringsplit|stringtrimleft|stringtrimright|stringupper|sysget|thread|tooltip|transform|traytip|urldownloadtofile|winactivate|winactivatebottom|winclose|winget|wingetactivestats|wingetactivetitle|wingetclass|wingetpos|wingettext|wingettitle|winhide|winkill|winmaximize|winmenuselectitem|winminimize|winminimizeall|winminimizeallundo|winmove|winrestore|winset|winsettitle|winshow|winwait|winwaitactive|winwaitclose|winwaitnotactive"
        , Functions := "abs|acos|array|asc|asin|atan|ceil|chr|comobjactive|comobjarray|comobjconnect|comobjcreate|comobject|comobjenwrap|comobjerror|comobjflags|comobjget|comobjmissing|comobjparameter|comobjquery|comobjtype|comobjunwrap|comobjvalue|cos|dllcall|exception|exp|fileexist|fileopen|floor|func|getkeyname|getkeysc|getkeystate|getkeyvk|il_add|il_create|il_destroy|instr|isbyref|isfunc|islabel|isobject|isoptional|ln|log|ltrim|lv_add|lv_delete|lv_deletecol|lv_getcount|lv_getnext|lv_gettext|lv_insert|lv_insertcol|lv_modify|lv_modifycol|lv_setimagelist|mod|numget|numput|objaddref|objclone|object|objgetaddress|objgetcapacity|objhaskey|objinsert|objinsertat|objlength|objmaxindex|objminindex|objnewenum|objpop|objpush|objrawset|objrelease|objremove|objremoveat|objsetcapacity|onmessage|ord|regexmatch|regexreplace|registercallback|round|rtrim|sb_seticon|sb_setparts|sb_settext|sin|sqrt|strget|strlen|strput|strsplit|substr|tan|trim|tv_add|tv_delete|tv_get|tv_getchild|tv_getcount|tv_getnext|tv_getparent|tv_getprev|tv_getselection|tv_gettext|tv_modify|tv_setimagelist|varsetcapacity|winactive|winexist|_addref|_clone|_getaddress|_getcapacity|_haskey|_insert|_maxindex|_minindex|_newenum|_release|_remove|_setcapacity"
        , Keynames := "alt|altdown|altup|appskey|backspace|blind|browser_back|browser_favorites|browser_forward|browser_home|browser_refresh|browser_search|browser_stop|bs|capslock|click|control|ctrl|ctrlbreak|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f1|f10|f11|f12|f13|f14|f15|f16|f17|f18|f19|f2|f20|f21|f22|f23|f24|f3|f4|f5|f6|f7|f8|f9|home|ins|insert|joy1|joy10|joy11|joy12|joy13|joy14|joy15|joy16|joy17|joy18|joy19|joy2|joy20|joy21|joy22|joy23|joy24|joy25|joy26|joy27|joy28|joy29|joy3|joy30|joy31|joy32|joy4|joy5|joy6|joy7|joy8|joy9|joyaxes|joybuttons|joyinfo|joyname|joypov|joyr|joyu|joyv|joyx|joyy|joyz|lalt|launch_app1|launch_app2|launch_mail|launch_media|lbutton|lcontrol|lctrl|left|lshift|lwin|lwindown|lwinup|mbutton|media_next|media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|numpadclear|numpaddel|numpaddiv|numpaddot|numpaddown|numpadend|numpadenter|numpadhome|numpadins|numpadleft|numpadmult|numpadpgdn|numpadpgup|numpadright|numpadsub|numpadup|pause|pgdn|pgup|printscreen|ralt|raw|rbutton|rcontrol|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|shift|shiftdown|shiftup|space|tab|up|volume_down|volume_mute|volume_up|wheeldown|wheelleft|wheelright|wheelup|xbutton1|xbutton2"
        , Builtins := "base|clipboard|clipboardall|comspec|errorlevel|false|programfiles|true"
        , Keywords := "abort|abovenormal|activex|add|ahk_class|ahk_exe|ahk_group|ahk_id|ahk_pid|all|alnum|alpha|altsubmit|alttab|alttabandmenu|alttabmenu|alttabmenudismiss|alwaysontop|and|autosize|background|backgroundtrans|base|belownormal|between|bitand|bitnot|bitor|bitshiftleft|bitshiftright|bitxor|bold|border|bottom|button|buttons|cancel|capacity|caption|center|check|check3|checkbox|checked|checkedgray|choose|choosestring|click|clone|close|color|combobox|contains|controllist|controllisthwnd|count|custom|date|datetime|days|ddl|default|delete|deleteall|delimiter|deref|destroy|digit|disable|disabled|dpiscale|dropdownlist|edit|eject|enable|enabled|error|exit|expand|exstyle|extends|filesystem|first|flash|float|floatfast|focus|font|force|fromcodepage|getaddress|getcapacity|grid|group|groupbox|guiclose|guicontextmenu|guidropfiles|guiescape|guisize|haskey|hdr|hidden|hide|high|hkcc|hkcr|hkcu|hkey_classes_root|hkey_current_config|hkey_current_user|hkey_local_machine|hkey_users|hklm|hku|hotkey|hours|hscroll|hwnd|icon|iconsmall|id|idlast|ignore|imagelist|in|insert|integer|integerfast|interrupt|is|italic|join|label|lastfound|lastfoundexist|left|limit|lines|link|list|listbox|listview|localsameasglobal|lock|logoff|low|lower|lowercase|ltrim|mainwindow|margin|maximize|maximizebox|maxindex|menu|minimize|minimizebox|minmax|minutes|monitorcount|monitorname|monitorprimary|monitorworkarea|monthcal|mouse|mousemove|mousemoveoff|move|multi|na|new|no|noactivate|nodefault|nohide|noicon|nomainwindow|norm|normal|nosort|nosorthdr|nostandard|not|notab|notimers|number|off|ok|on|or|owndialogs|owner|parse|password|pic|picture|pid|pixel|pos|pow|priority|processname|processpath|progress|radio|range|rawread|rawwrite|read|readchar|readdouble|readfloat|readint|readint64|readline|readnum|readonly|readshort|readuchar|readuint|readushort|realtime|redraw|regex|region|reg_binary|reg_dword|reg_dword_big_endian|reg_expand_sz|reg_full_resource_descriptor|reg_link|reg_multi_sz|reg_qword|reg_resource_list|reg_resource_requirements_list|reg_sz|relative|reload|remove|rename|report|resize|restore|retry|rgb|right|rtrim|screen|seconds|section|seek|send|sendandmouse|serial|setcapacity|setlabel|shiftalttab|show|shutdown|single|slider|sortdesc|standard|status|statusbar|statuscd|strike|style|submit|sysmenu|tab|tab2|tabstop|tell|text|theme|this|tile|time|tip|tocodepage|togglecheck|toggleenable|toolwindow|top|topmost|transcolor|transparent|tray|treeview|type|uncheck|underline|unicode|unlock|updown|upper|uppercase|useenv|useerrorlevel|useunsetglobal|useunsetlocal|vis|visfirst|visible|vscroll|waitclose|wantctrla|wantf2|wantreturn|wanttab|wrap|write|writechar|writedouble|writefloat|writeint|writeint64|writeline|writenum|writeshort|writeuchar|writeuint|writeushort|xdigit|xm|xp|xs|yes|ym|yp|ys|__call|__delete|__get|__handle|__new|__set"
        , Needle :="
        (LTrim Join Comments
            ODims)
            ((?:^|\s);[^\n]+)                	; Comments
            |(^\s*\/\*.+?\n\s*\*\/)      	; Multiline comments
            |((?:^|\s)#[^ \t\r\n,]+)      	; Directives
            |([+*!~&\/\\<>^|=?:
            ,().```%{}\[\]\-]+)           	; Punctuation
            |\b(0x[0-9a-fA-F]+|[0-9]+)	; Numbers
            |(""[^""\r\n]*"")                	; Strings
            |\b(A_\w*|" Builtins ")\b   	; A_Builtins
            |\b(" Flow ")\b                  	; Flow
            |\b(" Commands ")\b       	; Commands
            |\b(" Functions ")\b          	; Functions (builtin)
            |\b(" Keynames ")\b         	; Keynames
            |\b(" Keywords ")\b          	; Other keywords
            |(([a-zA-Z_$]+)(?=\())       	; Functions
            |(^\s*[A-Z()-\s]+\:\N)        	; Descriptions
        )"

    GenHighlighterCache(Settings)
    Map := Settings.Cache.ColorMap
    RTF:=""
    Pos := 1
    while (FoundPos := RegExMatch(Code, Needle, Match, Pos))
    {
        RTF .= "\cf" Map.Plain " "
        RTF .= EscapeRTF(SubStr(Code, Pos, FoundPos-Pos))

        ; Flat block of if statements for performance
        if (Match.Value(1) != "")
            RTF .= "\cf" Map.Comments
        else if (Match.Value(2) != "")
            RTF .= "\cf" Map.Multiline
        else if (Match.Value(3) != "")
            RTF .= "\cf" Map.Directives
        else if (Match.Value(4) != "")
            RTF .= "\cf" Map.Punctuation
        else if (Match.Value(5) != "")
            RTF .= "\cf" Map.Numbers
        else if (Match.Value(6) != "")
            RTF .= "\cf" Map.Strings
        else if (Match.Value(7) != "")
            RTF .= "\cf" Map.A_Builtins
        else if (Match.Value(8) != "")
            RTF .= "\cf" Map.Flow
        else if (Match.Value(9) != "")
            RTF .= "\cf" Map.Commands
        else if (Match.Value(10) != "")
            RTF .= "\cf" Map.Functions
        else if (Match.Value(11) != "")
            RTF .= "\cf" Map.Keynames
        else if (Match.Value(12) != "")
            RTF .= "\cf" Map.Keywords
        else if (Match.Value(13) != "")
            RTF .= "\cf" Map.Functions
        else If (Match.Value(14) != "")
            RTF .= "\cf" Map.Descriptions
        else
            RTF .= "\cf" Map.Plain

        RTF .= " " EscapeRTF(Match.Value())
            , Pos := FoundPos + Match.Len()
    }

    return Settings.Cache.RTFHeader . RTF . "\cf" Map.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}
HighlightR(Settings, ByRef Code)
{
    static Flow := "break|byref|catch|class|continue|else|exit|exitapp|finally|for|global|gosub|goto|if|ifequal|ifexist|ifgreater|ifgreaterorequal|ifinstring|ifless|iflessorequal|ifmsgbox|ifnotequal|ifnotexist|ifnotinstring|ifwinactive|ifwinexist|ifwinnotactive|ifwinnotexist|local|loop|onexit|pause|return|settimer|sleep|static|suspend|throw|try|until|var|while"
        , Commands := "autotrim|blockinput|clipwait|control|controlclick|controlfocus|controlget|controlgetfocus|controlgetpos|controlgettext|controlmove|controlsend|controlsendraw|controlsettext|coordmode|critical|detecthiddentext|detecthiddenwindows|drive|driveget|drivespacefree|edit|envadd|envdiv|envget|envmult|envset|envsub|envupdate|fileappend|filecopy|filecopydir|filecreatedir|filecreateshortcut|filedelete|fileencoding|filegetattrib|filegetshortcut|filegetsize|filegettime|filegetversion|fileinstall|filemove|filemovedir|fileread|filereadline|filerecycle|filerecycleempty|fileremovedir|fileselectfile|fileselectfolder|filesetattrib|filesettime|formattime|getkeystate|groupactivate|groupadd|groupclose|groupdeactivate|gui|guicontrol|guicontrolget|hotkey|imagesearch|inidelete|iniread|iniwrite|input|inputbox|keyhistory|keywait|listhotkeys|listlines|listvars|menu|mouseclick|mouseclickdrag|mousegetpos|mousemove|msgbox|outputdebug|pixelgetcolor|pixelsearch|postmessage|process|progress|random|regdelete|regread|regwrite|reload|run|runas|runwait|send|sendevent|sendinput|sendlevel|sendmessage|sendmode|sendplay|sendraw|setbatchlines|setcapslockstate|setcontroldelay|setdefaultmousespeed|setenv|setformat|setkeydelay|setmousedelay|setnumlockstate|setregview|setscrolllockstate|setstorecapslockmode|settitlematchmode|setwindelay|setworkingdir|shutdown|sort|soundbeep|soundget|soundgetwavevolume|soundplay|soundset|soundsetwavevolume|splashimage|splashtextoff|splashtexton|splitpath|statusbargettext|statusbarwait|stringcasesense|stringgetpos|stringleft|stringlen|stringlower|stringmid|stringreplace|stringright|stringsplit|stringtrimleft|stringtrimright|stringupper|sysget|thread|tooltip|transform|traytip|urldownloadtofile|winactivate|winactivatebottom|winclose|winget|wingetactivestats|wingetactivetitle|wingetclass|wingetpos|wingettext|wingettitle|winhide|winkill|winmaximize|winmenuselectitem|winminimize|winminimizeall|winminimizeallundo|winmove|winrestore|winset|winsettitle|winshow|winwait|winwaitactive|winwaitclose|winwaitnotactive"
        , Functions := "abs|acos|array|asc|asin|atan|ceil|chr|comobjactive|comobjarray|comobjconnect|comobjcreate|comobject|comobjenwrap|comobjerror|comobjflags|comobjget|comobjmissing|comobjparameter|comobjquery|comobjtype|comobjunwrap|comobjvalue|cos|dllcall|exception|exp|fileexist|fileopen|floor|func|getkeyname|getkeysc|getkeystate|getkeyvk|il_add|il_create|il_destroy|instr|isbyref|isfunc|islabel|isobject|isoptional|ln|log|ltrim|lv_add|lv_delete|lv_deletecol|lv_getcount|lv_getnext|lv_gettext|lv_insert|lv_insertcol|lv_modify|lv_modifycol|lv_setimagelist|mod|numget|numput|objaddref|objclone|object|objgetaddress|objgetcapacity|objhaskey|objinsert|objinsertat|objlength|objmaxindex|objminindex|objnewenum|objpop|objpush|objrawset|objrelease|objremove|objremoveat|objsetcapacity|onmessage|ord|regexmatch|regexreplace|registercallback|round|rtrim|sb_seticon|sb_setparts|sb_settext|sin|sqrt|strget|strlen|strput|strsplit|substr|tan|trim|tv_add|tv_delete|tv_get|tv_getchild|tv_getcount|tv_getnext|tv_getparent|tv_getprev|tv_getselection|tv_gettext|tv_modify|tv_setimagelist|varsetcapacity|winactive|winexist|_addref|_clone|_getaddress|_getcapacity|_haskey|_insert|_maxindex|_minindex|_newenum|_release|_remove|_setcapacity"
        , Keynames := "alt|altdown|altup|appskey|backspace|blind|browser_back|browser_favorites|browser_forward|browser_home|browser_refresh|browser_search|browser_stop|bs|capslock|click|control|ctrl|ctrlbreak|ctrldown|ctrlup|del|delete|down|end|enter|esc|escape|f1|f10|f11|f12|f13|f14|f15|f16|f17|f18|f19|f2|f20|f21|f22|f23|f24|f3|f4|f5|f6|f7|f8|f9|home|ins|insert|joy1|joy10|joy11|joy12|joy13|joy14|joy15|joy16|joy17|joy18|joy19|joy2|joy20|joy21|joy22|joy23|joy24|joy25|joy26|joy27|joy28|joy29|joy3|joy30|joy31|joy32|joy4|joy5|joy6|joy7|joy8|joy9|joyaxes|joybuttons|joyinfo|joyname|joypov|joyr|joyu|joyv|joyx|joyy|joyz|lalt|launch_app1|launch_app2|launch_mail|launch_media|lbutton|lcontrol|lctrl|left|lshift|lwin|lwindown|lwinup|mbutton|media_next|media_play_pause|media_prev|media_stop|numlock|numpad0|numpad1|numpad2|numpad3|numpad4|numpad5|numpad6|numpad7|numpad8|numpad9|numpadadd|numpadclear|numpaddel|numpaddiv|numpaddot|numpaddown|numpadend|numpadenter|numpadhome|numpadins|numpadleft|numpadmult|numpadpgdn|numpadpgup|numpadright|numpadsub|numpadup|pause|pgdn|pgup|printscreen|ralt|raw|rbutton|rcontrol|rctrl|right|rshift|rwin|rwindown|rwinup|scrolllock|shift|shiftdown|shiftup|space|tab|up|volume_down|volume_mute|volume_up|wheeldown|wheelleft|wheelright|wheelup|xbutton1|xbutton2"
        , Builtins := "base|clipboard|clipboardall|comspec|errorlevel|false|programfiles|true"
        , Keywords := "abort|abovenormal|activex|add|ahk_class|ahk_exe|ahk_group|ahk_id|ahk_pid|all|alnum|alpha|altsubmit|alttab|alttabandmenu|alttabmenu|alttabmenudismiss|alwaysontop|and|autosize|background|backgroundtrans|base|belownormal|between|bitand|bitnot|bitor|bitshiftleft|bitshiftright|bitxor|bold|border|bottom|button|buttons|cancel|capacity|caption|center|check|check3|checkbox|checked|checkedgray|choose|choosestring|click|clone|close|color|combobox|contains|controllist|controllisthwnd|count|custom|date|datetime|days|ddl|default|delete|deleteall|delimiter|deref|destroy|digit|disable|disabled|dpiscale|dropdownlist|edit|eject|enable|enabled|error|exit|expand|exstyle|extends|filesystem|first|flash|float|floatfast|focus|font|force|fromcodepage|getaddress|getcapacity|grid|group|groupbox|guiclose|guicontextmenu|guidropfiles|guiescape|guisize|haskey|hdr|hidden|hide|high|hkcc|hkcr|hkcu|hkey_classes_root|hkey_current_config|hkey_current_user|hkey_local_machine|hkey_users|hklm|hku|hotkey|hours|hscroll|hwnd|icon|iconsmall|id|idlast|ignore|imagelist|in|insert|integer|integerfast|interrupt|is|italic|join|label|lastfound|lastfoundexist|left|limit|lines|link|list|listbox|listview|localsameasglobal|lock|logoff|low|lower|lowercase|ltrim|mainwindow|margin|maximize|maximizebox|maxindex|menu|minimize|minimizebox|minmax|minutes|monitorcount|monitorname|monitorprimary|monitorworkarea|monthcal|mouse|mousemove|mousemoveoff|move|multi|na|new|no|noactivate|nodefault|nohide|noicon|nomainwindow|norm|normal|nosort|nosorthdr|nostandard|not|notab|notimers|number|off|ok|on|or|owndialogs|owner|parse|password|pic|picture|pid|pixel|pos|pow|priority|processname|processpath|progress|radio|range|rawread|rawwrite|read|readchar|readdouble|readfloat|readint|readint64|readline|readnum|readonly|readshort|readuchar|readuint|readushort|realtime|redraw|regex|region|reg_binary|reg_dword|reg_dword_big_endian|reg_expand_sz|reg_full_resource_descriptor|reg_link|reg_multi_sz|reg_qword|reg_resource_list|reg_resource_requirements_list|reg_sz|relative|reload|remove|rename|report|resize|restore|retry|rgb|right|rtrim|screen|seconds|section|seek|send|sendandmouse|serial|setcapacity|setlabel|shiftalttab|show|shutdown|single|slider|sortdesc|standard|status|statusbar|statuscd|strike|style|submit|sysmenu|tab|tab2|tabstop|tell|text|theme|this|tile|time|tip|tocodepage|togglecheck|toggleenable|toolwindow|top|topmost|transcolor|transparent|tray|treeview|type|uncheck|underline|unicode|unlock|updown|upper|uppercase|useenv|useerrorlevel|useunsetglobal|useunsetlocal|vis|visfirst|visible|vscroll|waitclose|wantctrla|wantf2|wantreturn|wanttab|wrap|write|writechar|writedouble|writefloat|writeint|writeint64|writeline|writenum|writeshort|writeuchar|writeuint|writeushort|xdigit|xm|xp|xs|yes|ym|yp|ys|__call|__delete|__get|__handle|__new|__set"
        , Needle :="
        (LTrim Join Comments
            ODims)
            ((?:^|\s);[^\n]+)                	; Comments
            |(^\s*\/\*.+?\n\s*\*\/)      	; Multiline comments
            |((?:^|\s)#[^ \t\r\n,]+)      	; Directives
            |([+*!~&\/\\<>^|=?:
            ,().```%{}\[\]\-]+)           	; Punctuation
            |\b(0x[0-9a-fA-F]+|[0-9]+)	; Numbers
            |(""[^""\r\n]*"")                	; Strings
            |\b(A_\w*|" Builtins ")\b   	; A_Builtins
            |\b(" Flow ")\b                  	; Flow
            |\b(" Commands ")\b       	; Commands
            |\b(" Functions ")\b          	; Functions (builtin)
            |\b(" Keynames ")\b         	; Keynames
            |\b(" Keywords ")\b          	; Other keywords
            |(([a-zA-Z_$]+)(?=\())       	; Functions
            |(^\s*[A-Z()-\s]+\:\N)        	; Descriptions
        )"

    GenHighlighterCache(Settings)
    Map := Settings.Cache.ColorMap
    RTF:=""
    Pos := 1
    while (FoundPos := RegExMatch(Code, Needle, Match, Pos))
    {
        RTF .= "\cf" Map.Plain " "
        RTF .= EscapeRTF(SubStr(Code, Pos, FoundPos-Pos))

        ; Flat block of if statements for performance
        if (Match.Value(1) != "")
            RTF .= "\cf" Map.Comments
        else if (Match.Value(2) != "")
            RTF .= "\cf" Map.Multiline
        else if (Match.Value(3) != "")
            RTF .= "\cf" Map.Directives
        else if (Match.Value(4) != "")
            RTF .= "\cf" Map.Punctuation
        else if (Match.Value(5) != "")
            RTF .= "\cf" Map.Numbers
        else if (Match.Value(6) != "")
            RTF .= "\cf" Map.Strings
        else if (Match.Value(7) != "")
            RTF .= "\cf" Map.A_Builtins
        else if (Match.Value(8) != "")
            RTF .= "\cf" Map.Flow
        else if (Match.Value(9) != "")
            RTF .= "\cf" Map.Commands
        else if (Match.Value(10) != "")
            RTF .= "\cf" Map.Functions
        else if (Match.Value(11) != "")
            RTF .= "\cf" Map.Keynames
        else if (Match.Value(12) != "")
            RTF .= "\cf" Map.Keywords
        else if (Match.Value(13) != "")
            RTF .= "\cf" Map.Functions
        else If (Match.Value(14) != "")
            RTF .= "\cf" Map.Descriptions
        else
            RTF .= "\cf" Map.Plain

        RTF .= " " EscapeRTF(Match.Value())
            , Pos := FoundPos + Match.Len()
    }

    return Settings.Cache.RTFHeader . RTF . "\cf" Map.Plain " " EscapeRTF(SubStr(Code, Pos)) "\`n}"
}

GenHighlighterCache(Settings)
{

    if Settings.HasKey("Cache")
        return
    Cache := Settings.Cache := {}

    ; --- Process Colors ---
        , Cache.Colors := Settings.Colors.Clone()

    ; Inherit from the Settings array's base
        , BaseSettings := Settings
    while (BaseSettings := BaseSettings.Base)
        for Name, Color in BaseSettings.Colors
            if !Cache.Colors.HasKey(Name)
                Cache.Colors[Name] := Color

    ; Include the color of plain text
    if !Cache.Colors.HasKey("Plain")
        Cache.Colors.Plain := Settings.FGColor

    ; Create a Name->Index map of the colors
    Cache.ColorMap := {}
    for Name, Color in Cache.Colors
        Cache.ColorMap[Name] := A_Index

    ; --- Generate the RTF headers ---
    RTF := "{\urtf"

    ; Color Table
        , RTF .= "{\colortbl;"
    for Name, Color in Cache.Colors
    {
        RTF .= "\red" 	Color>>16	& 0xFF
            , RTF .= "\green"	Color>>8 	& 0xFF
            , RTF .= "\blue" 	Color 	& 0xFF ";"
    }
    RTF .= "}"

    ; Font Table

    FontTable:=""
    if Settings.Font
    {
        FontTable .= "{\fonttbl{\f0\fmodern\fcharset0 "
            ,FontTable .= Settings.Font.Typeface
            ,FontTable .= ";}}"
            ,RTF .= "\fs" Settings.Font.Size * 2 ; Font size (half-points)
        if Settings.Font.Bold
            RTF .= "\b"
    }

    ; Tab size (twips)
    RTF .= "\deftab" GetCharWidthTwips(Settings.Font) * Settings.TabSize

        , Cache.RTFHeader := RTF
}

GetCharWidthTwips(Font)
{

    static Cache := {}

    if Cache.HasKey(Font.Typeface "_" Font.Size "_" Font.Bold)
        return Cache[Font.Typeface "_" Font.Size "_" Font.Bold]

    ; Calculate parameters of CreateFont
    Height	:= -Round(Font.Size*A_ScreenDPI/72)
        , Weight	:= 400+300*(!!Font.Bold)
        , Face 	:= Font.Typeface

    ; Get the width of "x"
    hDC 	:= DllCall("GetDC", "UPtr", 0)
        , hFont 	:= DllCall("CreateFont"
        , "Int", Height 	; _In_ int       	  nHeight,
        , "Int", 0 	; _In_ int       	  nWidth,
        , "Int", 0 	; _In_ int       	  nEscapement,
        , "Int", 0 	; _In_ int       	  nOrientation,
        , "Int", Weight ; _In_ int        	  fnWeight,
        , "UInt", 0 	; _In_ DWORD   fdwItalic,
        , "UInt", 0 	; _In_ DWORD   fdwUnderline,
        , "UInt", 0 	; _In_ DWORD   fdwStrikeOut,
        , "UInt", 0 	; _In_ DWORD   fdwCharSet, (ANSI_CHARSET)
        , "UInt", 0 	; _In_ DWORD   fdwOutputPrecision, (OUT_DEFAULT_PRECIS)
        , "UInt", 0 	; _In_ DWORD   fdwClipPrecision, (CLIP_DEFAULT_PRECIS)
        , "UInt", 0 	; _In_ DWORD   fdwQuality, (DEFAULT_QUALITY)
        , "UInt", 0 	; _In_ DWORD   fdwPitchAndFamily, (FF_DONTCARE|DEFAULT_PITCH)
        , "Str", Face 	; _In_ LPCTSTR  lpszFace
        , "UPtr")
        , hObj := DllCall("SelectObject", "UPtr", hDC, "UPtr", hFont, "UPtr")
        , VarSetCapacity(SIZE, 8, 0)
        , DllCall("GetTextExtentPoint32", "UPtr", hDC, "Str", "x", "Int", 1, "UPtr", &SIZE)
        , DllCall("SelectObject", "UPtr", hDC, "UPtr", hObj, "UPtr")
        , DllCall("DeleteObject", "UPtr", hFont)
        , DllCall("ReleaseDC", "UPtr", 0, "UPtr", hDC)

    ; Convert to twpis
    Twips := Round(NumGet(SIZE, 0, "UInt")*1440/A_ScreenDPI)
        , Cache[Font.Typeface "_" Font.Size "_" Font.Bold] := Twips
    return Twips
}

EscapeRTF(Code)
{
    for _, Char in ["\", "{", "}", "`n"]
        Code := StrReplace(Code, Char, "\" Char)
    return StrReplace(StrReplace(Code, "`t", "\tab "), "`r")
}
; #region:HasVal (106844043)

; #region:Metadata:
; Snippet: HasVal;  (v.1.0.0)
; --------------------------------------------------------------
; Author: jNizM
; Source: https://www.autohotkey.com/boards/viewtopic.php?p=109173&sid=e530e129dcf21e26636fec1865e3ee30#p109173
; (07 August 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 12 - Objects
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata


; #region:Description:
; Checks if an Array/Object has a value and returns its index/key.
; 
; If value occurs more than once in the array/object, ONLY THE FIRST occurence's key is returned
; #endregion:Description

; #region:Example
; A:=[1,2,3]
; msgbox, % HasVal(A,2)
; B:={I:"1",J:"2",K:"3"}
; msgbox, % HasVal(B,2)
; 
; #endregion:Example


; #region:Code
HasVal(haystack, needle) 
{
    if !(IsObject(haystack)) || (haystack.Length() = 0)
        return 0
    for index, value in haystack
        if (value = needle)
            return index
    return 0
}
; #endregion:Code



; #endregion:HasVal (106844043)
; =================================================================================
; Function: AutoXYWH
;   Move and resize control automatically when GUI resizes.
; Parameters:
;   DimSize - Can be one or more of x/y/w/h  optional followed by a fraction
;             add a '*' to DimSize to 'MoveDraw' the controls rather then just 'Move', this is recommended for Groupboxes
;             add a 't' to DimSize to tell AutoXYWH that the controls in cList are on/in a tab3 control
;   cList   - variadic list of ControlIDs
;             ControlID can be a control HWND, associated variable name, ClassNN or displayed text.
;             The later (displayed text) is possible but not recommend since not very reliable 
; Examples:
;   AutoXYWH("xy", "Btn1", "Btn2")
;   AutoXYWH("w0.5 h 0.75", hEdit, "displayed text", "vLabel", "Button1")
;   AutoXYWH("*w0.5 h 0.75", hGroupbox1, "GrbChoices")
;   AutoXYWH("t x h0.5", "Btn1")
; ---------------------------------------------------------------------------------
; Version: 2020-5-20 / small code improvements (toralf)
;          2018-1-31 / added a line to prevent warnings (pramach)
;          2018-1-13 / added t option for controls on Tab3 (Alguimist)
;          2015-5-29 / added 'reset' option (tmplinshi)
;          2014-7-03 / mod by toralf
;          2014-1-02 / initial version tmplinshi
; requires AHK version : 1.1.13.01+    due to SprSplit()
; =================================================================================

AutoXYWH(DimSize, cList*){   ;https://www.autohotkey.com/boards/viewtopic.php?t=1079
    Static cInfo := {}

    If (DimSize = "reset")
        Return cInfo := {}

    For _, ctrl in cList {
        ctrlID := A_Gui ":" ctrl
        If !cInfo.hasKey(ctrlID) {
            ix := iy := iw := ih := 0	
            ;@ahk-neko-ignore-fn 1 line; at 9/16/2023, 9:37:45 PM ; var is assigned but never used.
            GuiControlGet i, %A_Gui%: Pos, %ctrl%
            MMD := InStr(DimSize, "*") ? "MoveDraw" : "Move"
            fx := fy := fw := fh := 0
            For i, dim in (a := StrSplit(RegExReplace(DimSize, "i)[^xywh]"))) 
                If !RegExMatch(DimSize, "i)" . dim . "\s*\K[\d.-]+", f%dim%)
                    f%dim% := 1

            If (InStr(DimSize, "t")) {
                GuiControlGet hWnd, %A_Gui%: hWnd, %ctrl%
                hParentWnd := DllCall("GetParent", "Ptr", hWnd, "Ptr")
                VarSetCapacity(RECT, 16, 0)
                DllCall("GetWindowRect", "Ptr", hParentWnd, "Ptr", &RECT)
                DllCall("MapWindowPoints", "Ptr", 0, "Ptr", DllCall("GetParent", "Ptr", hParentWnd, "Ptr"), "Ptr", &RECT, "UInt", 1)
                ix := ix - NumGet(RECT, 0, "Int")
                iy := iy - NumGet(RECT, 4, "Int")
            }

            cInfo[ctrlID] := {x:ix, fx:fx, y:iy, fy:fy, w:iw, fw:fw, h:ih, fh:fh, gw:A_GuiWidth, gh:A_GuiHeight, a:a, m:MMD}
        } Else {
            ;@ahk-neko-ignore-fn 1 line; at 9/16/2023, 9:37:18 PM ; var is assigned but never used.
            dgx := dgw := A_GuiWidth - cInfo[ctrlID].gw, dgy := dgh := A_GuiHeight - cInfo[ctrlID].gh
            Options := ""
            For i, dim in cInfo[ctrlID]["a"]
                Options .= dim (dg%dim% * cInfo[ctrlID]["f" . dim] + cInfo[ctrlID][dim]) A_Space
            GuiControl % A_Gui ":" cInfo[ctrlID].m, % ctrl, % Options
        } } }

buildHistory(History,NumberOfRecords,configpath:="") {
    examples:=[]
    for _, file in History {
        if InStr(file,A_ScriptDir) {
            examples.push(file)
        }
    }
    ret:=History.Clone()
    if (configpath!="") {
        if HasVal(ret,configpath) {
            ret.RemoveAt(HasVal(ret,configpath),1)
        }
        ret.InsertAt(1,configpath)
    }
    if (ret.Count()>NumberOfRecords) {
        ret.Delete(NumberOfRecords+1,ret.Count())
    }
    for _, file in examples {
        if !HasVal(ret,file) {
            ret.push(file)
        }
    }
    return ret
}


toggle_ReportTip() {
    global hwndLV_ConfigHistory
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
    global hwndLV_RScriptHistory
    GuiControlGet vToggleLVReport2
    GuiControl % (vToggleLVReport2 ? "+Tile" : "+Report"), % hwndLV_RScriptHistory
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
    if (!InStr(configPath,A_ScriptDir)) {
        script.config.LastConfigsHistory:=buildHistory(script.config.LastConfigsHistory,script.config.Configurator_settings.ConfigHistoryLimit,configPath)
        updateLV(hwndLV_ConfigHistory,script.config.LastConfigsHistory)
        script.save(script.scriptconfigfile,,true)
    }
    return
}
loadRScriptFromLV(dynGUI,guiObject) {
    global hwndLV_RScriptHistory
    global generateRScriptBtn
    gui Listview, % hwndLV_RScriptHistory
    ; TODO: clean up the load config logic to use one singular function, instead of the same code copy-pasted everywhere. then make this func properly take the right guiObject
    rscriptPath:=getSelectedLVEntries2()
    /*
    */
    if (rscriptPath!="") {

        if (!InStr(rscriptPath,".R")) {
            rscriptPath:=rscriptPath ".R"
        }
        onGenerateRScript:=Func("createRScript").Bind(rscriptPath)
        guiControl GC:+g, %generateRScriptBtn%, % onGenerateRScript
        guicontrol % "GC:",vStarterRScriptLocation, % rscriptPath
        if (rscriptPath!="") {
            dynGUI.GFA_Evaluation_RScript_Location:=rscriptPath
        }
        if (!FileExist(rscriptPath)) {
            writeFile(rscriptPath,"","UTF-8-RAW",,true)
        } else {
        }
        guiResize(guiObject)
    }
    if (rscriptPath!="") {
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
        if (!InStr(rscriptPath,A_ScriptDir)) {
            script.config.LastRScriptHistory:=buildHistory(script.config.LastRScriptHistory,script.config.Configurator_settings.ConfigHistoryLimit,rscriptPath)
            updateLV(hwndLV_RScriptHistory,script.config.LastRScriptHistory)
            script.save(script.scriptconfigfile,,true)
        }
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
    Global hwndLV_ConfigHistory, hwndLV_RScriptHistory, LVTTHWNDARR
    Static NMHDRSize := A_PtrSize * 3
    Static offText := NMHDRSize + A_PtrSize
    Static offItem := NMHDRSize + (A_PtrSize * 2) + 4
    Static TTM_SETTITLE := (A_IsUnicode ? 0x421 : 0x420)
    Static LVN_GETINFOTIP := (A_IsUnicode ? -158 : -157)
    Static LVM_GETSTRINGWIDTH := (A_IsUnicode ? 0x1057 : 0x1011)

    Code := NumGet(L + (A_PtrSize * 2), "Int")
    HCTL := NumGet(L + 0, 0, "UPtr")
    ; HCTL is one of our listviews
    If ((HCTL = hwndLV_ConfigHistory) || (HCTL = hwndLV_RScriptHistory)) {
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
            DllCall("SendMessage", "Ptr", LVTTHWNDARR[HCTL], "UInt", TTM_SETTITLE, "Ptr", 0, "Ptr", &txt1)
            ; Populate the string buffer with newly added text for the ToolTip
            StrPut(txt2 "`n" txt3, textAddr, "UTF-16")
        }
        else {
            ; Remove ToolTip's title in case we are on a column other than 1
            ; May be another way to do this so we aren't setting to nothing so often.
            DllCall("SendMessage", "Ptr", LVTTHWNDARR[HCTL], "UInt", TTM_SETTITLE, "Ptr", 0, "Ptr", "")
        }
    }
}


; ======================================================================================================================
; LV_EX_SetTileViewLines - Sets the maximum number of additional text lines in each tile, not counting the title.
; ======================================================================================================================
LV_EX_SetTileViewLines(HLV, Lines, tileX := "", tileY := "") {
    ; Lines : Maximum number of text lines in each item label, not counting the title.
    ; LVM_GETTILEVIEWINFO = 0x10A3 -> http://msdn.microsoft.com/en-us/library/bb761083(v=vs.85).aspx
    ; LVM_SETTILEVIEWINFO = 0x10A2 -> http://msdn.microsoft.com/en-us/library/bb761212(v=vs.85).aspx
    ; One line is added internally because the item might be wrapped to two lines!
    Static SizeLVTVI := 40
    ;Static offSize := 12 ;; this var is never used, why is it here?!
    Static OffLines := 20
    Static LVTVIM_TILESIZE := 0x1
    Static LVTVIM_COLUMNS := 0x2
    Static LVTVIF_AUTOSIZE := 0x0, LVTVIF_FIXEDWIDTH := 0x1, LVTVIF_FIXEDHEIGHT := 0x2, LVTVIF_FIXEDSIZE := 0x3
    Mask := LVTVIM_COLUMNS | (tileX || tileY ? LVTVIM_TILESIZE : 0)
    If (tileX && tileY)
        flag := LVTVIF_FIXEDSIZE
    Else If (tileX && !tileY)
        flag := LVTVIF_FIXEDWIDTH
    Else If (!tileX && tileY)
        flag := LVTVIF_FIXEDHEIGHT
    Else
        flag := LVTVIF_AUTOSIZE
    ; If (Lines > 0)
    ; Lines++
    VarSetCapacity(LVTVI, SizeLVTVI, 0)     ; LVTILEVIEWINFO
    NumPut(SizeLVTVI, LVTVI, 0, "UInt")     ; cbSize
    NumPut(Mask, LVTVI, 4, "UInt")    ; dwMask = LVTVIM_TILESIZE | LVTVIM_COLUMNS
    NumPut(flag, LVTVI, 8, "UInt")       ; dwMask
    if (tileX)
        NumPut(tileX, LVTVI, 12, "Int")       ; sizeTile.cx
    if (tileY)
        NumPut(tileY, LVTVI, 16, "Int")       ; sizeTile.cx
    NumPut(Lines, LVTVI, OffLines, "Int") ; c_lines: max lines below first line
    SendMessage 0x10A2, 0, % &LVTVI, , % "ahk_id " . HLV ; LVM_SETTILEVIEWINFO
    Return ErrorLevel
}

; ======================================================================================================================
; Namespace:      LV_EX
; Function:       Some additional functions to use with AHK ListView controls.
; Tested with:    AHK 1.1.20.03 (A32/U32/U64)
; Tested on:      Win 8.1 (x64)
; Changelog:
;     1.1.01.00/2016-04-28(just me     -  added LV_EX_GroupGetState contributed by Pulover.
;     1.1.00.00/2015-03-13/just me     -  added basic tile view support (suggested by toralf),
;                                         added basic (XP compatible) group view support,
;                                         revised code and made some minor changes.
;     1.0.00.00/2013-12-30/just me     -  initial release.
; Notes:
;     In terms of Microsoft
;        Item     stands for the whole row or the first column of the row
;        SubItem  stands for the second to last column of a row
;     All functions require the handle of the ListView (HWND). You get this handle using the 'Hwnd' option when
;     creating the control per 'Gui, Add, HwndHwndOfLV ...' or using 'GuiControlGet, HwndOfLV, Hwnd, MyListViewVar'
;     after control creation.
; Credits:
;     LV_EX tile view functions:
;        Initial idea by segalion (old forum: /board/topic/80754-listview-with-multiline-in-report-mode-help/)
;        based on code from Fabio Lucarelli (http://users.skynet.be/oleole/ListView_Tiles.htm).
; ======================================================================================================================
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from the use of this software.
; ======================================================================================================================
; ======================================================================================================================
; LV_EX_CalcViewSize - Calculates the approximate width and height required to display a given number of items.
; ======================================================================================================================
LV_EX_CalcViewSize(HLV, Rows := 0) {
    ; LVM_APPROXIMATEVIEWRECT = 0x1040 -> http://msdn.microsoft.com/en-us/library/bb774883(v=vs.85).aspx
    SendMessage 0x1040, % (Rows - 1), 0, , % "ahk_id " . HLV
    Return {W: (ErrorLevel & 0xFFFF), H: (ErrorLevel >> 16) & 0xFFFF}
}
; ======================================================================================================================
; LV_EX_EnableGroupView - Enables or disables whether the items in a list-view control display as a group.
; ======================================================================================================================
LV_EX_EnableGroupView(HLV, Enable := True) {
    ; LVM_ENABLEGROUPVIEW = 0x109D -> msdn.microsoft.com/en-us/library/bb774900(v=vs.85).aspx
    SendMessage 0x109D, % (!!Enable), 0, , % "ahk_id " . HLV
    Return (ErrorLevel >> 31) ? 0 : 1
}
; ======================================================================================================================
; LV_EX_FindString - Searches the first column for an item containing the specified string.
; ======================================================================================================================
LV_EX_FindString(HLV, Str, Start := 0, Partial := False) {
    ; LVM_FINDITEM -> http://msdn.microsoft.com/en-us/library/bb774903(v=vs.85).aspx
    Static LVM_FINDITEM := A_IsUnicode ? 0x1053 : 0x100D ; LVM_FINDITEMW : LVM_FINDITEMA
    Static LVFISize := 40
    VarSetCapacity(LVFI, LVFISize, 0) ; LVFINDINFO
    Flags := 0x0002 ; LVFI_STRING
    If (Partial)
        Flags |= 0x0008 ; LVFI_PARTIAL
    NumPut(Flags, LVFI, 0, "UInt")
    NumPut(&Str,  LVFI, A_PtrSize, "Ptr")
    SendMessage % LVM_FINDITEM, % (Start - 1), % &LVFI, , % "ahk_id " . HLV
    Return (ErrorLevel > 0x7FFFFFFF ? 0 : ErrorLevel + 1)
}
; ======================================================================================================================
; LV_EX_FindStringEx - Searches all columns or the specified column for a subitem containing the specified string.
; ======================================================================================================================
LV_EX_FindStringEx(HLV, Str, Column := 0, Start := 0, Partial := False) {
    Len := StrLen(Str)
    Row := Col := 0
    ControlGet ItemList, List, , , % "ahk_id " . HLV
    Loop, Parse, ItemList, `n
    {
        If (A_Index > Start) {
            Row := A_Index
            Columns := StrSplit(A_LoopField, "`t")
            If (Column + 0) > 0 {
                If (Partial) {
                    If (SubStr(Columns[Column], 1, Len) = Str)
                        Col := Column
                }
                Else {
                    If (Columns[Column] = Str)
                        Col := Column
                }
            }
            Else {
                For Index, ColumnText In Columns {
                    If (Partial) {
                        If (SubStr(ColumnText, 1, Len) = Str)
                            Col := Index
                    }
                    Else {
                        If (ColumnText = Str)
                            Col := Index
                    }
                } Until (Col > 0)
            }
        }
    } Until (Col > 0)
    Return (Col > 0) ? {Row: Row, Col: Column} : 0
}
; ======================================================================================================================
; LV_EX_GetColumnOrder - Gets the current left-to-right order of columns in a list-view control.
; ======================================================================================================================
LV_EX_GetColumnOrder(HLV) {
    ; LVM_GETCOLUMNORDERARRAY = 0x103B -> http://msdn.microsoft.com/en-us/library/bb774913(v=vs.85).aspx
    SendMessage 0x1200, 0, 0, , % "ahk_id " . LV_EX_GetHeader(HLV) ; HDM_GETITEMCOUNT
    If (ErrorLevel > 0x7FFFFFFF)
        Return False
    Cols := ErrorLevel
    VarSetCapacity(COA, Cols * 4, 0)
    SendMessage 0x103B, % Cols, % &COA, , % "ahk_id " . HLV
    If (ErrorLevel = 0) || !(ErrorLevel + 0)
        Return False
    ColArray := []
    Loop, %Cols%
        ColArray[A_Index] := NumGet(COA, 4 * (A_Index - 1), "Int") + 1
    Return ColArray
}
; ======================================================================================================================
; LV_EX_GetColumnWidth - Gets the width of a column in report or list view.
; ======================================================================================================================
LV_EX_GetColumnWidth(HLV, Column) {
    ; LVM_GETCOLUMNWIDTH = 0x101D -> http://msdn.microsoft.com/en-us/library/bb774915(v=vs.85).aspx
    SendMessage 0x101D, % (Column - 1), 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetExtendedStyle - Gets the extended styles that are currently in use for a given list-view control.
; ======================================================================================================================
LV_EX_GetExtendedStyle(HLV) {
    ; LVM_GETEXTENDEDLISTVIEWSTYLE = 0x1037 -> http://msdn.microsoft.com/en-us/library/bb774923(v=vs.85).aspx
    SendMessage 0x1037, 0, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetGroup - Gets the ID of the group the list-view item belongs to.
; ======================================================================================================================
LV_EX_GetGroup(HLV, Row) {
    ; LVM_GETITEMA = 0x1005 -> http://msdn.microsoft.com/en-us/library/bb774953(v=vs.85).aspx
    Static OffGroupID := 28 + (A_PtrSize * 3)
    LV_EX_LVITEM(LVITEM, 0x00000100, Row) ; LVIF_GROUPID
    SendMessage 0x1005, 0, % &LVITEM, , % "ahk_id " . HLV
    Return NumGet(LVITEM, OffGroupID, "UPtr")
}
; ======================================================================================================================
; LV_EX_GetHeader - Retrieves the handle of the header control used by the list-view control.
; ======================================================================================================================
LV_EX_GetHeader(HLV) {
    ; LVM_GETHEADER = 0x101F -> http://msdn.microsoft.com/en-us/library/bb774937(v=vs.85).aspx
    SendMessage 0x101F, 0, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetIconSpacing - Determines the spacing between icons in the icon view.
; ======================================================================================================================
LV_EX_GetIconSpacing(HLV, ByRef CX, BYREF CY) {
    ; LVM_GETITEMSPACING = 0x1033 -> http://msdn.microsoft.com/en-us/library/bb761051(v=vs.85).aspx
    CX := CY := 0
    SendMessage 0x1033, 0, 0, , % "ahk_id " . HLV
    CX := ErrorLevel & 0xFFFF, CY := ErrorLevel >> 16
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetItemParam - Retrieves the value of the item's lParam field.
; ======================================================================================================================
LV_EX_GetItemParam(HLV, Row) {
    ; LVM_GETITEM -> http://msdn.microsoft.com/en-us/library/bb774953(v=vs.85).aspx
    Static LVM_GETITEM := A_IsUnicode ? 0x104B : 0x1005 ; LVM_GETITEMW : LVM_GETITEMA
    Static OffParam := 24 + (A_PtrSize * 2)
    LV_EX_LVITEM(LVITEM, 0x00000004, Row) ; LVIF_PARAM
    SendMessage % LVM_GETITEM, 0, % &LVITEM, , % "ahk_id " . HLV
    Return NumGet(LVITEM, OffParam, "UPtr")
}
; ======================================================================================================================
; LV_EX_GetItemRect - Retrieves the bounding rectangle for all or part of an item in the current view.
; ======================================================================================================================
LV_EX_GetItemRect(HLV, Row := 1, LVIR := 0, Byref RECT := "") {
    ; LVM_GETITEMRECT = 0x100E -> http://msdn.microsoft.com/en-us/library/bb761049(v=vs.85).aspx
    VarSetCapacity(RECT, 16, 0)
    NumPut(LVIR, RECT, 0, "Int")
    SendMessage 0x100E, % (Row - 1), % &RECT, , % "ahk_id " . HLV
    If (ErrorLevel = 0)
        Return False
    Result := {}
    Result.X := NumGet(RECT,  0, "Int")
    Result.Y := NumGet(RECT,  4, "Int")
    Result.R := NumGet(RECT,  8, "Int")
    Result.B := NumGet(RECT, 12, "Int")
    Result.W := Result.R - Result.X
    Result.H := Result.B - Result.Y
    Return Result
}
; ======================================================================================================================
; LV_EX_GetItemState - Retrieves the state of a list-view item.
; ======================================================================================================================
LV_EX_GetItemState(HLV, Row) {
    ; LVM_GETITEMSTATE = 0x102C -> http://msdn.microsoft.com/en-us/library/bb761053(v=vs.85).aspx
    Static LVIS := {Cut: 0x04, DropHilited: 0x08, Focused: 0x01, Selected: 0x02, Checked: 0x2000}
    SendMessage 0x102C, % (Row - 1), 0xFFFF, , % "ahk_id " . HLV ; all states
    States := ErrorLevel
    Result := {}
    For Key, Value In LVIS
        Result[Key] := States & Value
    Return Result
}
; ======================================================================================================================
; LV_EX_GetRowHeight - Gets the height of the specified row.
; ======================================================================================================================
LV_EX_GetRowHeight(HLV, Row := 1) {
    Return LV_EX_GetItemRect(HLV, Row).H
}
; ======================================================================================================================
; LV_EX_GetRowsPerPage - Calculates the number of items that can fit vertically in the visible area of a list-view
;                        control when in list or report view. Only fully visible items are counted.
; ======================================================================================================================
LV_EX_GetRowsPerPage(HLV) {
    ; LVM_GETCOUNTPERPAGE = 0x1028 -> http://msdn.microsoft.com/en-us/library/bb774917(v=vs.85).aspx
    SendMessage 0x1028, 0, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GetSubItemRect - Retrieves information about the bounding rectangle for a subitem in a list-view control.
; ======================================================================================================================
LV_EX_GetSubItemRect(HLV, Column, Row := 1, LVIR := 0, ByRef RECT := "") {
    ; LVM_GETSUBITEMRECT = 0x1038 -> http://msdn.microsoft.com/en-us/library/bb761075(v=vs.85).aspx
    VarSetCapacity(RECT, 16, 0)
    NumPut(LVIR, RECT, 0, "Int")
    NumPut(Column - 1, RECT, 4, "Int")
    SendMessage 0x1038, % (Row - 1), % &RECT, , % "ahk_id " . HLV
    If (ErrorLevel = 0)
        Return False
    If (Column = 1) && ((LVIR = 0) || (LVIR = 3))
        NumPut(NumGet(RECT, 0, "Int") + LV_EX_GetColumnWidth(HLV, 1), RECT, 8, "Int")
    Result := {}
    Result.X := NumGet(RECT,  0, "Int"), Result.Y := NumGet(RECT,  4, "Int")
    Result.R := NumGet(RECT,  8, "Int"), Result.B := NumGet(RECT, 12, "Int")
    Result.W := Result.R - Result.X,     Result.H := Result.B - Result.Y
    Return Result
}
; ======================================================================================================================
; LV_EX_GetSubItemText - Retrieves the text of the specified item and subitem.
; ======================================================================================================================
LV_EX_GetSubItemText(HLV, Row, Column := 1, MaxChars := 257) {
    ; LVM_GETITEMTEXT -> http://msdn.microsoft.com/en-us/library/bb761055(v=vs.85).aspx
    Static LVM_GETITEMTEXT := A_IsUnicode ? 0x1073 : 0x102D ; LVM_GETITEMTEXTW : LVM_GETITEMTEXTA
    Static OffText := 16 + A_PtrSize
    Static OffTextMax := OffText + A_PtrSize
    VarSetCapacity(ItemText, MaxChars << !!A_IsUnicode, 0)
    LV_EX_LVITEM(LVITEM, , Row, Column)
    NumPut(&ItemText, LVITEM, OffText, "Ptr")
    NumPut(MaxChars, LVITEM, OffTextMax, "Int")
    SendMessage % LVM_GETITEMTEXT, % (Row - 1), % &LVITEM, , % "ahk_id " . HLV
    VarSetCapacity(ItemText, -1)
    Return ItemText
}
; ======================================================================================================================
; LV_EX_GetTileViewLines - Retrieves the maximum number of additional text lines in each tile, not counting the title.
; ======================================================================================================================
LV_EX_GetTileViewLines(HLV) {
    ; LVM_GETTILEVIEWINFO = 0x10A3 -> http://msdn.microsoft.com/en-us/library/bb774768(v=vs.85).aspx
    Static SizeLVTVI := 40
    Static OffLines := 20
    VarSetCapacity(LVTVI, SizeLVTVI, 0)   ; LVTILEVIEWINFO
    NumPut(SizeLVTVI, LVTVI, 0, "UInt")   ; cbSize
    NumPut(0x00000002, LVTVI, 4, "UInt")  ; dwMask = LVTVIM_COLUMNS
    SendMessage 0x10A3, 0, % &LVTVI, , % "ahk_id " . HLV ; LVM_GETTILEVIEWINFO
    Lines := NumGet(LVTVI, OffLines, "Int")
    Return (Lines > 0 ? --Lines : 0)
}
; ======================================================================================================================
; LV_EX_GetTopIndex - Retrieves the index of the topmost visible item when in list or report view.
; ======================================================================================================================
LV_EX_GetTopIndex(HLV) {
    ; LVM_GETTOPINDEX = 0x1027 -> http://msdn.microsoft.com/en-us/library/bb761087(v=vs.85).aspx
    SendMessage 0x1027, 0, 0, , % "ahk_id " . HLV
    Return (ErrorLevel + 1)
}
; ======================================================================================================================
; LV_EX_GetView - Retrieves the current view of a list-view control.
; ======================================================================================================================
LV_EX_GetView(HLV) {
    ; LVM_GETVIEW = 0x108F -> http://msdn.microsoft.com/en-us/library/bb761091(v=vs.85).aspx
    Static Views := {0x00: "Icon", 0x01: "Report", 0x02: "IconSmall", 0x03: "List", 0x04: "Tile"}
    SendMessage 0x108F, 0, 0, , % "ahk_id " . HLV
    Return Views[ErrorLevel]
}
; ======================================================================================================================
; LV_EX_GroupGetHeader - Gets the header text of a group by group ID
; ======================================================================================================================
LV_EX_GroupGetHeader(HLV, GroupID, MaxChars := 1024) {
    ; LVM_GETGROUPINFO = 0x1095
    Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4)
    Static LVGF_HEADER := 0x00000001
    Static OffHeader := 8
    Static OffHeaderMax := 8 + A_PtrSize
    VarSetCapacity(HeaderText, MaxChars * 2, 0)
    VarSetCapacity(LVGROUP, SizeOfLVGROUP, 0)
    NumPut(SizeOfLVGROUP, LVGROUP, 0, "UInt")
    NumPut(LVGF_HEADER, LVGROUP, 4, "UInt")
    NumPut(&HeaderText, LVGROUP, OffHeader, "Ptr")
    NumPut(MaxChars, LVGROUP, OffHeaderMax, "Int")
    SendMessage 0x1095, %GroupID%, % &LVGROUP, , % "ahk_id " . HLV
    Return StrGet(&HeaderText, MaxChars, "UTF-16")
}
; ======================================================================================================================
; LV_EX_GroupGetState - Get group states (requires Win Vista+ for most states).
; ======================================================================================================================
LV_EX_GroupGetState(HLV, GroupID, ByRef Collapsed := "", ByRef Collapsible := "", ByRef Focused := "", ByRef Hidden := ""
    , ByRef NoHeader := "", ByRef Normal := "", ByRef Selected := "") {
    ; LVM_GETGROUPINFO = 0x1095 -> msdn.microsoft.com/en-us/library/bb774932(v=vs.85).aspx
    Static OS := DllCall("GetVersion", "UChar")
    Static LVGS5 := {Collapsed: 0x01, Hidden: 0x02, Normal: 0x00}
    Static LVGS6 := {Collapsed: 0x01, Collapsible: 0x08, Focused: 0x10, Hidden: 0x02, NoHeader: 0x04, Normal: 0x00, Selected: 0x20}
    Static LVGF := 0x04 ; LVGF_STATE
    Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4)
    Static OffStateMask := 8 + (A_PtrSize * 3) + 8
    Static OffState := OffStateMask + 4
    SetStates := 0
    LVGS := OS > 5 ? LVGS6 : LVGS5
    For Each, State In LVGS
        SetStates |= State
    VarSetCapacity(LVGROUP, SizeOfLVGROUP, 0)
    NumPut(SizeOfLVGROUP, LVGROUP, 0, "UInt")
    NumPut(LVGF, LVGROUP, 4, "UInt")
    NumPut(SetStates, LVGROUP, OffStateMask, "UInt")
    SendMessage 0x1095, %GroupID%, &LVGROUP, , % "ahk_id " . HLV
    States := NumGet(&LVGROUP, OffState, "UInt")
    For Each, State in LVGS
        %Each% := States & State ? True : False
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GroupInsert - Inserts a group into a list-view control.
; ======================================================================================================================
LV_EX_GroupInsert(HLV, GroupID, Header, Align := "", Index := -1) {
    ; LVM_INSERTGROUP = 0x1091 -> msdn.microsoft.com/en-us/library/bb761103(v=vs.85).aspx
    Static Alignment := {1: 1, 2: 2, 4: 4, C: 2, L: 1, R: 4}
    Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4)
    Static OffHeader := 8
    Static OffGroupID := OffHeader + (A_PtrSize * 3) + 4
    Static OffAlign := OffGroupID + 12
    Static LVGF := 0x11 ; LVGF_GROUPID | LVGF_HEADER | LVGF_STATE
    Static LVGF_ALIGN := 0x00000008
    Align := (A := Alignment[SubStr(Align, 1, 1)]) ? A : 0
    Mask := LVGF | (Align ? LVGF_ALIGN : 0)
    PHeader := A_IsUnicode ? &Header : LV_EX_PWSTR(Header, WHeader)
    VarSetCapacity(LVGROUP, SizeOfLVGROUP, 0)
    NumPut(SizeOfLVGROUP, LVGROUP, 0, "UInt")
    NumPut(Mask, LVGROUP, 4, "UInt")
    NumPut(PHeader, LVGROUP, OffHeader, "Ptr")
    NumPut(GroupID, LVGROUP, OffGroupID, "Int")
    NumPut(Align, LVGROUP, OffAlign, "UInt")
    SendMessage 0x1091, %Index%, % &LVGROUP, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GroupRemove - Removes a group from a list-view control.
; ======================================================================================================================
LV_EX_GroupRemove(HLV, GroupID) {
    ; LVM_REMOVEGROUP = 0x1096 -> msdn.microsoft.com/en-us/library/bb761149(v=vs.85).aspx
    SendMessage 0x10A0, %GroupID%, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GroupRemoveAll - Removes all groups from a list-view control.
; ======================================================================================================================
LV_EX_GroupRemoveAll(HLV) {
    ; LVM_REMOVEALLGROUPS = 0x10A0 -> msdn.microsoft.com/en-us/library/bb761147(v=vs.85).aspx
    SendMessage 0x10A0, 0, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_GroupSetState - Set group state (requires Win Vista+ for most states).
; ======================================================================================================================
LV_EX_GroupSetState(HLV, GroupID, States*) {
    ; LVM_SETGROUPINFO = 0x1093 -> msdn.microsoft.com/en-us/library/bb761167(v=vs.85).aspx
    Static OS := DllCall("GetVersion", "UChar")
    Static LVGS5 := {Collapsed: 0x01, Hidden: 0x02, Normal: 0x00, 0: 0, 1: 1, 2: 2}
    Static LVGS6 := {Collapsed: 0x01, Collapsible: 0x08, Focused: 0x10, Hidden: 0x02, NoHeader: 0x04, Normal: 0x00
            , Selected: 0x20, 0: 0, 1: 1, 2: 2, 4: 4, 8: 8, 16: 16, 32: 32}
    Static LVGF := 0x04 ; LVGF_STATE
    Static SizeOfLVGROUP := (4 * 6) + (A_PtrSize * 4)
    Static OffStateMask := 8 + (A_PtrSize * 3) + 8
    Static OffState := OffStateMask + 4
    SetStates := 0
    LVGS := OS > 5 ? LVGS6 : LVGS5
    For _, State In States {
        If !LVGS.HasKey(State)
            Return False
        SetStates |= LVGS[State]
    }
    VarSetCapacity(LVGROUP, SizeOfLVGROUP, 0)
    NumPut(SizeOfLVGROUP, LVGROUP, 0, "UInt")
    NumPut(LVGF, LVGROUP, 4, "UInt")
    NumPut(SetStates, LVGROUP, OffStateMask, "UInt")
    NumPut(SetStates, LVGROUP, OffState, "UInt")
    SendMessage 0x1093, %GroupID%, % &LVGROUP, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_HasGroup - Determines whether the list-view control has a specified group.
; ======================================================================================================================
LV_EX_HasGroup(HLV, GroupID) {
    ; LVM_HASGROUP = 0x10A1 -> msdn.microsoft.com/en-us/library/bb761097(v=vs.85).aspx
    SendMessage 0x10A1, %GroupID%, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_IsGroupViewEnabled - Checks whether the list-view control has group view enabled.
; ======================================================================================================================
LV_EX_IsGroupViewEnabled(HLV) {
    ; LVM_ISGROUPVIEWENABLED = 0x10AF -> msdn.microsoft.com/en-us/library/bb761133(v=vs.85).aspx
    SendMessage 0x10AF, 0, 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_IsRowChecked - Indicates if a row in the list-view control is checked.
; ======================================================================================================================
LV_EX_IsRowChecked(HLV, Row) {
    Return LV_EX_GetItemState(HLV, Row).Checked
}
; ======================================================================================================================
; LV_EX_IsRowFocused - Indicates if a row in the list-view control is focused.
; ======================================================================================================================
LV_EX_IsRowFocused(HLV, Row) {
    Return LV_EX_GetItemState(HLV, Row).Focused
}
; ======================================================================================================================
; LV_EX_IsRowSelected - Indicates if a row in the list-view control is selected.
; ======================================================================================================================
LV_EX_IsRowSelected(HLV, Row) {
    Return LV_EX_GetItemState(HLV, Row).Selected
}
; ======================================================================================================================
; LV_EX_IsRowVisible - Indicates if a row in the list-view control is visible.
; ======================================================================================================================
LV_EX_IsRowVisible(HLV, Row) {
    ; LVM_ISITEMVISIBLE = 0x10B6 -> http://msdn.microsoft.com/en-us/library/bb761135(v=vs.85).aspx
    SendMessage 0x10B6, % (Row - 1), 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; CommCtrl.h:
; // These next to methods make it easy to identify an item that can be repositioned
; // within listview. For example: Many developers use the lParam to store an identifier that is
; // unique. Unfortunatly, in order to find this item, they have to iterate through all of the items
; // in the listview. Listview will maintain a unique identifier.  The upper bound is the size of a DWORD.
; ======================================================================================================================
; LV_EX_MapIDToIndex - Maps the ID of an item to an index.
; ======================================================================================================================
LV_EX_MapIDToIndex(HLV, ID) {
    ; LVM_MAPIDTOINDEX = 0x10B5 -> http://msdn.microsoft.com/en-us/library/bb761137(v=vs.85).aspx
    SendMessage 0x10B5, % ID, 0, , % "ahk_id " . HLV
    Return (ErrorLevel + 1)
}
; ======================================================================================================================
; LV_EX_MapIndexToID - Maps the index of an item to an unique ID.
; ======================================================================================================================
LV_EX_MapIndexToID(HLV, Index) {
    ; LVM_MAPINDEXTOID = 0x10B4 -> http://msdn.microsoft.com/en-us/library/bb761139(v=vs.85).aspx
    SendMessage 0x10B4, % (Index - 1), 0, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_RedrawRows - Forces a list-view control to redraw a range of items.
; ======================================================================================================================
LV_EX_RedrawRows(HLV, First := 0, Last := "") {
    ; LVM_REDRAWITEMS = 0x1015 -> http://msdn.microsoft.com/en-us/library/bb761145(v=vs.85).aspx
    If (First > 0) {
        If (Last = "")
            Last := First
    }
    Else {
        First := LV_EX_GetTopIndex(HLV)
        Last := First + LV_EX_GetRowsPerPage(HLV) - 1
    }
    SendMessage 0x1015, % (First - 1), % (Last - 1), , % "ahk_id " . HLV
    If (ErrorLevel)
        Return DllCall("User32.dll\UpdateWindow", "Ptr", HLV, "UInt")
    Return False
}
; ======================================================================================================================
; LV_EX_SetBkImage - Sets the background image in a list-view control.
; ======================================================================================================================
LV_EX_SetBkImage(HLV, ImgPath, Width := "", Height := "") {
    ; LVM_SETBKIMAGEA := 0x1044 -> http://msdn.microsoft.com/en-us/library/bb761155(v=vs.85).aspx
    ;@ahk-neko-ignore-fn 1 line; at 9/18/2023, 12:40:14 PM ; var is assigned but never used.
    Static XAlign := {C: 50, L: 0, R: 100}, YAlign := {B: 100, C: 50, T: 0}
    Static KnownCtrls := []
    Static OSVERSION := DllCall("Kernel32.dll\GetVersion", "UInt") & 0xFF
    HBITMAP := 0
    If (ImgPath) && FileExist(ImgPath) {
        If (Width = "") && (Height = "") {
            VarSetCapacity(RECT, 16, 0)
            DllCall("User32.dll\GetClientRect", "Ptr", HLV, "Ptr", &RECT)
            Width := NumGet(RECT, 8, "Int"), Height := NumGet(RECT, 12, "Int")
        }
        HMOD := DllCall("Kernel32.dll\LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
        VarSetCapacity(SI, 24, 0), NumPut(1, SI, "UInt")
        DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", Token, "Ptr", &SI, "Ptr", 0)
        DllCall("Gdiplus.dll\GdipCreateBitmapFromFile", "WStr", ImgPath, "PtrP", Bitmap)
        DllCall("Gdiplus.dll\GdipCreateHBITMAPFromBitmap", "Ptr", Bitmap, "PtrP", HBITMAP, "UInt", 0x00FFFFFF)
        DllCall("Gdiplus.dll\GdipDisposeImage", "Ptr", Bitmap)
        DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", Token)
        DllCall("Kernel32.dll\FreeLibrary", "Ptr", HMOD)
        HBITMAP := DllCall("User32.dll\CopyImage"
            , "Ptr", HBITMAP, "UInt", 0, "Int", Width, "Int", Height, "UInt", 0x2008, "UPtr")
        If !(HBITMAP)
            Return False
    }
    ; Set extended style LVS_EX_DOUBLEBUFFER to avoid drawing issues
    If !KnownCtrls.HasKey(HLV) {
        LV_EX_SetExtendedStyle(HLV, 0x00010000, 0x00010000) ; LVS_EX_DOUBLEBUFFER = 0x00010000
        KnownCtrls[HLV] := True
    }
    Flags := 0x10000000 ; LVBKIF_TYPE_WATERMARK
    If (HBITMAP) && (OSVERSION >= 6) ; LVBKIF_FLAG_ALPHABLEND prevents that the image will be shown on WinXP
        Flags |= 0x20000000 ; LVBKIF_FLAG_ALPHABLEND
    LVBKIMAGESize :=  A_PtrSize = 8 ? 40 : 24
    VarSetCapacity(LVBKIMAGE, LVBKIMAGESize, 0)
    NumPut(Flags, LVBKIMAGE, 0, "UInt")
    NumPut(HBITMAP, LVBKIMAGE, A_PtrSize, "UPtr")
    SendMessage 0x1044, 0, % &LVBKIMAGE, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetColumnOrder - Sets the left-to-right order of columns in a list-view control.
; ======================================================================================================================
LV_EX_SetColumnOrder(HLV, ColArray) {
    ; LVM_SETCOLUMNORDERARRAY = 0x103A -> http://msdn.microsoft.com/en-us/library/bb761161(v=vs.85).aspx
    Cols := ColArray.MaxIndex()
    VarSetCapacity(COA, Cols * 4, 0)
    For I, C In ColArray
        NumPut(C - 1, COA, (I - 1) * 4, "Int")
    SendMessage 0x103A, % Cols, % &COA, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetExtendedStyle - Sets extended styles in list-view controls.
; ======================================================================================================================
LV_EX_SetExtendedStyle(HLV, StyleMsk, Styles) {
    ; LVM_SETEXTENDEDLISTVIEWSTYLE = 0x1036 -> http://msdn.microsoft.com/en-us/library/bb761165(v=vs.85).aspx
    SendMessage 0x1036, % StyleMsk, % Styles, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetGroup - Assigns a list-view item to an existing group.
; ======================================================================================================================
LV_EX_SetGroup(HLV, Row, GroupID) {
    ; LVM_SETITEMA = 0x1006 -> http://msdn.microsoft.com/en-us/library/bb761186(v=vs.85).aspx
    Static OffGroupID := 28 + (A_PtrSize * 3)
    LV_EX_LVITEM(LVITEM, 0x00000100, Row) ; LVIF_GROUPID
    NumPut(GroupID, LVITEM, OffGroupID, "UPtr")
    SendMessage 0x1006, 0, % &LVITEM, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetIconSpacing - Sets the spacing between icons in the icon view.
; ======================================================================================================================
LV_EX_SetIconSpacing(HLV, CX, CY) {
    ; LVM_SETICONSPACING = 0x1035 -> http://msdn.microsoft.com/en-us/library/bb761176(v=vs.85).aspx
    If (CX < 4) && (CX <> -1)
        CX := 4
    If (CY < 4) && (CY <> -1)
        CY := 4
    SendMessage 0x1035, 0, % (CX & 0xFFFF) | ((CY & 0xFFFF) << 16), , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetItemIndent - Sets the indent of the first column to the specified number of icon widths.
; ======================================================================================================================
LV_EX_SetItemIndent(HLV, Row, NumIcons) {
    ; LVM_SETITEMA = 0x1006 -> http://msdn.microsoft.com/en-us/library/bb761186(v=vs.85).aspx
    Static OffIndent := 24 + (A_PtrSize * 3)
    LV_EX_LVITEM(LVITEM, 0x00000010, Row) ; LVIF_INDENT
    NumPut(NumIcons, LVITEM, OffIndent, "Int")
    SendMessage 0x1006, 0, % &LVITEM, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetItemParam - Sets the lParam field of the item to the specified value.
; ======================================================================================================================
LV_EX_SetItemParam(HLV, Row, Value) {
    ; LVM_SETITEMA = 0x1006 -> http://msdn.microsoft.com/en-us/library/bb761186(v=vs.85).aspx
    Static OffParam := 24 + (A_PtrSize * 2)
    LV_EX_LVITEM(LVITEM, 0x00000004, Row) ; LVIF_PARAM
    NumPut(Value, LVITEM, OffParam, "UPtr")
    SendMessage 0x1006, 0, % &LVITEM, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetSubItemImage - Assigns an image from the list-view's image list to this subitem.
; ======================================================================================================================
LV_EX_SetSubItemImage(HLV, Row, Column, Index) {
    ; LVM_SETITEMA = 0x1006 -> http://msdn.microsoft.com/en-us/library/bb761186(v=vs.85).aspx
    Static KnownCtrls := []
    Static OffImage := 20 + (A_PtrSize * 2)
    If !KnownCtrls.HasKey(HLV) {
        LV_EX_SetExtendedStyle(HLV, 0x00000002, 0x00000002) ; LVS_EX_SUBITEMIMAGES = 0x00000002
        KnownCtrls[HLV] := True
    }
    LV_EX_LVITEM(LVITEM, 0x00000002, Row, Column) ; LVIF_IMAGE
    NumPut(Index - 1, LVITEM, OffImage, "Int")
    SendMessage 0x1006, 0, % &LVITEM, , % "ahk_id " . HLV
    Return ErrorLevel
}
; ======================================================================================================================
; LV_EX_SetTileInfo - Sets the additional columns displayed for this tile, and the order of those columns.
; ======================================================================================================================
LV_EX_SetTileInfo(HLV, Row, Columns*) {
    ; Row      : The 1-based row number. If you specify a number less than 1, the tile info will be set for all rows.
    ; Colomns* : Array of column indices, specifying which columns are displayed for this item, and the order of those
    ;            columns. Indices should be greater than 1, because column 1, the item name, is already displayed.
    ; LVM_SETTILEINFO = 0x10A4 -> http://msdn.microsoft.com/en-us/library/bb761210(v=vs.85).aspx
    Static SizeLVTI := (4 * 2) + (A_PtrSize * 2)
    Static OffItem := 4
    Static OffCols := 8
    Static OffColArr := OffCols + A_PtrSize
    ColCount := (CC := Columns.MaxIndex()) = "" ? 0 : CC
    Lines := LV_EX_GetTileViewLines(HLV)
    If ((Row = 0) && (ColCount <> Lines)) || ((Row <> 0) && (ColCount >= Lines))
        LV_EX_SetTileViewLines(HLV, ColCount)
    VarSetCapacity(ColArr, 4 * (ColCount + 1), 0)
    Addr := &ColArr
    For _, Column In Columns
        Addr := NumPut(Column - 1, Addr + 0, "UInt")
    VarSetCapacity(LVTI, SizeLVTI, 0)       ; LVTILEINFO
    NumPut(SizeLVTI, LVTI, 0, "UInt")       ; cbSize
    NumPut(ColCount, LVTI, OffCols, "UInt") ; cColumns
    NumPut(&ColArr, LVTI, OffColArr, "Ptr") ; puColumns
    If (Row > 0) {
        NumPut(Row - 1, LVTI, OffItem, "Int") ; iItem
        SendMessage 0x10A4, 0, % &LVTI, , % "ahk_id " . HLV ; LVM_SETTILEINFO
        Return ErrorLevel
    }
    SendMessage 0x1004, 0, 0, , % "ahk_id " . HLV ; LVM_GETITEMCOUNT
    Loop, % ErrorLevel {
        NumPut(A_Index - 1, LVTI, OffItem, "Int") ; iItem
        SendMessage 0x10A4, 0, % &LVTI, , % "ahk_id " . HLV ; LVM_SETTILEINFO
        If !(ErrorLevel)
            Return ErrorLevel
    }
    Return True
}
; ======================================================================================================================
; LV_EX_SetTileViewLines - Sets the maximum number of additional text lines in each tile, not counting the title.
; ======================================================================================================================
;LV_EX_SetTileViewLines(HLV, Lines) {
;   ; Lines : Maximum number of text lines in each item label, not counting the title.
;   ; LVM_GETTILEVIEWINFO = 0x10A3 -> http://msdn.microsoft.com/en-us/library/bb761083(v=vs.85).aspx
;   ; LVM_SETTILEVIEWINFO = 0x10A2 -> http://msdn.microsoft.com/en-us/library/bb761212(v=vs.85).aspx
;   ; One line is added internally because the item might be wrapped to two lines!
;   Static SizeLVTVI := 40
;   Static OffLines := 20
;   If (Lines > 0)
;      Lines++
;   VarSetCapacity(LVTVI, SizeLVTVI, 0)     ; LVTILEVIEWINFO
;   NumPut(SizeLVTVI, LVTVI, 0, "UInt")     ; cbSize
;   NumPut(0x00000003, LVTVI, 4, "UInt")    ; dwMask = LVTVIM_TILESIZE | LVTVIM_COLUMNS
;   NumPut(Lines, LVTVI, OffLines, "Int") ; c_lines: max lines below first line
;   SendMessage, 0x10A2, 0, % &LVTVI, , % "ahk_id " . HLV ; LVM_SETTILEVIEWINFO
;   Return ErrorLevel
;}
; ======================================================================================================================
; LV_EX_SubItemHitTest - Gets the column (subitem) at the passed coordinates or the position of the mouse cursor.
; ======================================================================================================================
LV_EX_SubItemHitTest(HLV, X := -1, Y := -1) {
    ; LVM_SUBITEMHITTEST = 0x1039 -> http://msdn.microsoft.com/en-us/library/bb761229(v=vs.85).aspx
    VarSetCapacity(LVHTI, 24, 0) ; LVHITTESTINFO
    If (X = -1) || (Y = -1) {
        DllCall("User32.dll\GetCursorPos", "Ptr", &LVHTI)
        DllCall("User32.dll\ScreenToClient", "Ptr", HLV, "Ptr", &LVHTI)
    }
    Else {
        NumPut(X, LVHTI, 0, "Int")
        NumPut(Y, LVHTI, 4, "Int")
    }
    SendMessage 0x1039, 0, % &LVHTI, , % "ahk_id " . HLV
    Return (ErrorLevel > 0x7FFFFFFF ? 0 : NumGet(LVHTI, 16, "Int") + 1)
}
; ======================================================================================================================
; ======================================================================================================================
; Function for internal use ============================================================================================
; ======================================================================================================================
; ======================================================================================================================
LV_EX_LVITEM(ByRef LVITEM, Mask := 0, Row := 1, Col := 1) {
    Static LVITEMSize := 48 + (A_PtrSize * 3)
    VarSetCapacity(LVITEM, LVITEMSize, 0)
    NumPut(Mask, LVITEM, 0, "UInt"), NumPut(Row - 1, LVITEM, 4, "Int"), NumPut(Col - 1, LVITEM, 8, "Int")
}
; ----------------------------------------------------------------------------------------------------------------------
LV_EX_PWSTR(Str, ByRef WSTR) { ; ANSI to Unicode
    VarSetCapacity(WSTR, StrPut(Str, "UTF-16") * 2, 0)
    StrPut(Str, &WSTR, "UTF-16")
    Return &WSTR
}
SetExplorerTheme(HCTL) { ; HCTL : handle of a ListView or TreeView control ;; just me, https://www.autohotkey.com/boards/viewtopic.php?p=49416#p49416
    If (DllCall("GetVersion", "UChar") > 5) {
        VarSetCapacity(ClassName, 1024, 0)
        If DllCall("GetClassName", "Ptr", HCTL, "Str", ClassName, "Int", 512, "Int")
            If (ClassName = "SysListView32") || (ClassName = "SysTreeView32")
                Return !DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HCTL, "WStr", "Explorer", "Ptr", 0)
    }
    Return False
}
; #region:RegexMatchAll/RegexMatchLines (3010221476)

; #region:Metadata:
; Snippet: RegexMatchAll/RegexMatchLines;  (v.1.0)
; --------------------------------------------------------------
; Author: u/anonymous1184
; License: none
; Source: https://www.reddit.com/r/AutoHotkey/comments/12l4gr8/comment/jg6ngt7/?utm_source=reddit&utm_medium=web2x&context=3
; (14 April 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 05 - String/Array/Text
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------
; Keywords: Regex
; #endregion:Metadata

; #region:Example
; for _, match in matches {
;     text := StrReplace(text, match[0])
; }
; #endregion:Example


; #region:Code
RegExMatchAll(Haystack, NeedleRegEx, StartingPosition := 1) {
    out := []
    RegExMatch(NeedleRegEx, "^([imsxADJUXPOSC`r`n`a]+)?\)?(.+)", match)
    NeedleRegEx := "O" StrReplace(match1, "O") ")" match2
    loop {
        StartingPosition := RegExMatch(Haystack, NeedleRegEx, match, StartingPosition)
        if (!StartingPosition)
            break
        StartingPosition += match.Len(0)
        out.Push(match)
    }
    return out
}

RegExMatchLines(Haystack, NeedleRegEx) {
    out := []
    RegExMatch(NeedleRegEx, "^([imsxADJUXPOSC``nra]+)?\)?(.+)", match)
    NeedleRegEx := "O" StrReplace(match1, "O") ")" match2
    for _, line in StrSplit(Haystack, "`n", "`r") {
        if (RegExMatch(line, NeedleRegEx, match))
            out.Push(match)
    }
    return out
}
; #endregion:Code


; #endregion:RegexMatchAll/RegexMatchLines (3010221476)
checkDecimalsOnEdit(hEdit) ;wolf_II: check for number incl. decimal point
{ ;https://www.autohotkey.com/boards/viewtopic.php?f=76&t=31251&start=20
    ;-------------------------------------------------------------------------------
    static PrevNumber := [], Warning := "You can only enter a number!"
        , BadNeedle := "[^\d\.]"    ; "[^\d\.-]|^.+-"
    ControlGet Pos, CurrentCol,,, ahk_id %hEdit%
    GuiControlGet NewNumber,, %hEdit%
    StrReplace(NewNumber, ".",, DotCount)
    If NewNumber ~= BadNeedle Or DotCount > 1
    { ; BAD
        ControlGetPos x, y,,,, ahk_id %hEdit%
        ToolTip %Warning%, x, y-20
        SetTimer ToolTipOff, -2000
        GuiControl,, %hEdit%, % PrevNumber[hEdit]
        SendMessage 0xB1, % Pos-2, % Pos-2,, ahk_id %hEdit%
    }
    Else ; GOOD
        PrevNumber[hEdit] := NewNumber
    Return
    ToolTipOff:
    ToolTip ; off
    Return
}
; #region:Deref (3534284804)
; #region:Metadata:
; Snippet: Deref;  (v.1)
; --------------------------------------------------------------
; License: GNU GPLv2
; LicenseURL: https://www.autohotkey.com/docs/v1/license.htm
; Source: https://www.autohotkey.com/docs/v1/lib/RegExMatch.htm#ExDeref
; (22 April 2023)
; --------------------------------------------------------------
; Library: Personal Library
; Section: 07 - Variables
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------

; #endregion:Metadata

; #region:Description:
; Replace Variable references in-String
;
; Similar to Transform Deref, the following function expands variable references and escape sequences contained inside other variables.
; Furthermore, this example shows how to find all matches in a string rather than stopping at the first match (similar to the g flag in JavaScript's RegEx).
; #endregion:Description

; #region:Example
; var1 := "abc"
; var2 := 123
; MsgBox % Deref("%var1%def%var2%")  ; Reports abcdef123.
; #endregion:Example

; #region:Code
Deref(String) {
    spo := 1
    out := ""
    while (fpo := RegexMatch(String, "(%(.*?)%)|``(.)", m, spo)) {
        out .= SubStr(String, spo, fpo - spo)
        spo := fpo + StrLen(m)
        if (m1) {
            out .= %m2%
        } else switch (m3) {
        case "a": out .= "`a"
        case "b": out .= "`b"
        case "f": out .= "`f"
        case "n": out .= "`n"
        case "r": out .= "`r"
        case "t": out .= "`t"
        case "v": out .= "`v"
        default: out .= m3
        }
    }
    return out SubStr(String, spo)
}
; #endregion:Code

; #region:License
; License could not be copied, please retrieve manually from 'https://www.autohotkey.com/docs/v1/license.htm'
;
; #endregion:License

; #endregion:Deref (3534284804)
convertCSV2XLSX(dynGUI){
    if (dynGUI.GFA_Evaluation_Configfile_Location!="") {
        if (FileExist(dynGUI.GFA_Evaluation_Configfile_Location)) {
            SplitPath % dynGUI.GFA_Evaluation_Configfile_Location,, SearchDirectory
            if (csv2xlsx(SearchDirectory,true)) {
                ttip("Created missing xlsx-files for csv-files without xlsx-complements in " SearchDirectory ".")
            } else {
                ttip("There were no missing xlsx-files in subfolders of " SearchDirectory ".")
            }
        } else {
            ttip("The selected configuration file '" dynGUI.GFA_Evaluation_Configfile_Location "' does not exist.")
        }
    } else {
        ttip("No configuration file has been selected yet.")
    }
}
csv2xlsx(StartDir:="",replaceDotsToCommas:=false) {
    modified:=0
    Loop, Files,% StartDir "\*.csv",R
    {
        SplitPath A_LoopFileFullPath, , OutDir, , OutNameNoExt
        if (!FileExist(OutDir "\" OutNameNoExt ".xlsx")) {
            FileRead Content, % A_LoopFileFullPath
            if (replaceDotsToCommas) {
                Content_new:=replaceDotsinCSV(Content)
            } else {
                Content_new:=Content
            }
            writeFile(A_LoopFileFullPath,Content_new,,,True)
            xl := ComObjCreate("Excel.Application")
            xl.Workbooks.Open(A_LoopFileFullPath)
            xl.ActiveWorkbook.SaveAs(OutDir . "\" . OutNameNoExt . ".xlsx", 51) ; same folder, same name, .xls extension
            xl.ActiveWorkbook.Close
            xl.quit
            modified++
        }
    }
    return modified
}
replaceDotsinCSV(Content) {
    Content_new:=StrReplace(Content,".",",")
    return Content_new
}   
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

StdErr_Write(LineNumber:="", text:="", spec = "") {
    if IsObject(LineNumber) {
        text:=LineNumber.Message
        spec:=LineNumber.What
        File:=LineNumber.File
        LineNumber:=LineNumber.Line
    }
    text := (File!=""?File:A_ScriptFullPath) " (" LineNumber ") : ==>  " . text
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
      For _, File In FileArray
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
; --uID:4117059000
; Metadata:
; Snippet: CountFilesR()
; 09 Oktober 2022
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------


;; Description:
;; count files recursive in specific folder (uses COM method)
;;
;;

CountFilesR(Folder, callIndex) {																			                                                                    	;-- count files recursive in specific folder (uses COM method)
  static Counter = 0, fso, ci
  if (ci = "")
    ci := callIndex
  else if (callIndex > ci) {
    Counter := 0
  }
  fso := fso ? fso : ComObjCreate("Scripting.FileSystemObject")
  Folder := fso.GetFolder(Folder), Counter += Counter ? 0 : CountFiles(Folder.path)
  For Subfolder in Folder.SubFolders
    Counter += CountFiles(Subfolder.path), CountFilesR(Subfolder.path, Counter)
  return Counter
}


; --uID:4117059000

; --uID:22831245
; Metadata:
; Snippet: CountFiles()
; 09 Oktober 2022
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 10 - Filesystem
; Dependencies: /
; AHK_Version: v1
; --------------------------------------------------------------


;; Description:
;; count files in specific folder (uses COM method)
;;
;;

CountFiles(Folder) {                                                                                                                                                 	;-- count files in specific folder (uses COM method)
  fso := ComObjCreate("Scripting.FileSystemObject")
  Folder := fso.GetFolder(Folder)
  return fso.GetFolder(Folder).Files.Count
}


; --uID:22831245
renameImages(dynGUI) {
    if (dynGUI.GFA_Evaluation_Configfile_Location!="") {
        if (FileExist(dynGUI.GFA_Evaluation_Configfile_Location)) {
            SplitPath % dynGUI.GFA_Evaluation_Configfile_Location,, OutDir,
            GFAR_createGUI(dynGUI.Arguments.PotsPerGroup.Value,dynGUI.Arguments.UniqueGroups.Value,OutDir,dynGUI)
        } else {
            ttip("The selected configuration file '" dynGUI.GFA_Evaluation_Configfile_Location "' does not exist.")
        }
    } else {
        ttip("No configuration file has been selected yet.")
    }
}

GFAR_createGUI(PotsPerGroup,UniqueGroups,SearchStartLocation,dynGUI) {
    ;global
    global CHSNFLDR_STRING
    global gfarFolder
    global gfarNames
    global gfarPlantsPerGroup
    global GFARGui
    oH:=dynGUI.GCHWND
    ypos:=A_ScreenHeight-500
    xpos:=A_ScreenWidth-440
    gui GFAR: destroy
    gui GFAR: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +hwndGFARGui +Owner%oH% +LabelGFAR
    gui Font, s10
    gui add, text,vCHSNFLDR_STRING,% "Please drag and drop the folder you want to use on this window.`n`nChosen folder:"
    SelectedFolder:=SelectFolder(SearchStartLocation,"Select Folder containing images to be renamed")
    if (SelectedFolder="") {
        return
    }
    try {
        LastRunCount:=false
        if FileExist(SelectedFolder) {
            LastRunCount:=CountFiles(SelectedFolder)
        }
    } catch e {
        ttip(e)
    }
    if (LastRunCount) {
        gui add, Edit, w400 h110 vgfarFolder disabled, % SelectedFolder
    } else {
        gui add, Edit, w400 h110 vgfarFolder disabled,
    }
    gui add, text,, % "Enter Group names, delimited by a comma ','."
    gui add, edit, vgfarNames w200, % UniqueGroups
    gui add, text,, % "Please set the number of pots/plants per group.`nValue must be an integer."
    gui add, edit, vgfarPlantsPerGroup w200, % PotsPerGroup
    gui add, Button, vSubmitButton gGFARSubmit, &Submit
    gui add, Button, xp+60 hwndhwndgfarreselectfolder, Select &Different Folder
    onReselectFolder:=Func("GFARReselectFolder").Bind(SearchStartLocation)
    guicontrol +g,%hwndgfarreselectfolder%,% onReselectFolder
    gui font, s7
    gui add, text,ypos+20 x350,% "v." script.version " by ~Gw"
    gui GFAR: show, w430 x%xpos% y%ypos% ,% "Drop folder with images on this window"
    GUI %oH%: +Disabled
}

GFARReselectFolder(SearchStartLocation) {
    SelectedFolder:=SelectFolder(SearchStartLocation,"Select Folder containing images to be renamed")
    try {
        LastRunCount:=false
        if FileExist(SelectedFolder) {
            LastRunCount:=CountFiles(SelectedFolder)
        }
    } catch e {
        ttip(e)
    }
    if (LastRunCount) {
        guicontrol ,, gfarFolder,% SelectedFolder
    } else {

    }
}
#if WinActive("ahk_id " GFARGui)
!F4::GFAREscape()
#if WinActive("ahk_id " GFAR_ExcludeGui)
!F4::GFAR_ExcludeEscape()
#if
GFAREscape() {
    global dynGUI
    gui GFAR: destroy
    oH:=dynGUI.GCHWND
    GUI %oH%: -Disabled
}

GFARSubmit() {
    global
    gui GFAR: Submit, NoHide
    oH:=dynGUI.GCHWND
    GUI %oH%: +Disabled
    if (gfarNames="") {
        ttip("Please provide the number of pots/plants per group.")
    }
    if (gfarPlantsPerGroup="") {
        ttip("Please provide the number of pots/plants per group.")
    }
    if (gfarFolder="") {
        ttip("Please provide a Folder containing the images you want to name by dragging it onto this window.")
    }
    Arr:=""
    Arr:={}
    script.config.LastRun.Folder:=gfarFolder
    script.config.LastRun.Names:=gfarNames
    script.config.LastRun.PlantsPerGroup:=gfarPlantsPerGroup
    if (InStr(gfarPlantsPerGroup,",")) { ;; we have designated group sizes
        Counts:=strsplit(gfarPlantsPerGroup,",")
        GroupNames:=strsplit(gfarNames,",")
        if (Counts.Count() != GroupNames.Count()) {
            AppError("Parameters incompatible", "You provided a list of varying number of pots/plants per group: `n" gfarPlantsPerGroup "`n for " Counts.Count() " groups`, but also provided names for " GroupNames.Count() " groups:`n" gfarNames "`n`nPlease fix this error by aligning both.")
            return
        }
        for each, Name in GroupNames {
            loop, % Counts[each] {
                Arr.push(Name " (" A_Index ")")
            }
        }
        LoopCount:=gfarPlantsPerGroup*strsplit(gfarNames,",").Count()
        loop % LoopCount
        {
            bReset:=(!(mod(A_Index,gfarPlantsPerGroup))) ;; force a reset in call_index every 'PlantsPerGroup'
            GroupName:=repeatElementIofarrayNKtimes(strsplit(gfarNames,","),gfarPlantsPerGroup,bReset,gfarNames)
            Number:=repeatIndex(gfarPlantsPerGroup)
            Arr.push(GroupName " (" Number ")")
        }
    } else {

        LoopCount:=gfarPlantsPerGroup*strsplit(gfarNames,",").Count()
        loop % LoopCount
        {
            bReset:=(!(mod(A_Index,gfarPlantsPerGroup))) ;; force a reset in call_index every 'PlantsPerGroup'
            GroupName:=repeatElementIofarrayNKtimes(strsplit(gfarNames,","),gfarPlantsPerGroup,bReset,gfarNames)
            Number:=repeatIndex(gfarPlantsPerGroup)
            Arr.push(GroupName " (" Number ")")
        }
    }
    TrueNumberOfFiles:=0
    ImagePaths:=[]

    query:=gfarFolder "\*." script.config.GFA_Renamer_settings.filetype
    Loop, Files, % query, % (bTestSet?"FR":"F")
    {
        if (InStr(A_LoopFileDir,"GFAR_WD")) {
            continue
        }
        ImageF:=A_LoopFileFullPath
        TrueNumberOfFiles++
        ImagePaths.Push(A_LoopFileFullPath)
        if (A_Index=1) {
            TEST_FOLDERPATH:=A_LoopFileDir
        }
    }
    str:="Number of Images that would be renamed given the settings provided: " Arr.Count() "`nFound number of images: " TrueNumberOfFiles "`n"
    Files:=str
    /*
    Think aobut what should happen if you have less images than names - this makes the GUI unfitting for renaming,
    cuz you'd have to recursively look at every image to verify its name, then recurse to exclude names from the array
    until you have them all line up again.
    */
    if (ImagePaths.Count() > Arr.Count()) {
        AppError("More images than names defined", "The folder you provided contains " ImagePaths.Count() " images. The combination of the 'number of groups' and 'plants per group' you provided only allows for renaming " Arr.Count() " images."
            . "`nBe aware that only those first " Arr.Count() " images will be renamed, (and copied to the clipboard)")
        ImageF:=ImagePaths[Arr.Count()]
    }
    gui GFAR_Exclude: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +hwndGFAR_ExcludeGui
    gui GFAR_Exclude: +OwnerGFAR +LabelGFAR_Exclude
    gui GFAR: +disabled
    gui Font, s10
    gui add, text,,% "Please UNTICK any name you do not have an image for (at that position).`nNotes:`n - Files are not actually skipped. Instead, by unticking a row you prevent the name of a pot that you don't have an image`nof from being applied to the 'next-in-line' image.)`n - Double-click an entry in this list to view the image`n - Select an image and press F2 if you want to change the name it will be assigned (and you know what you are doing.)"
    gui add, Listview, Checked vvLV_SelectedEntries w700 R30 -ReadOnly WantF2 Report gGFAR_ExcludeInspectSelection, Name | Expected Filepath
    ImagePaths2:=ForceOrder(ImagePaths)
    f_UpdateLV(Arr,ImagePaths2)
    gui add, text,, % "Images/Names: (" ImagePaths.Count() "/" Arr.Count() ")"
    gui add, Button, hwndhwndDuplicateShiftFrame vvGFAR_DuplicatetoShiftFrame disabled, &Duplicate to shift frame
    gui add, Button,yp xp+170 vvGFAR_ExcludeSubmitButton gGFAR_ExcludeSubmit, &Continue
    fGFAR_DuplicatetoShiftFrame:=Func("GFAR_DuplicatetoShiftFrame").Bind(TEST_FOLDERPATH)
    guicontrol +g, %hwndDuplicateShiftFrame%, % fGFAR_DuplicatetoShiftFrame
    GFAR_LastImage:=Func("GFAR_ExcludeOpenPath").Bind(ImageF)
    gui add, Button, yp xp+80 hwndGFAR_ExcludeOpenLastImage,Open &Last image
    GuiControl +g, %GFAR_ExcludeOpenLastImage%, % GFAR_LastImage

    GFAR_OpenFolder:=Func("GFAR_ExcludeOpenPath").Bind(gfarFolder)
    GFAR_OpenSelectedImage:=Func("GFAR_ExcludeInspectSelection").Bind(gfarFolder)
    gui add, Button, yp xp+130 hwndGFAR_ExcludeOpenFolder,Open &Folder
    gui add, Button, yp xp+130 hwndGFAR_ExcludeInspect, Open &Selected Image
    GuiControl +g, %GFAR_ExcludeOpenFolder%, % GFAR_OpenFolder
    GuiControl +g, %GFAR_ExcludeInspect%, % GFAR_OpenSelectedImage
    if (ImagePaths.Count()<Arr.Count()) {
        guicontrol GFAR_Exclude: Disable,vGFAR_ExcludeSubmitButton
        guicontrol GFAR_Exclude: Enable,vGFAR_DuplicatetoShiftFrame
    } else {
        guicontrol GFAR_Exclude: Enable,vGFAR_ExcludeSubmitButton
        guicontrol GFAR_Exclude: Disable,vGFAR_DuplicatetoShiftFrame
    }
    gui GFAR_Exclude: show, AutoSize,% "Exclude Names"
    WinWaitClose % "Exclude Names"
    return
}

GFAR_DuplicatetoShiftFrame(TEST_FOLDERPATH) {
    global
    static SourceImagesToDelete:=[]

    sel:=GFARgetSelectedLVEntries()
    sel2:=strsplit(sel[1],"||")
    Delim:=(SubStr(Folder, -1 )!="\"?"\":"")
    if (TEST_FOLDERPATH!="") {
        InspectedImage:=TEST_FOLDERPATH Delim sel2[3] "." script.config.GFA_Renamer_settings.filetype
        Padding_Name:=TEST_FOLDERPATH Delim sel2[3] " (padding)." script.config.GFA_Renamer_settings.filetype
    } else {
        InspectedImage:=Folder Delim sel2[3] "." script.config.GFA_Renamer_settings.filetype
        Padding_Name:=Folder Delim sel2[3] " (padding)." script.config.GFA_Renamer_settings.filetype
    }
    FileCopy % InspectedImage,% Padding_Name, 0

    Position_Original:=HasVal(ImagePaths,InspectedImage)
    Position_Duplicate:=Position_Original
    LV_Insert(Position_Duplicate, "Check", sel2[2] " (blank)", sel2[3] " (padding)")
    SourceImagesToDelete.push(Position_Duplicate) ; todo:: this does not work for mapping which files are padded and which are not. (just delete all files containing '(padding)' instead?)
    if (ImagePaths.Count()=Arr.Count()) {
        guicontrol GFAR_Exclude: enable,vGFAR_ExcludeSubmitButton
    } else {
        GFAR_ExcludeEscape()
        sleep 200
        GFARSubmit()
    }
    return SourceImagesToDelete
}

f_UpdateLV(Array,Array2) {
    ; updates the selected LV. LV MUST BE SELECTED BEFORE.
    LV_Delete()
    for k,v in Array {
        SplitPath % Array2[k], ,,, OutNameNoExt
        LV_Add("Check",v,OutNameNoExt)
    }
    LV_ModifyCol(1,"auto")
    return
}

GFAR_ExcludeOpenPath(Path) {
    gui GFAR_Exclude: -AlwaysOnTop
    Run % Path
    gui GFAR_Exclude: +AlwaysOnTop
    return
}

GFAR_ExcludeInspectSelection() {
    global
    sel:=GFARgetSelectedLVEntries()
    sel2:=strsplit(sel[1],"||")
    Delim:=(SubStr(Folder, -1 )!="\"?"\":"")
    LV_ModifyCol(1,"auto")
    if (TEST_FOLDERPATH!="") {
        InspectedImage:=TEST_FOLDERPATH Delim sel2[3] "." script.config.GFA_Renamer_settings.filetype
    } else {
        InspectedImage:=Folder Delim sel2[3] "." script.config.GFA_Renamer_settings.filetype
    }
    if (FileExist(InspectedImage) && A_GuiEvent!="e") {
        run % InspectedImage
    }
    return
}

GFAR_ExcludeEscape() {
    gui GFAR: -disabled
    gui GFAR_Exclude: destroy
    return
}

GFAR_ExcludeSubmit() {
    global
    gui GFAR: -disabled
    Sel:=f_GetCheckedLVEntries() ;; retrieve all rows of the Listview that we have checked/not unchecked
    gui GFAR_Exclude: Submit ;; submit the GUI to get all data inputted into it formally.

    Count_CopiedImages:=0 ;; if duplicates are excluded or padding files exist, we want less files in the output than in the Working Directory.
    /*
    ;; we have deselected some files in the final GUI. Thus, we cannot  use a fileloop easily. This can have the following reasons:
    1. We have deselected images because they are wrong, but all images afterwards are correct
    (aka, all intended images have been assigned the names they should receive, but for whatever reason we don't want the image X to be processed - maybe it was damaged and the plant was removed, but the image was shot beforehand, or was shot to make processing easier.)
    */
    if (Sel.Count()<TrueNumberOfFiles) {
        Log:="Expected Number of images: " TrueNumberOfFiles "`nFound Number of images: " Sel.Count() "`n"
        LogBody:=""
        FilestoCopy:=""
        if (TEST_FOLDERPATH!="") {
            Folder:=TEST_FOLDERPATH
        }
        FileRecycle % Folder "\assets\Image Test Files\GFAR_WD"
        for Sel_Index,Sel_String in Sel ;; iterate over all entries that we left checked. These will be renamed based on the Entries of the Listview - the name displayed will be applied to the respectively displayed filename
        {
            if (TEST_FOLDERPATH!="") {
                Folder:=TEST_FOLDERPATH
            }
            Sel_Arr:=strsplit(Sel_String,"||")
            Delim:=(SubStr(Folder, -1 )!="\"?"\":"")
            RenamedImage:=Folder Delim Sel_Arr[3] "." script.config.GFA_Renamer_settings.filetype
            scriptWorkingDir:=renameFile(RenamedImage,Sel_Arr[2],Sel_Index,Sel.Count())
            LogBody.=RenamedImage " - " Sel_Arr[2] "`n"
            FilestoCopy.=scriptWorkingDir "\" Arr[A_Index] "." script.config.GFA_Renamer_settings.filetype "`n"
            Count_CopiedImages++ ;; for every file that is renamed,
        }
        writeFile(logfile:=scriptWorkingDir "\__gfa_renamer_log.txt",Log LogBody, "UTF-8-RAW","w",true) ;; ensure the log-file is written as UTF-8, in case there are unicode characters in any groupname. Just a precaution
    } else {
        Log:="Expected Number of images: " TrueNumberOfFiles "`nFound Number of images: " Sel.Count() "`n"
        for Sel_Index,Sel_String in Sel ;; iterate over all entries that we left checked. These will be renamed based on the Entries of the Listview - the name displayed will be applied to the respectively displayed filename
        {
            if (TEST_FOLDERPATH!="") {
                Folder:=TEST_FOLDERPATH
            }
            Sel_Arr:=strsplit(Sel_String,"||")
            Delim:=(SubStr(Folder, -1 )!="\"?"\":"")
            RenamedImage:=Folder Delim Sel_Arr[3] "." script.config.GFA_Renamer_settings.filetype
            if InStr(Sel_Arr[3],"(padding)") { ;; remove padding files and advance to next iteration
                FileDelete % RenamedImage
                continue
            }
            scriptWorkingDir:=renameFile(RenamedImage,Sel_Arr[2],Sel_Index,Sel.Count())
            LogBody.=RenamedImage " - " Sel_Arr[2] "`n"
            FilestoCopy.=scriptWorkingDir "\" Sel_Arr[2] "." script.config.GFA_Renamer_settings.filetype "`n"
            Count_CopiedImages++ ;; for every file that is renamed,
        }
        Log.="Renamed Number of images: " Count_CopiedImages "`n"
        writeFile(logfile:=scriptWorkingDir "\__gfa_renamer_log.txt",Log LogBody, "UTF-8-RAW","w",true)
    }
    if (script.config.GFA_Renamer_settings.CopyParentDirectory) {
        FilestoCopy:=scriptWorkingDir "`n"
    } else {
        FilestoCopy.=logfile "`n"
    }
    if (script.config.GFA_Renamer_settings.PutFilesOnClipboard) {
        if (script.config.GFA_Renamer_settings.CopyFiles)
            if !ClipboardSetFiles(FilestoCopy,"Move") {
                StdErr_Write(A_LineNumber, "ClipboardSetFiles was unable to put the renamed images to the clipboard.", spec = FilestoCopy)
            }
    } else {
        if (WinExist(scriptWorkingDir " ahk_exe explorer.exe")) {
            WinActivate
            return
        }
        Else {
            run % scriptWorkingDir
        }
    }
    FinalInfoBox_String:="The script finished running.`n"
    FinalInfoBox_String.= (script.config.GFA_Renamer_settings.PutFilesOnClipboard)
        ? "The renamed image files are now ready to be pasted into whatever folder you want. Just open your intended folder and press 'CTRL-V'.`n`nAdditionally, a log file is copied. This log-file displays for every file that got renamed its original path. Files which are not renamed - and thus are missing in the output - are not shown in the log."
        : "- The folder containing the renamed images will open once this message box is closed.`n`nA log mapping each image to its new name is given in the file '__gfa_renamer_log.txt' within the output directory 'GFAR_WD'. The original image files are preserved in the original folder."
    MsgBox 0x40, % script.name " > Image-Renamer - Script finished",% FinalInfoBox_String
    OnMessage(0x44, "")
    GFAR_ExcludeEscape()
    return
}

GFARgetSelectedLVEntries() {
    vRowNum:=0
    sel:=[]
    loop
    {
        vRowNum:=LV_GetNext(vRowNum)
        if not vRowNum ; The above returned zero, so there are no more selected rows.
            break
        LV_GetText(sCurrText1,vRowNum,1)
        LV_GetText(sCurrText2,vRowNum,2)
        LV_GetText(sCurrText3,vRowNum,3)
        sel[A_Index]:="||" sCurrText1 "||" sCurrText2 "||" sCurrText3
    }
    return sel
}

f_GetCheckedLVEntries() {
    vRowNum:=0
    sel:=[]
    loop
    {
        vRowNum:=LV_GetNext(vRowNum,"C")
        if not vRowNum ; The above returned zero, so there are no more checked rows.
            break
        LV_GetText(sCurrText1,vRowNum,1)
        LV_GetText(sCurrText2,vRowNum,2)
        LV_GetText(sCurrText3,vRowNum,3)
        sel[A_Index]:="||" sCurrText1 "||" sCurrText2 "||" sCurrText3
    }
    return sel
}

renameFile(Path,Name,CurrentIndex:="",TotalCount:="") {
    SplitPath % Path,, OutDir, OutExtension
    if !Instr(FileExist(scriptWorkingDir:=OutDir "\" "GFAR_WD"),"D")
        FileCreateDir % scriptWorkingDir
    ttip(["Renaming (" CurrentIndex "/" TotalCount ")",[Path,Name]])
    FileCopy % Path, % scriptWorkingDir "\" Name "." OutExtension
    return scriptWorkingDir
}

repeatIndex(repetitions) {
    static lastreturn:=0
    lastreturn++
    if (lastreturn>repetitions)
        lastreturn:=1
    OutputDebug % lastreturn "`n"
    return lastreturn
}

repeatElementIofarrayNKtimes(array:="",repetitions:="",resetCallIndex:=False,Names:="") {
    static k, callIndex, position, sites := []
    static lastNames:=""
    if (lastNames="") {
        lastNames:=Names
    }
    if (sites.Count() = 0) || (lastNames!=Names) { ; It is the first run, let set variables and see their contents
        lastNames:=Names
        k := 5 ; Arbitrary set to a desired value
        k := repetitions
        callIndex := 0 ; Always start at zero to add from there
        position := 1 ; Have a value on the first iteration
        sites := {}
        sites := array
        OutputDebug % "Sites (N-elements): " sites.Count() "`n"
        OutputDebug % "Calls (K-iterations): " k "`n"
    }
    site := sites[position]
    OutputDebug % callIndex " " site " - "

    callIndex++ ; Increment `callIndex`, meaning that we made a new call to the function
    modResult := Mod(callIndex, k)
    if (modResult = 0) ; If there is a remainder (ie, not exactly divisible by k)
        position++ ; Increase the position by 1
    if (position > sites.Count()) ; If the new position is bigger than the actual number of elements in the array
        position := 1 ; Reset the position to start over
    if (resetCallIndex) { ;; force-reset the CI
        callIndex := 0 ; Always start at zero to add from there
    }
    return site
}

ForceOrder(Array) {
    assoc_1 := {}
    for key, value in Array {
        assoc_1.Insert(value, key)
    }
    assoc_2 := {}
    for key, value in assoc_1 {
        assoc_2.Insert(value, key)
    }
    return assoc_2
}
; #region:CenterControl() (3153967541)

; #region:Metadata:
; Snippet: CenterControl()
; --------------------------------------------------------------
; Author: banane
; Source: http://de.autohotkey.com/forum/viewtopic.php?p=67802#67802
; (09.10.2022)
; --------------------------------------------------------------
; Library: AHK-Rare
; Section: 06 - gui - interacting
; Dependencies: /
; AHK_Version: AHK_L
; --------------------------------------------------------------
; Keywords: positioning
; #endregion:Metadata


; #region:Description:
; Centers one control
; ;------------------------------------------------------------------------------------------------------------------------
; ;Parameters:  hWnd  = Handle of a Window (can be obtained using "WinExist()")
; ;             hCtrl = Handle of a Control (can be obtained using the "Hwnd" option when creating the control)
; ;             X     = Center the Control horizontally if X is 1
; ;             Y     = Center the Control vertically if Y is 1
; ;Description: Moves the specified control within the center of the specified window
; ;Returnvalue: 0 - Invalid Window / Control Handle, or the Window / Control has a size of 0
; ;------------------------------------------------------------------------------------------------------------------------
; #endregion:Description

; #region:Code
CenterControl(hWnd,hCtrl,X=1,Y=1) {
    static Border,CaptionSmall,CaptionNormal

    ;Retrieve Size of Border and Caption, if this is the first time this function is called
    If (!CaptionNormal) {
        SysGet Border, 5        ;Border Width
        SysGet CaptionNormal, 4 ;Window Caption
        SysGet CaptionSmall, 51 ;Window Caption with Toolwindow Style
    }

    ;Only continue if valid handles passed
    If (!hWnd || !hCtrl)
        Return 0

    ;Retrieve the size of the control and window
    ControlGetPos,,, cW, cH,, % "ahk_id " hCtrl
    WinGetPos,,, wW, wH, % "ahk_id " hWnd
    ;Only continue if the control and window are visible (and don't have a size of 0)
    If ((cW = "" || cH = "") || (wW = "" || wH = ""))
        Return 0

    ;Retrieve the window styles
    WinGet Styles, Style, % "ahk_id " hWnd
    WinGet ExStyles, ExStyle, % "ahk_id " hWnd

    ;Calculate the offset
    If (Styles & 0xC00000) ;If window has the "Caption" flag
        If (ExStyles & 0x00000080) ;If window has the "Toolwindow" flag
            Caption := CaptionSmall
    Else Caption := CaptionNormal
    Else Caption := 1

    ;Calculate the new position and apply it to the control
    ControlMove,, % (X = 1) ? Round((wW - cW + Border) / 2) : "", % (Y = 1) ? Round((wH - cH + Caption) / 2) : "",,, % "ahk_id " hCtrl

    ;Redraw the windows content
    WinSet Redraw,, % "ahk_id " hWnd

    Return 1
}
; #endregion:Code



; #endregion:CenterControl() (3153967541)
AppError(Title, Message, Options := 0, TitlePrefix := " - Error occured: ") {
    static labels := StrSplit("Abort,Cancel,Continue,Ignore,No,OK,Retry,TryAgain,Yes", ",")
    Options |= 0x1000, Options |= 0x0010
    MsgBox % Options, % script.name TitlePrefix Title, % Message
    for _, label in labels {
        IfMsgBox % label, return label
    }
}
DerefAHKVariables(String) {
    while (RegExMatch(String, "i)%(A_[^%]+)%", match)) {
        String := StrReplace(String, match, %match1%)
    }
    AHKVARIABLES := { "A_Index":A_Index,"A_ScriptDir": A_ScriptDir, "A_ScriptName": A_ScriptName, "A_ScriptFullPath": A_ScriptFullPath, "A_ScriptHwnd": A_ScriptHwnd, "A_LineNumber": A_LineNumber, "A_LineFile": A_LineFile, "A_ThisFunc": A_ThisFunc, "A_ThisLabel": A_ThisLabel, "A_AhkVersion": A_AhkVersion, "A_AhkPath": A_AhkPath, "A_IsUnicode": A_IsUnicode, "A_IsCompiled": A_IsCompiled, "A_ExitReason": A_ExitReason, "A_YYYY": A_YYYY, "A_MM": A_MM, "A_DD": A_DD, "A_MMMM": A_MMMM, "A_MMM": A_MMM, "A_DDDD":A_DDDD,"A_DDD":A_DDD,"A_WDay":A_WDay,"A_YDay":A_YDay,"A_YWeek":A_YWeek,"A_Hour":A_Hour,"A_Min":A_Min,"A_Sec":A_Sec,"A_MSec":A_MSec,"A_Now":A_Now,"A_NowUTC":A_NowUTC,"A_TickCount":A_TickCount,"A_IsSuspended":A_IsSuspended,"A_IsPaused":A_IsPaused,"A_IsCritical":A_IsCritical,"A_BatchLines":A_BatchLines,"A_ListLines":A_ListLines,"A_TitleMatchMode":A_TitleMatchMode,"A_TitleMatchModeSpeed":A_TitleMatchModeSpeed,"A_DetectHiddenWindows":A_DetectHiddenWindows,"A_DetectHiddenText":A_DetectHiddenText,"A_AutoTrim":A_AutoTrim,"A_StringCaseSense":A_StringCaseSense,"A_FileEncoding":A_FileEncoding,"A_FormatInteger":A_FormatInteger,"A_FormatFloat":A_FormatFloat,"A_SendMode":A_SendMode,"A_SendLevel":A_SendLevel,"A_StoreCapsLockMode":A_StoreCapsLockMode,"A_KeyDelay":A_KeyDelay,"A_KeyDuration":A_KeyDuration,"A_KeyDelayPlay":A_KeyDelayPlay,"A_KeyDurationPlay":A_KeyDurationPlay,"A_WinDelay":A_WinDelay,"A_ControlDelay":A_ControlDelay,"A_MouseDelay":A_MouseDelay,"A_MouseDelayPlay":A_MouseDelayPlay,"A_DefaultMouseSpeed":A_DefaultMouseSpeed,"A_CoordModeToolTip":A_CoordModeToolTip,"A_CoordModePixel":A_CoordModePixel,"A_CoordModeMouse":A_CoordModeMouse,"A_CoordModeCaret":A_CoordModeCaret,"A_CoordModeMenu":A_CoordModeMenu,"A_RegView":A_RegView,"A_IconHidden":A_IconHidden,"A_IconTip":A_IconTip,"A_IconFile":A_IconFile,"A_IconNumber":A_IconNumber,"A_TimeIdle":A_TimeIdle,"A_TimeIdlePhysical":A_TimeIdlePhysical,"A_TimeIdleKeyboard":A_TimeIdleKeyboard,"A_TimeIdleMouse":A_TimeIdleMouse,"A_DefaultGUI":A_DefaultGUI,"A_DefaultListView":A_DefaultListView,"A_DefaultTreeView":A_DefaultTreeView,"A_Gui":A_Gui,"A_GuiControl":A_GuiControl,"A_GuiWidth":A_GuiWidth,"A_GuiHeight":A_GuiHeight,"A_GuiX":A_GuiX,"A_GuiY":A_GuiY,"A_GuiEvent":A_GuiEvent,"A_GuiControlEvent":A_GuiControlEvent,"A_EventInfo":A_EventInfo,"A_ThisMenuItem":A_ThisMenuItem,"A_ThisMenu":A_ThisMenu,"A_ThisMenuItemPos":A_ThisMenuItemPos,"A_ThisHotkey":A_ThisHotkey,"A_PriorHotkey":A_PriorHotkey,"A_PriorKey":A_PriorKey,"A_TimeSinceThisHotkey":A_TimeSinceThisHotkey,"A_TimeSincePriorHotkey":A_TimeSincePriorHotkey,"A_EndChar":A_EndChar,"A_ComSpec":A_ComSpec,"A_Temp":A_Temp,"A_OSType":A_OSType,"A_OSVersion":A_OSVersion,"A_Is64bitOS":A_Is64bitOS,"A_PtrSize":A_PtrSize,"A_Language":A_Language,"A_ComputerName":A_ComputerName,"A_UserName":A_UserName,"A_WinDir":A_WinDir,"A_ProgramFiles":A_ProgramFiles,"A_AppData":A_AppData,"A_AppDataCommon":A_AppDataCommon,"A_Desktop":A_Desktop,"A_DesktopCommon":A_DesktopCommon,"A_DesktopCommon":A_DesktopCommon}
    return Deref_FormatEx(String, AHKVARIABLES)
}

Deref_FormatEx(FormatStr, Values*) {
    replacements := []
        , clone := Values.Clone()
    for i, part in clone
        IsObject(part) ? clone[i] := "" : Values[i] := {}
    FormatStr := Format(FormatStr, clone*)
        , index := 0
        , replacements := []
    for _, part in Values {
        for search, replace in part {
            replacements.Push(replace)
                , FormatStr := StrReplace(FormatStr, "{" search "}", "{" ++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}
CallStack(deepness = 5, printLines = 1)
{
    loop % deepness
    {
        lvl := -1 - deepness + A_Index
        oEx := Exception("", lvl)
        oExPrev := Exception("", lvl - 1)
        FileReadLine line, % oEx.file, % oEx.line
        if(oEx.What = lvl)
        continue
        stack .= (stack ? "`n" : "") "File '" oEx.file "', Line " oEx.line (oExPrev.What = lvl-1 ? "" : ", in " oExPrev.What) (printLines ? ":`n" line : "") "`n"
    }
    return stack
}
GetStdStreams_WithInput(CommandLine, WorkDir := "", ByRef InOut := "") {
    static HANDLE_FLAG_INHERIT := 0x00000001, PIPE_NOWAIT := 0x00000001, STARTF_USESTDHANDLES := 0x0100, CREATE_NO_WINDOW := 0x08000000, HIGH_PRIORITY_CLASS := 0x00000080
    DllCall("CreatePipe", "Ptr*", hInputR := 0, "Ptr*", hInputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("CreatePipe", "Ptr*", hOutputR := 0, "Ptr*", hOutputW := 0, "Ptr", 0, "UInt", 0)
    DllCall("SetHandleInformation", "Ptr", hInputR, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetHandleInformation", "Ptr", hOutputW, "UInt", HANDLE_FLAG_INHERIT, "UInt", HANDLE_FLAG_INHERIT)
    DllCall("SetNamedPipeHandleState", "Ptr", hOutputR, "Ptr", &PIPE_NOWAIT, "Ptr", 0, "Ptr", 0)
    VarSetCapacity(processInformation, A_PtrSize = 4 ? 16 : 24, 0) ; PROCESS_INFORMATION
    cb := VarSetCapacity(startupInfo, A_PtrSize = 4 ? 68 : 104, 0) ; STARTUPINFO
    NumPut(cb, startupInfo, 0, "UInt")
    NumPut(STARTF_USESTDHANDLES, startupInfo, A_PtrSize = 4 ? 44 : 60, "UInt")
    NumPut(hInputR, startupInfo, A_PtrSize = 4 ? 56 : 80, "Ptr")
    NumPut(hOutputW, startupInfo, A_PtrSize = 4 ? 60 : 88, "Ptr")
    NumPut(hOutputW, startupInfo, A_PtrSize = 4 ? 64 : 96, "Ptr")
    pWorkDir := IsSet(WorkDir) && WorkDir ? &WorkDir : 0
    created := DllCall("CreateProcess", "Ptr", 0, "Ptr", &CommandLine, "Ptr", 0, "Ptr", 0, "Int", true, "UInt", CREATE_NO_WINDOW | HIGH_PRIORITY_CLASS, "Ptr", 0, "Ptr", pWorkDir, "Ptr", &startupInfo, "Ptr", &processInformation)
    lastError := A_LastError
    DllCall("CloseHandle", "Ptr", hInputR)
    DllCall("CloseHandle", "Ptr", hOutputW)
    if (!created) {
        DllCall("CloseHandle", "Ptr", hInputW)
        DllCall("CloseHandle", "Ptr", hOutputR)
        throw Exception("Couldn't create process.", -1, Format("{:04x}", lastError))
    }
    if (IsSet(InOut) && InOut != "") {
        if (SubStr(InOut, 0) != "`n") {
            InOut .= "`n"
        }
        FileOpen(hInputW, "h", "UTF-8").Write(InOut)

    }
    DllCall("CloseHandle", "Ptr", hInputW)
    cbAvail := 0, InOut := ""
    pipe := FileOpen(hOutputR, "h`n", "UTF-8")
    while (DllCall("PeekNamedPipe", "Ptr", hOutputR, "Ptr", 0, "UInt", 0, "Ptr", 0, "UInt*", cbAvail, "Ptr", 0)) {
        if (cbAvail) {
            InOut .= pipe.Read()
        }
        else {
            Sleep 10
        }
    }
    DllCall("CloseHandle", "Ptr", hOutputR)
    hProcess := NumGet(processInformation, 0)
    DllCall("GetExitCodeProcess", "Ptr", hProcess, "UInt*", exitCode := 0)
    DllCall("CloseHandle", "Ptr", hProcess)
    hThread := NumGet(processInformation, A_PtrSize)
    DllCall("CloseHandle", "Ptr", hThread)
    return exitCode
}
FormatEx(FormatStr, Values*) {
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
            FormatStr := StrReplace(FormatStr, "{" search "}", "{" ++index "}")
        }
    }
    return Format(FormatStr, replacements*)
}
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
CodeTimer(Description:="",x:=500,y:=500,ClipboardFlag:=0)
{
    static StartTimer:=""
    If (StartTimer != "")
    {
        FinishTimer := A_TickCount
            , TimedDuration := FinishTimer - StartTimer
            , StartTimer := ""
        If (ClipboardFlag=1) {
            Clipboard.="`n" TimedDuration
        }
        if (Description!="") {
            tooltip % String:="Timer " Description "`n" TimedDuration " ms have elapsed!",% x,% y
        }
        Return [TimedDuration,String]
    } Else {
        StartTimer := A_TickCount
    }
    return
}
; #endregion:Code



; #endregion:CodeTimer (2035383057)