checkDecimalsOnEdit(hEdit) ;wolf_II: check for number incl. decimal point
{ ;https://www.autohotkey.com/boards/viewtopic.php?f=76&t=31251&start=20
    ;-------------------------------------------------------------------------------
    static PrevNumber := [], Warning := "You can only enter a number!"
        , BadNeedle := "[^\d\.]"    ; "[^\d\.-]|^.+-"
    ControlGet Pos, CurrentCol,,, ahk_id %hEdit%
    GuiControlGet NewNumber,, %hEdit%
    StrReplace(NewNumber, ".",, DotCount)
    If NewNumber ~= BadNeedle Or DotCount > 1
    { ; BAD
        ControlGetPos x, y,,,, ahk_id %hEdit%
        ToolTip %Warning%, x, y-20
        SetTimer ToolTipOff, -2000
        GuiControl,, %hEdit%, % PrevNumber[hEdit]
        SendMessage 0xB1, % Pos-2, % Pos-2,, ahk_id %hEdit%
    }
    Else ; GOOD
        PrevNumber[hEdit] := NewNumber
    Return
    ToolTipOff:
    ToolTip ; off
    Return
}
