renameImages(dynGUI) {
    if (dynGUI.GFA_Evaluation_Configfile_Location!="") {
        if (FileExist(dynGUI.GFA_Evaluation_Configfile_Location)) {
            SplitPath % dynGUI.GFA_Evaluation_Configfile_Location,, OutDir,
            GFAR_createGUI(dynGUI.Arguments.PotsPerGroup.Value,dynGUI.Arguments.UniqueGroups.Value,OutDir,dynGUI)
        } else {
            throw exception("Config-file does not exist`n"  CallStack(),-1)
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
    oH:=dynGUI.GCHWND
    yP:=A_ScreenHeight-500
    xP:=A_ScreenWidth-440
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
    ;gui, add, text,vvUsedStick, % "used Stick: " (device_name!=""? "'" device_name "'": "Device '" script.config.GFA_Renamer_settings.USB_Stick_Name "' could not be found.")
    gui add, Button, vSubmitButton gGFARSubmit, &Submit
    gui add, Button, yp xp+64 hwndhwndgfarreselectfolder, Select &Different Folder
    onOpenConfig:=Func("GFARopenConfig").Bind(script.configfile)
    onReselectFolder:=Func("GFARReselectFolder").Bind(SearchStartLocation)
    guicontrol +g,%hwndgfarreselectfolder%,% onReselectFolder
    gui font, s7
    gui add, text,yp+20 x350,% "v." script.version " by ~Gw"
    gui GFAR: show, w430 x%xP% y%yP% ,% "Drop folder with images on this window"
}

GFARReselectFolder(SearchstartLocation) {
    SelectedFolder:=SelectFolder(SearchStartLocation,"Select Folder containing images to be renamed")
    try {
        ; A_DefaultGui
        LastRunCount:=false
        if FileExist(SelectedFolder) {
            LastRunCount:=CountFiles(SelectedFolder)
        }
    } catch e {
        ttip(e)
    }
    if (LastRunCount) {
        guicontrol ,, gfarFolder,% SelectedFolder
        ;gui add, Edit, w400 h110 vFolder disabled, % SelectedFolder
    } else {

    }
}

GFAREscape() {
    gui GFAR: destroy
}

GFARSubmit() {
    global
    gui GFAR: Submit, NoHide
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
        totalNumber:=0
        Counts:=strsplit(gfarPlantsPerGroup,",")
        GroupNames:=strsplit(gfarNames,",")
        if (Counts.Count() != GroupNames.Count()) {
            Gui +OwnDialogs
            MsgBox 0x40010,% script.name " - Critical error: Parameters incompatible",% "You provided a list of varying number of pots/plants per group: `n" gfarPlantsPerGroup "`n for " Counts.Count() " groups`, but also provided names for " GroupNames.Count() " groups:`n" gfarNames "`n`nPlease fix this error by aligning both."
            return
        }
        for each, Name in Groupnames {
            loop, % Counts[each] {
                Arr.push(Name " (" A_Index ")")
            }
        }
        LoopCount:=gfarPlantsPerGroup*strsplit(gfarNames,",").Count()
        loop % LoopCount
        {
            bReset:=(!(mod(A_Index,gfarPlantsPerGroup))) ;; force a reset in call_index every 'PlantsPerGroup'
            Reset:=true
            GroupName:=repeatElementIofarrayNKtimes(strsplit(gfarNames,","),gfarPlantsPerGroup,,bReset,gfarNames)
            Reset:=false
            Number:=repeatIndex(gfarPlantsPerGroup)
            Arr.push(GroupName " (" Number ")")
            if (bReset) {

            }
        }
    } else {

        LoopCount:=gfarPlantsPerGroup*strsplit(gfarNames,",").Count()
        Reset:=true
        loop % LoopCount
        {
            bReset:=(!(mod(A_Index,gfarPlantsPerGroup))) ;; force a reset in call_index every 'PlantsPerGroup'
            GroupName:=repeatElementIofarrayNKtimes(strsplit(gfarNames,","),gfarPlantsPerGroup,,bReset,gfarNames)
            Reset:=false
            Number:=repeatIndex(gfarPlantsPerGroup)
            Arr.push(GroupName " (" Number ")")
            if (bReset) {

            }
        }
    }
    ;ttip(repeatElementIofarrayNKtimes())
    TrueNumberOfFiles:=0
    ImagePaths:=[]

    opt:=(bTestSet?"FR":"F")
    query:=gfarFolder "\*." script.config.GFA_Renamer_settings.filetype
    Loop, Files, % query, % opt
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
        MsgBox 0x40010, % script.name " - Critical error: More images than names defined"
            , % "The folder you provided contains " ImagePaths.Count() " images. The combination of the 'number of groups' and 'plants per group' you provided only allows for renaming " Arr.Count() " images."
            . "`nBe aware that only those first " Arr.Count() " images will be renamed, (and copied to the clipboard)"
        ImageF:=ImagePaths[Arr.Count()]
    }
    gui GFAR_Exclude: new, +AlwaysOnTop -SysMenu -ToolWindow -caption +Border +hwndGFAR_ExcludeGui
    gui GFAR_Exclude: +OwnerGFAR +LabelGFAR_Exclude
    gui GFAR: +disabled
    gui Font, s10
    gui add, text,,% "Please UNTICK any name you do not have an image for (at that position).`nNotes:`n - Files are not actually skipped. Instead, by unticking a row you prevent the name of a pot that you don't have an image`nof from being applied to the 'next-in-line' image.)`n - Double-click an entry in this list to view the image`n - Select an image and press F2 if you want to change the name it will be assigned (and you know what you are doing.)"
    gui add, Listview, Checked vvLV_SelectedEntries w700 R30 -ReadOnly WantF2 Report gGFAR_ExcludeInspectSelection, Name | Expected Filepath
    ;Arr2:=ForceOrder(Arr)
    ImagePaths2:=ForceOrder(ImagePaths)
    ;Clipboard:= "OLD:`n" StringifyObject(Arr) "`n---`n" StringifyObject(ImagePaths) "`n---`n" "`n---`nNEW:`n" StringifyObject(Arr2) "`n---`n" StringifyObject(ImagePaths2)
    f_UpdateLV(Arr,ImagePaths2)
    gui add, text,, % "Images/Names: (" ImagePaths.Count() "/" Arr.Count() ")"
    gui add, Button, gGFAR_DuplicatetoShiftFrame vvGFAR_DuplicatetoShiftFrame disabled, &Duplicate to shift frame
    gui add, Button,yp xp+170 vvGFAR_ExcludeSubmitButton gGFAR_ExcludeSubmit, &Continue

    GFAR_LastImage:=Func("GFAR_ExcludeOpenPath").Bind(ImageF)
    gui add, Button, yp xp+80 hwndGFAR_ExcludeOpenLastImage,Open &Last image
    GuiControl +g, %GFAR_ExcludeOpenLastImage%, % GFAR_LastImage

    GFAR_OpenFolder:=Func("GFAR_ExcludeOpenPath").Bind(gfarFolder)
    GFAR_OpenSelectedImage:=Func("GFAR_ExcludeInspectSelection").Bind(gfarFolder)
    gui add, Button, yp xp+130 hwndGFAR_ExcludeOpenFolder,Open &Folder
    gui add, Button, yp xp+130 hwndGFAR_ExcludeInspect, Open &Selected Image
    GuiControl +g, %GFAR_ExcludeOpenFolder%, % GFAR_OpenFolder
    GuiControl +g, %GFAR_ExcludeInspect%, % GFAR_OpenSelectedImage
    ;gui, add, Button, yp xp+80 gGFAR_ExcludeAbort
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

GFAR_DuplicatetoShiftFrame() {
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

    ;; Arr
    ;; ImagePaths
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

    Run % Path, , , vPID
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
    ;MsgBox 0x40034, % script.name " - Confirm", % "No changes occured. Return to first GUI"
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
            scriptWorkingDir:=renameFile(RenamedImage,Sel_Arr[2],true,Sel_Index,Sel.Count())
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
            scriptWorkingDir:=renameFile(RenamedImage,Sel_Arr[2],true,Sel_Index,Sel.Count())
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
    ttip(script.name " - Finished running")
    OnMessage(0x44, "OnMsgBox2")
    FinalInfoBox_String:="The script finished running.`n"
    FinalInfoBox_String.= (script.config.GFA_Renamer_settings.PutFilesOnClipboard)
        ? "The renamed image files are now ready to be pasted into whatever folder you want. Just open your intended folder and press 'CTRL-V'.`n`nAdditionally, a log file is copied. This log-file displays for every file that got renamed its original path. Files which are not renamed - and thus are missing in the output - are not shown in the log."
        : "- The folder containing the renamed images will open once this message box is closed.`n`nA log mapping each image to its new name is given in the file '__gfa_renamer_log.txt' within the output directory 'GFAR_WD'. The original image files are preserved in the original folder."
    MsgBox 0x40, % script.name " - Script finished",% FinalInfoBox_String
    OnMessage(0x44, "")
    scriptWorkingDir2:=""
    scriptWorkingDir2:=scriptWorkingDir
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

renameFile(Path,Name,Backup:=true,CurrentIndex:="",TotalCount:="") {
    static HasBackuped:=false
    SplitPath % Path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
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

repeatElementIofarrayNKtimes(array:="",repetitions:="",bDebug:=true,resetCallIndex:=False,Names:="") {
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
        assoc_1.Insert(Value, Key)

    }
    assoc_2 := {}
    for key, value in assoc_1 {
        assoc_2.Insert(Value, Key)

    }
    return assoc_2
}
