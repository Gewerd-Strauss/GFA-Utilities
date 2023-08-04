#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Requires AutoHotkey v1.1.36+ ;; version at which script was written.
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

    script.loadCredits(script.resfolder "\credits.txt")
    script.loadMetadata(script.resfolder "\meta.txt")
    script.Load(script.configfile, bSilentReturn:=1)
    FileRead script_Version, % A_ScriptDir "\INI-Files\GFC_Version.ini"
    script.version:=Regexreplace(script_Version,"\s*")
    script.config.version.GFC_version:=Regexreplace(script_Version,"\s*")
    script.config.version.build:=124
    script.Save(script.configfile)
    gw:=guiCreate()
    hwnd:=guiShow(gw)
    return
}

guiCreate() {
    ;; Funktion erstellt die Benutzeroberfläche. Sehr basic, aber reicht für das was gemacht werden muss.
    gui GC: destroy

    ;; get Screen dimensions
    SysGet A, MonitorWorkArea
    guiWidth:=A_ScreenWidth - 2*30
        ,guiHeight:=ABottom - 2*30
    if (bRunFromVSC) || (script.authorID!=A_ComputerName) {
        guiWidth:=1920 - 2*30
        guiHeight:=1080 - 2*30
        ttip({guiWidth:guiWidth,guiHeight:guiHeight})
    }

    XMarginWidth:=15
    NumberofSections:=3
    WidthMinusMargins:=guiWidth - 4*XMarginWidth + 0
    SectionWidth:=WidthMinusMargins/NumberofSections + 0
    Sections:={}
    loop, % NumberofSections {
        if (A_Index>1) {
            Sections[A_Index]:={XAnchor:XMarginWidth*A_Index + SectionWidth*(A_Index-1),Width:SectionWidth*1}
        } else {
            Sections[A_Index]:={XAnchor:XMarginWidth*A_Index,Width:SectionWidth*1}
        }
    }

    middleanchor:=guiWidth-4*15-middleWidth
    middleanchor2:=middleanchor-15

    groupbox_height:=953
    global StatusBarMainWindow
    global vUsedConfigLocation
    global vStarterRScriptLocation
    global vreturnDays
    global vSaveFigures
    global vSaveRData
    global vSaveExcel
    gui GC: new
    gui GC: +AlwaysOnTop +LabelGC
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
    gui add, text,% "y15 x" Sections[1].XAnchor+5 " h0 w0",leftanchor
    gui add, text,% "y20 x" Sections[1].XAnchor+5 " h40 w350",% "Select the configuration file you want to use. Alternatively, choose a folder containing your data - where you want your configuration file to sit. All '.xlsx'/'.csv'-files in any subfolder will be used."
    ;gui add, button, y60 xp w80 hwndselectConfigLocation,% "Select &Folder"
    gui add, button,% "y60 w80 hwndnewConfiguration x" Sections[1].XAnchor+5,% "New &Config in Folder"
    gui add, button,% "yp w80 hwndeditConfiguration x" Sections[1].XAnchor+95,% "&Edit existing Config"

    onEditConfiguration := Func("editConfiguration").Bind("")
    if (DEBUG) {
        onNewConfiguration := Func("createConfiguration").Bind(A_ScriptDir)
        oncreateNewStarterScript := Func("createNewStarterScript").Bind(A_ScriptDir)
        onSelectConfigLocation := Func("selectConfigLocation").Bind(A_ScriptDir)
    } else {
        onNewConfiguration := Func("createConfiguration").Bind("D:/")
        oncreateNewStarterScript := Func("createNewStarterScript").Bind("D:/")
        onSelectConfigLocation := Func("selectConfigLocation").Bind("D:/")
    }
    guiControl GC:+g, %selectConfigLocation%, % onSelectConfigLocation
    guiControl GC:+g, %EditConfiguration%, % onEditConfiguration
    guiControl GC:+g, %NewConfiguration%, % onNewConfiguration
    gui add, edit,% "y100 x" Sections[1].XAnchor+5 " r1 disabled vvUsedConfigLocation w" Sections[1].Width - 3*5,   % "<Location of Configuration-.ini-File)>"
    dynGUI:= new dynamicGUI("Experiment::blank",A_ScriptDir "\INI-Files\GFC_DA.ini","-<>-",FALSE,FALSE)
    dynGUI.GenerateGUI(,,False,"GC:",false,15,Sections[1].Width-15)
    gui add, statusbar, -Theme vStatusBarMainWindow  gfCallBack_StatusBarMainWindow
    if ((bShowDebugPanelINMenuBar) && bIsDevPC)
        SB_SetParts(23,185,100,175,95,70,80,170)
    Else
        SB_SetParts(23,185,100,175,95,70,80)
    SB_SetIcon("C:\WINDOWS\system32\shell32.dll",48,1)
    SB_SetText(script.name " v." script.version,2)
    SB_SetText(" by " script.author,3)
    SB_SetText("Report a bug",6)
    SB_SetText("Documentation",7)
    gui add, text,% "y15 x" Sections[2].XAnchor+5 " h0 w0", middleanchor
    gui add, text,% "y20 x" Sections[2].XAnchor+5 " h40 w350", % "Configure the R-Script used for running the GF-Analysis-Skript"
    gui add, button, y60 xp+5 w80 hwndnewStarterScript, % "New &R-StarterScript"
    gui add, button, y60 xp+90 w80 hwndeditStarterScript, % "Edit existing &R-StarterScript"
    guiControl GC:+g, %NewConfiguration%, % onNewConfiguration
    gui add, edit,% "y100 x" Sections[2].XAnchor+5 " r1 disabled vvStarterRScriptLocation w" Sections[2].Width - 3*5,   % "<Location of Starter-.R-Script>"
    gui add, checkbox, y125 xp vvreturnDays, Do you want to evaluate every day on its own?
    gui add, checkbox, y145 xp vvSaveFigures, Do you want to save 'Figures' to disk?
    gui add, checkbox, y165 xp vvSaveRData, Do you want to save 'RData' to disk?
    gui add, checkbox, y185 xp vvSaveExcel, Do you want to save 'Excel' to disk?
    GuiControl Show, vTab3
    ;guicontrol
    return {guiWidth:guiWidth
            ,guiHeight:guiHeight
            ,dynGUI:dynGUI
            ,Sections:Sections}
}

guiShow(gw) {
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
    return
}

GCSubmit() {
    gui GC: submit
    return
}
GCEscape() {
    gui GC: hide
    gui GC: destroy
}

fCallBack_StatusBarMainWindow() {
    gui GC: Submit, NoHide
    if ((A_GuiEvent="DoubleClick") && (A_EventInfo=1)) { ; part 1

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=2)) { ; part 2

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=3)) { ; part 3

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=4)) { ; part 4

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=5)) { ; part 5

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=6)) { ; part 6

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=7)) { ; part 7

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=8)) { ; part 8

    } else if ((A_GuiEvent="DoubleClick") && (A_EventInfo=9)) { ; part 9

    }

}
!Esc::Reload
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
