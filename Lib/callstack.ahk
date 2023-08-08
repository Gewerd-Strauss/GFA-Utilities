CallStack(deepness = 5, printLines = 1)
{
    loop % deepness
    {
        lvl := -1 - deepness + A_Index
        oEx := Exception("", lvl)
        oExPrev := Exception("", lvl - 1)
        FileReadLine line, % oEx.file, % oEx.line
        if(oEx.What = lvl)
        continue
        stack .= (stack ? "`n" : "") "File '" oEx.file "', Line " oEx.line (oExPrev.What = lvl-1 ? "" : ", in " oExPrev.What) (printLines ? ":`n" line : "") "`n"
    }
    return stack
}
