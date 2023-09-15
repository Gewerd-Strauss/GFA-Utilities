convertCSV2XLSX(dynGUI){
    if (dynGUI.GFA_Evaluation_Configfile_Location!="") {
        if (FileExist(dynGUI.GFA_Evaluation_Configfile_Location)) {
            SplitPath % dynGUI.GFA_Evaluation_Configfile_Location,, SearchDirectory
            if (csv2xlsx(SearchDirectory,true)) {
                ttip("Created missing xlsx-files for csv-files without xlsx-complements in " SearchDirectory)
            } else {
                ttip("There were no missing xlsx-files in subfolders of " SearchDirectory)
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
