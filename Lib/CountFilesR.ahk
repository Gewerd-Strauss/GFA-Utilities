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
  f := Folder
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
