
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
    if A_IsCompiled {
        FileAppend % message, % errorlog_path
        MsgBox,, % "Error thrown: ", % message "`n`nThis error has been saved to the file '" errorlog_path "'"

    } else {
        if (IsDebug()) {
            FileAppend % message, *       ; throow to the db-console

        } else {
            MsgBox,, % "Error thrown: ", % message "`n`nThis error has been saved to the file '" errorlog_path "'"
            FileAppend % message, % errorlog_path
        }
    }
    return true                   ; Exit thread, prevent standard Exception thrown
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
