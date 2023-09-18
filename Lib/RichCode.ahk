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
