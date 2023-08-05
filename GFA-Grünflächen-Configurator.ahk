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

FileGetTime ModDate, %A_ScriptFullPath%, M
FileGetTime CrtDate, %A_ScriptFullPath%, C
CrtDate := SubStr(CrtDate, 7, 2) "." SubStr(CrtDate, 5, 2) "." SubStr(CrtDate, 1, 4)
ModDate := SubStr(ModDate, 7, 2) "." SubStr(ModDate, 5, 2) "." SubStr(ModDate, 1, 4)
global script := new script()
global bRunFromVSC:=(WinActive("ahk_class Chrome_WidgetWin_1") && WinActive("ahk_exe Code.exe"))
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
        , rfile: "https://github.com/Gewerd-Strauss/OBSIDIANSCRIPTS/archive/refs/heads/master.zip"
        , vfile_raw: "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/master/version.ini"
        , vfile: "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/master/version.ini"
    ; , vfile_local : A_ScriptDir "\res\version.ini"
        , EL: "359b3d07acd54175a1257e311b5dfaa8370467c95f869d80dba32f4afdcae19f4485d67815d9c1f4fe9a024586584b3a0e37489e7cfaad8ce4bbc657ed79bd74"
        , authorID: "Laptop-C"
        , author: "Gewerd Strauss"
        , Computername: A_ComputerName
        , license: A_ScriptDir "\res\LICENSE.txt" ;; do not edit the variables above if you don't know what you are doing.
        , blank: "" }
global DEBUG := IsDebug()
main()
return

main() {

    if !script.requiresInternet() {
        exitApp()
    }
    if !FileExist(script.scriptconfigfile) || DEBUG {
        setupdefaultconfig(1)
    }
    if !FileExist(script.gfcGUIconfigfile) || DEBUG {
        setupdefaultconfig(2)
    }
    script.Load(script.scriptconfigfile, bSilentReturn:=1)
    if (script.config.settings.bRunAsAdmin) {
        RunAsAdmin()
    }
    script.version:=script.config.version.GFC_version
        , script.loadCredits(script.resfolder "\credits.txt")
        , script.loadMetadata(script.resfolder "\meta.txt")
        , IconString:="iVBORw0KGgoAAAANSUhEUgAAADwAAAA8CAYAAAA6/NlyAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAARISURBVGhD7dtLbxNXGMbxbFh2yRIpzkWQgpIUKFAVibCBknIJqCFOZNIbJg0Xp7ikkAAh4SJoCxUENiBgW6ktUldIKQURbmpAIkSiqlqg6gcAvsLLPPPKVjp5bM/xnAllMpb+K4/PeX9yjj1epGKmPpqcBmdAcLqPwcrKSol6cCo3BkczOJUbg6MZnMqNwdEMTuXG4GgGp3JjcDSDU7kG4OzvJ+TAs3NT6p04Kd1XB6TtbJc0fbZGaupq6etNqplX666VPNflrH1QesdP0b2/evAtfb03OJVrAext7x/fS9vwNlnwXiNdp1gLljXI5jNpdw22trdQwZnRI3TTQvX/NSwth1NSVVNF15tcorpKNgylZN+fp+lahfry7jG6njc4lWsAxp8W27RU237pk7kNdXRNNLe+TtJX9tHXlmr7yEG6pjc4lWsATl3aRTf1E96JhhWLp6xZv3yh9Nw+Sl/jp87LPVPWZMGpXANw89etdFO/ZcdOyPwl9fn18M6aHhNvH/a1/WfGQsGpXAPwwlVL6aYmdV89INW11e6ZTV/ZS68xadHqZXRWb3Aq1wCMMjcP041NWru/XdYPdNDnTMqMHpVEIkHn9Aancg3BH2Q30c1Nyj46Lnsef0OfM2lVz0Y6IwtO5RqCcUOQfXCcDuC39P1dkh4r/wMQZW4e8/V1lwtO5RqC0crPm+kQfup/Oizt1zZJ8teN0v/kLL3GTys+WU1nKxScyi0DjFIXd9JBSpWZOCRtI+vdMhMD9JpS4euRzVQsOJVbJhh/2uXciKTHdubBW8d20GuKhT3LuVeHU7llghG+R/E1wwYrVOetzjy4c/Rjek2h8ANlXuPbdJZSwancAGCEd3rL5QwdkNVxvTUP7vjN/41MytkjyK8wOJUbEJwLH2S4fWTDTi55rSUPTo600GsmhzVXbm2me5oEp3ItgRHuoNbs+Uh23yv8MzKHzbX/2TC9Dms097a6a7K9TINTuRbBuRJVCVmy7n3ZMJiST3/IundEvY9OSt/fZ6aA+5yfkHgO1+BavAavxRps7XKDU7khgIvlfSfZNWEEp3JjcLi9seCXdypea2ymYsGp3BjsLzbEdMZmKhacyg0AfnGjQv4Zchqcppy9nl9/jWD073dksJDCXrl92UzFglO5ZYJznR96Kz9E2GEvNoOf4FRuQPAX7bPpcGHUlZxNZ/ATnMoNCF7UOEee3+ID2u7dd+bQGfwEp3IDgtH4j7PogDZ7+NMsurff4HS1ziMw+MI0nOMg5xfBqVwL4O6O8M8xPivY3n6DU7kWwIudc8yGtFmQ84vgVK4FMArzHGNttqdJcLpa52EFfPFIeOcYnxFsT5PgVK4lcJjnGGuzPU2CU7mWwGGe46DnF8GpXEtgNP6z/XNs4/wiOF2t87AGDuMcY022l2lwKtci+P8cnMqNwdEMTuXG4GgGp3JjcDSDU7kz5j/TKppeAamEQurI/tgFAAAAAElFTkSuQmCC"
    ;script.setIcon(IconString)
    script_TraySetup(IconString)

    ;script.Save(script.scriptconfigfile)
    global bIsDebug:=script.config.settings.bDebugSwitch
    global bIsAuthor:=(script.computername==script.authorID) + 0
    global gw:=guiCreate()
    hwnd:=guiShow(gw)
    f5:=Func("guiShow2").Bind(gw)
    Menu Tray, Add, Show/Hide GUI, % f5
    return
}

guiCreate() {
    ;; Funktion erstellt die Benutzeroberfläche. Sehr basic, aber reicht für das was gemacht werden muss.
    gui GC: destroy

    ;; get Screen dimensions
    SysGet A, MonitorWorkArea
    guiWidth:=A_ScreenWidth - 2*30
        ,guiHeight:=ABottom - 2*30
    if (bRunFromVSC) || ((script.authorID!=A_ComputerName) && script.config.Settings.Toggle1080p) {
        guiWidth:=1920 - 2*30
        guiHeight:=1080 - 2*30
    }
    ttip({guiWidth:guiWidth,guiHeight:guiHeight,A_ScreenHeight:A_ScreenHeight,A_ScreenWidth:A_ScreenWidth},1,2300)

    YMarginWidth:=XMarginWidth:=15
    NumberofSections:=3
    WidthMinusMargins:=guiWidth - 4*XMarginWidth + 0
    HeightMinusMargins:=guiHeight - 4*YMarginWidth + 0
    SectionWidth:=WidthMinusMargins/NumberofSections + 0
    SectionHeight:=HeightMinusMargins/1 + 0
    Sections:={}
    loop, % NumberofSections {
        if (A_Index>1) {
            Sections[A_Index]:={XAnchor:XMarginWidth*A_Index + SectionWidth*(A_Index-1),Width:SectionWidth*1,Height:SectionHeight*1}
        } else {
            Sections[A_Index]:={XAnchor:XMarginWidth*A_Index,Width:SectionWidth*1,Height:SectionHeight*1}
        }
    }

    middleanchor:=guiWidth-4*15-middleWidth
    middleanchor2:=middleanchor-15

    groupbox_height:=953
    global StatusBarMainWindow
        , vUsedConfigLocation
        , vStarterRScriptLocation
        , vreturnDays
        , vSaveFigures
        , vSaveRData
        , vSaveExcel
        , vRCRScript
        , vRCConfiguration
    gui GC: new
    gui GC: +AlwaysOnTop +LabelGC +HWNDGCHWND
    if DEBUG {
        gui -AlwaysOnTop
    }
    Names:=["1. Configuration File","2. R Starter Script Configuration","3. Miscellaneous"]
    ;gui GC: Show, % "w" guiWidth " h" guiHeight

    for each, section in Sections {
        Sections[each].Name:=Names[A_Index]
        gui add, text,% " y0 h0 w" 0 " x" 0, % section.name
    }
    gui show
    ;; left side
    gui add, text,% "y15 x" Sections[1].XAnchor+5 " h0 w0",leftanchor
    gui add, text,% "y20 x" Sections[1].XAnchor+5 " h40 w350",% "Select the configuration file you want to use. Alternatively, choose a folder containing your data - where you want your configuration file to sit. All '.xlsx'/'.csv'-files in any subfolder will be used."
    ;gui add, button, y60 xp w80 hwndselectConfigLocation,% "Select &Folder"
    gui add, button,% "y60 w80 hwndnewConfiguration x" Sections[1].XAnchor+5,% "New &Config in Folder"
    gui add, button,% "yp w80 hwndeditConfiguration x" Sections[1].XAnchor+95,% "&Edit existing Config"
    gui add, edit,% "yp w160 hwnddropFilesEdit disabled -vscroll -hscroll x" Sections[1].XAnchor+180,% "Drop config file or config destination folder here"
    gui add, edit,% "y100 x" Sections[1].XAnchor+5 " r1 disabled vvUsedConfigLocation w" Sections[1].Width - 3*5,   % "<Location of Configuration-'.ini'-File>"
    global dynGUI:= new gfcGUI("Experiment::blank",script.gfcGUIconfigfile,"-<>-",FALSE)
    dynGUI.guiVisible:=false
    dynGUI.GCHWND:=GCHWND
    dynGUI.GenerateGUI(,,False,"GC:",false,15,Sections[1].Width-15,,9)

    ;; middle
    gui add, text,% "y15 x" Sections[2].XAnchor+5 " h0 w0", middleanchor
    gui add, text,% "y20 x" Sections[2].XAnchor+5 " h40 w350", % "Configure the R-Script used for running the GF-Analysis-Skript"
    gui add, button,% "y60 w80 hwndnewStarterScript x" Sections[2].XAnchor+5, % "New &R-StarterScript"
    gui add, button,% "y60 w80 hwndeditStarterScript x" Sections[2].XAnchor+95, % "Edit existing &R-StarterScript"
    gui add, edit,% "y60 w160 hwnddropFilesEdit disabled -vscroll -hscroll x" Sections[2].XAnchor+180,% "Drop RScript-file or RScript-destination folder here"
    gui add, edit,% "y100 x" Sections[2].XAnchor+5 " r1 disabled vvStarterRScriptLocation w" Sections[2].Width - 3*5,   % "<Location of Starter-'.R'-Script>"
    gui add, checkbox, y125 xp vvreturnDays, Do you want to evaluate every day on its own?
    gui add, checkbox, y145 xp vvSaveFigures, Do you want to save 'Figures' to disk?
    gui add, checkbox, y165 xp vvSaveRData, Do you want to save 'RData' to disk?
    gui add, checkbox, y185 xp vvSaveExcel, Do you want to save 'Excel' to disk?

    ;; right
    gui add, text, % "y15 x" Sections[3].XAnchor+5 " h0 w0", rightanchor

    gui add, text, % "y30 x" Sections[3].XAnchor+5 " h40 w" Sections[3].Width - 3*5, R-Script-Preview
    /*
    RESettings2 :=
    ( LTrim Join Comments
    {
    "TabSize": 4,
    "Indent": "`t",
    "FGColor": 0xEDEDCD,
    "BGColor": 0x3F3F3F,
    "Font": {"Typeface": "Consolas", "Size": 11},
    "WordWrap": False,

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
    }
    }
    )
    global RC:=new ACS_RichCode(RESettings2, "y" yPos_RichCode " x" xPos_RichCode " w" Width_RichCode " h" Height_RichCode,"MainGui", HighlightBound=Func("HighlightAHK"))
    AddToolTip(RC,"Test")
    }
    RC.HighlightBound:=Func("HighlightAHK")
    */
    gui add, edit,% "y45 x" Sections[3].XAnchor+5 " h" (Sections[3].Height-45-3*5)/4  "disabled vvRCRScript w" Sections[3].Width - 3*5,   % "<RScript-preview -'.R'-File>"
    gui add, text, % "y" (45+(Sections[3].Height-45-3*5)/4 + 15) " x" Sections[3].XAnchor+5 " h40 w" Sections[3].Width - 3*5, Configuration-Preview
    gui add, edit,% "y" ((45+(Sections[3].Height-45-3*5)/4 + 15)+15) " x" Sections[3].XAnchor+5 " h" (Sections[3].Height-45-3*5)/4 " disabled vvRCConfiguration w" Sections[3].Width - 3*5,   % "<Configuration-preview -'.ini'-File>"
    gui add, button,% "y" ((45+(Sections[3].Height-45-3*5)/4 + 15)+15+(Sections[3].Height-45-3*5)/4+15) " w80 hwnd x" Sections[3].XAnchor+5 " ggenerateRScript", % "Generate R-Script"
    gui add, button,% "yp w80 hwndgenerateConfiguration x" Sections[3].XAnchor+95, % "Generate Configuration"
    gui add, button,% "yp w80  gfEditSettings hwndEditSettings x" Sections[3].XAnchor+185, % "Open program settings"
    gui add, button,% "yp w80  gexitApp hwndExitProgram x" Sections[3].XAnchor+275, % "Exit Program"

    gui add, statusbar, -Theme vStatusBarMainWindow  gfCallBack_StatusBarMainWindow
    if ((bShowDebugPanelINMenuBar) && (script.authorID=A_ComputerName))
        SB_SetParts(0,240,100,280,95,70,80,170)
    Else
        SB_SetParts(0,240,100,270,95,70,80)
    SB_SetText(script.name " v." script.config.version.GFC_version A_Space script.config.version.build,2)
    SB_SetText(" by " script.author,3)
    SB_SetText("Standard Mode Engaged. Click to enter debug-mode",4)
    SB_SetText("Report a bug",6)
    SB_SetText("Documentation",7)

    onEditConfiguration := Func("editConfiguration").Bind("")
    onEditStarterScript := Func("editRScript").Bind("")
    onGenerateConfiguration := ObjBindMethod(dynGUI, "generateConfig")
    if (DEBUG) {
        onNewConfiguration := Func("createConfiguration").Bind(A_ScriptDir)
        oncreateNewStarterScript := Func("createNewStarterScript").Bind(A_ScriptDir)
    } else {
        onNewConfiguration := Func("createConfiguration").Bind("D:/")
        oncreateNewStarterScript := Func("createNewStarterScript").Bind("D:/")
    }

    guiControl GC:+g, %generateConfiguration%, % onGenerateConfiguration
    guiControl GC:+g, %EditConfiguration%, % onEditConfiguration
    guiControl GC:+g, %NewConfiguration%, % onNewConfiguration
    guiControl GC:+g, %newStarterScript%, % oncreateNewStarterScript
    guiControl GC:+g, %editStarterScript%, % onEditStarterScript
    GuiControl Show, vTab3
    return {guiWidth:guiWidth
            ,guiHeight:guiHeight
            ,dynGUI:dynGUI
            ,Sections:Sections}
}
generateRScript() {
    return
}
guiShow2(gw) {
    global
    if (WinActive("ahk_id " gw.dynGUI.GCHWND)) {
        if (dynGUI.guiVisible) {
            guiHide()
            dynGUI.guiVisible:=false
        } else {
            guiShow(gw)
            dynGUI.guiVisible:=true
        }
    } else {
        if (dynGUI.guiVisible) {
            guiHide()
            dynGUI.guiVisible:=false
        } else {
            guiShow(gw)
            dynGUI.guiVisible:=true
        }
    }
    return
}
guiShow(gw) {
    gui GC: default
    ;gui GC: add,groupbox , y0 x10 w684 h953, Configuration File
    gui GC: show,% "w" gw["guiWidth"]*2 " h" gw["guiHeight"]*0.5  , % script.name " - Create new Configuration"
    useGroupbox:=1
    for each, section in gw.Sections {
        Sections[each].Name:=Names[A_Index]
        if (useGroupbox) {
            gui add, groupbox,% " y3 h953 w" section.Width " x" section.XAnchor-5, % section.name
        } else {
            gui add, text,% " y3 h15 w" section.Width " x" section.XAnchor-5, % section.name
        }
    }
    gui GC: show,% "w" gw["guiWidth"] " h" gw["guiHeight"] " AutoSize Center" , % script.name " - Create new Configuration"
    dynGUI.guiVisible:=true
    return
}
guiHide() {
    global
    dynGUI.guiVisible:=false
    GCEscape()
    return 
}
GCDropFiles(GuiHwnd, File, CtrlHwnd, X, Y) {

    global dynGUI
    if (A_GuiControl="Drop config file or config destination folder here") {    ;; ini-file

        if (File.Count()>1) {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: 2+ files/folders dropped", You have dropped more than either 1 .ini-file or 1 folder on the GUI. This will not work. Please drop either a single file`, or a single folder onto the GUI.
            Gui -OwnDialogs
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
        if (configPath="") {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Selection-GUI got cancelled", You have closed the selection-window without selecting an existing or creating a new config-file. Please do either.
            Gui -OwnDialogs
            return
        }
        if RegexMatch(configPath,"\.R$")  {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Dropped RScript-file on config-dropper", % "You have dropped the RScript-file`n`n'" configPath "'`n`n on the left selection-window. Please drag-and-drop a configuration-file (.ini) here instead."
            Gui -OwnDialogs
            return
        }
        if !RegexMatch(configPath,"\.ini$") {
            configPath.= ".ini"
        }
        if !FileExist(configPath) {
            dynGUI.generateConfig()
            written_config:=dynGUI.ConfigObject
            t_script:=new script()
            t_script.Save(configPath,written_config)

            ;;writeFile(configPath,"","UTF-8",0x2,1)
        }
        guicontrol % "GC:",vUsedConfigLocation, % configPath
    } else if (A_GuiControl="Drop RScript-file or RScript-destination folder here") {                                                                    ;; Rscript-file
        if (File.Count()>1) {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: 2+ files/folders dropped", You have dropped more than either 1 .Rscript-file or 1 folder on the GUI. This will not work. Please drop either a single file`, or a single folder onto the GUI.
            Gui -OwnDialogs
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
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Selection-GUI got cancelled", You have closed the selection-window without selecting an existing or creating a new Rscript-file. Please do either.
            Gui -OwnDialogs
            return
        }

        if RegexMatch(rPath,"\.ini$")  {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Dropped config-file on rscript-dropper", % "You have dropped the config-file`n`n'" rPath "'`n`n on the right selection-window. Please drag-and-drop an Rscript-file here instead."
            Gui -OwnDialogs
            return
        }
        if !RegexMatch(rPath,"\.R$")  {
            rPath.= ".R"
        }
        guicontrol % "GC:",vStarterRScriptLocation, % rPath
    } else { ;; anywhere else
        if (File.Count()>1) {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: 2+ files/folders dropped", You have dropped more than either 1 .ini-file or 1 folder on the GUI. This will not work. Please drop either a single file`, or a single folder onto the GUI.
            Gui -OwnDialogs
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
        if (configPath="") {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Selection-GUI got cancelled", You have closed the selection-window without selecting an existing or creating a new config-file. Please do either.
            Gui -OwnDialogs
            return
        }
        if RegexMatch(configPath,"\.R$")  {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Dropped RScript-file on config-dropper", % "You have dropped the RScript-file`n`n'" configPath "'`n`n on the left selection-window. Please drag-and-drop a configuration-file (.ini) here instead."
            Gui -OwnDialogs
            return
        }
        if !RegexMatch(configPath,"\.ini$") {
            configPath.= ".ini"
        }
        if !FileExist(configPath) {
            dynGUI.generateConfig()
            written_config:=dynGUI.ConfigObject
            t_script:=new script()
            t_script.Save(configPath,written_config)
        }
        guicontrol % "GC:",vUsedConfigLocation, % configPath


        if (File.Count()>1) {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: 2+ files/folders dropped", You have dropped more than either 1 .Rscript-file or 1 folder on the GUI. This will not work. Please drop either a single file`, or a single folder onto the GUI.
            Gui -OwnDialogs
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
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Selection-GUI got cancelled", You have closed the selection-window without selecting an existing or creating a new Rscript-file. Please do either.
            Gui -OwnDialogs
            return
        }

        if RegexMatch(rPath,"\.ini$")  {
            Gui +OwnDialogs
            MsgBox 0x40010, % script.name " - Error occured: Dropped config-file on rscript-dropper", % "You have dropped the config-file`n`n'" rPath "'`n`n on the right selection-window. Please drag-and-drop an Rscript-file here instead."
            Gui -OwnDialogs
            return
        }
        if !RegexMatch(rPath,"\.R$")  {
            rPath.= ".R"
        }
        guicontrol % "GC:",vStarterRScriptLocation, % rPath

    }
    return  
}
GCSubmit() {
    gui GC: submit
    return
}
GCEscape() {
    gui GC: hide
    ;gui GC: destroy
    return
}

fCallBack_StatusBarMainWindow() {
    gui GC: Submit, NoHide
    ttip(bIsDebug)
    if ((A_GuiEvent="DoubleClick") && (A_EventInfo=1)) {        ; part 0  -  ??

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=2)) { ; part 1  -  build/version - check for updates
        script.Update()
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=3)) { ; part 2  -  Author
        script.About()
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=4)) { ; part 3  -  Mode Toggle
        script.config.settings.bDebugSwitch:=!script.config.settings.bDebugSwitch
        bIsAuthor:=(script.computername==script.authorID) + 0
        bIsDebug:=(script.config.settings.bDebugSwitch) + 0

        if (!(script.authorID!=A_ComputerName) & !bIsDebug) || ((script.authorID!=A_ComputerName) & !bIsDebug)
        { ;; public display
            SB_SetText("Standard Mode Engaged. Click to enter debug-mode",4)
            SoundBeep 150, 150
            SoundBeep 150, 150
            SoundBeep 150, 150
            ListLines Off
            ; KeyHistory
        }
        else if (!(script.authorID!=A_ComputerName) && bIsDebug) || ((script.authorID!=A_ComputerName) && bIsDebug)
        {
            SoundBeep 1750, 150
            SoundBeep 1750, 150
            SoundBeep 1750, 150
            SB_SetText("Author/Debug Mode Engaged. Click to exit debug-mode",4)
            ListLines On
        }
    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=5)) { ; part 4 - Debug Mode

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=6)) { ; part 5 - report bug

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=7)) { ; part 6

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=8)) { ; part 7

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=9)) { ; part 8

    }
    return
}
~!Esc::Reload
generateConfigFile(Folder) {
    InputBox configName, % "Choose name", % "Set the name of the config file", ,,,,,,5000, % "GFA_conf"
    if InStr(configName, ".ini") {
        SplitPath % configName, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
        configName:=OutNameNoExt
    }

}
createConfiguration(Path) {
    if (!DEBUG) {
        SearchPath:="C://"
    }
    if (!FileExist(Path)) {
        SearchPath:="C://"
    } else {
        SearchPath:=Path
    }
    gui -AlwaysOnTop
    FileSelectFolder Chosen,% SearchPath ,3, % "Select configuration file to populate."
    if (!DEBUG) {
        gui +AlwaysOnTop
    }
    SplitPath % Chosen,,,,ChosenName
    if (Chosen!="") {
        ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:44:47 AM ; case sensitivity
        Chosen:=Chosen "\GFA_conf_AG.ini"
        guicontrol % "GC:",vUsedConfigLocation, % Chosen
        if (!FileExist(Chosen)) {
            writeFile(Chosen,"","UTF-8-RAW",,true)
        }
    }
    global GFA_configurationFile:=Chosen
    return Chosen
}
editConfiguration(configurationFile) {
    global
    gui Submit,NoHide

    if (e:=FileExist(GFA_configurationFile)) {
        run % GFA_configurationFile
    } else if (FileExist(configurationFile)) {
        run % configurationFile
    } else {
        if (DEBUG) {
            GFA_configurationFile:=createConfiguration(A_ScriptDir)

        } else {

            GFA_configurationFile:=createConfiguration("D:/")
        }
    }

    return
}

selectConfigLocation(SearchPath) {
    if (!DEBUG) {
        SearchPath:="C://"
    }
    gui -AlwaysOnTop
    FileSelectFolder Chosen,% SearchPath ,3, % "Select configuration file to populate."
    if (!DEBUG) {
        gui +AlwaysOnTop
    }

    SplitPath % Chosen,,,,ChosenName
    if (Chosen!="") {
        ;@ahk-neko-ignore-fn 1 line; at 4/28/2023, 9:44:47 AM ; case sensitivity
        Chosen:=Chosen "\GFA_conf_AG.ini"
        guicontrol % "GC:",vUsedConfigLocation, % Chosen
        if (!FileExist(Chosen)) {
            writeFile(Chosen,"","UTF-8-RAW",,true)
        }
    }
    global GFA_configurationFile:=Chosen
    return Chosen
}
#if bRunFromVSC
NumpadDot::reload

reload() {
    reload
}
exitApp() {
    ExitApp
}
#Include <script>
#Include <Base64PNG_to_HICON>
#Include <DynamicArguments>
#Include <isDebug>
#Include <MWAGetMonitor>
#Include <OnError>
#Include <OnExit>
#Include <Quote>
#Include <st_count>
#Include <ttip>
#Include <writeFile>
#Include <GFC_GUI>
#Include <Configuration>
#Include <RunAsAdmin>
#Include <AddToolTip>
#Include <RichCode>
