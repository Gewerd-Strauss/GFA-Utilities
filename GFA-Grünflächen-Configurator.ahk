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
#Include <OnError>
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
        if (script.config.Configurator_settings.UpdateChannel="stable") {
            script.Update(script.vfile,script.rfile,1,,,1)
        } else if (script.config.Configurator_settings.UpdateChannel="development") {
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
    if (globalLogicSwitches.DEBUG) {
        ttip(["guiWidth: " guiWidth
                ,"guiHeight: " guiHeight
                ,"A_ScreenHeight " A_ScreenHeight
                ,"A_ScreenWidth " A_ScreenWidth
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
        if (!InStr(Chosen,".R")) {
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
                Title:=script.name " - " A_ThisFunc " - Script-Execution failed" 
                Message:="The R-Script 'GFA_Evaluation.R' (Path:" dynGUI.GFA_Evaluation_InstallationPath ") failed to finish execution. The complete callstack of the execution was printed to the file '" errorlog "'`n`nOpen the errorlog now?"
                writeFile(errorlog,InOut,,,true)
                Gui +OwnDialogs
                AppError(Title, Message,0x14)
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
                Title:=script.name " - " A_ThisFunc " - Script-Execution succeeded" 
                    , Message:="GFA_Evaluation: Execution finished.`nThe complete callstack of the execution was printed to the file '" errorlog "'.`n`nOpen the errorlog now?"
                Gui +OwnDialogs
                AppError(Title, Message,0x44)
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


#Include <script>
#Include <Base64PNG_to_HICON>
#Include <DynamicArguments>
#Include <isDebug>
#Include <MWAGetMonitor>
#Include <onExit>
#Include <Quote>
#Include <st_stringthings_functions>
#Include <ttip>
#Include <writeFile>
#Include <GFC_GUI>
#Include <Configuration>
#Include <RunAsAdmin>
#Include <AddToolTip>
#Include <RichCode>
#Include <HasVal>
#Include <AutoXYWH>
#Include <History>
#Include <LV_EX>
#Include <SetExplorerTheme>
#Include <RegexMatchAll>
#Include <checkDecimalsOnEdit>
#Include <Deref>
#Include <csv2xlsx>
#Include <SelectFolder>
#Include <StdErr_Write>
#Include <ClipboardSetFiles>
#Include <CountFilesR>
#Include <renameImages>
#Include <CenterControl>
#Include <messageboxes>
#Include <DerefAHKVariables>
#Include <callstack>
#Include <GetStdStreams_WithInput>
#Include <FormatEX>
#Include <CodeTimer>
