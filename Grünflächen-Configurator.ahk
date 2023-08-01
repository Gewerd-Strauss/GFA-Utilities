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

script := { base: script.base
        , name: regexreplace(A_ScriptName, "\.\w+")
        , crtdate: CrtDate
        , moddate: ModDate
        , offdoclink: A_ScriptDir "\assets\Documentation\GFA_Renamer_Readme.html"
        , resfolder: A_ScriptDir "\res"
        , iconfile: ""
        , version: ""
        , config: []
        , configfile: A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
        , configfolder: A_ScriptDir "\INI-Files"
        , aboutPath: A_ScriptDir "\res\About.html"
        , reqInternet: false
        , rfile: "https://github.com/Gewerd-Strauss/OBSIDIANSCRIPTS/archive/refs/heads/master.zip"
        , vfile_raw: "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/master/version.ini"
        , vfile: "https://raw.githubusercontent.com/Gewerd-Strauss/OBSIDIANSCRIPTS/master/version.ini"
    ; , vfile_local : A_ScriptDir "\res\version.ini"
        , EL: "359b3d07acd54175a1257e311b5dfaa8370467c95f869d80dba32f4afdcae19f4485d67815d9c1f4fe9a024586584b3a0e37489e7cfaad8ce4bbc657ed79bd74"
        , authorID: "Laptop-C"
        , Computername: A_ComputerName
        , license: A_ScriptDir "\res\LICENSE.txt" ;; do not edit the variables above if you don't know what you are doing.
        , blank: "" }
global DEBUG := IsDebug()
main()
return


main() {

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
        ,rightWidth:=leftWidth:=(guiWidth-4*30)/2
    gui add, text, y15 x15 w0 h0,leftanchor


    gui add, edit,% "y15 x" 15+leftWidth +2*15+rightWidth " w200 h200",   % "d2"
    global StatusBarMainWindow
    gui GC: new
    gui GC: +AlwaysOnTop +ToolWindow +LabelGC
    gui GC: Show, % "w" guiWidth " h" guiHeight
    gui add, statusbar, -Theme vStatusBarMainWindow BackGround373b41 gfCallBack_StatusBarMainWindow
    if DEBUG {
        gui -AlwaysOnTop
    }
    return {guiWidth:guiWidth
            ,guiHeight:guiHeight}
}

guiShow(gw) {
    gui GC: show,% "w" gw["guiWidth"] " h" gw["guiHeight"]  , % script.name " - Create new Configuration"
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
}
!Esc::Reload
;#Include <script>
;#Include <Quote>
;#Include <ttip>
;#Include <st_count>
;#Include <HasVal>
;#Include <OnError>
;#Include <OnExit>
;#Include <Base64PNG_to_HICON>
;#Include <writeFile>
;#Include <DynamicArguments>
;#Include <MWAGetMonitor>

#Include %A_ScriptDir%/Lib
