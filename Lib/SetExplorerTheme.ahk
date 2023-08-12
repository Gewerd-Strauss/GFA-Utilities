SetExplorerTheme(HCTL) { ; HCTL : handle of a ListView or TreeView control ;; just me, https://www.autohotkey.com/boards/viewtopic.php?p=49416#p49416
    If (DllCall("GetVersion", "UChar") > 5) {
        VarSetCapacity(ClassName, 1024, 0)
        If DllCall("GetClassName", "Ptr", HCTL, "Str", ClassName, "Int", 512, "Int")
            If (ClassName = "SysListView32") || (ClassName = "SysTreeView32")
                Return !DllCall("UxTheme.dll\SetWindowTheme", "Ptr", HCTL, "WStr", "Explorer", "Ptr", 0)
    }
    Return False
}
