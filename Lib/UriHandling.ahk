
Clean(sText) {
    sText := _Decode(sText, 1)
    sText := StrReplace(sText, "'", "\'")
    return sText
}

DecodeUriComponent(sText) {
    return _Decode(sText, 2)
}

_Decode(sText, nMode) {
    static document := ""
    if (document = "") {
        document := ComObjCreate("HTMLFile")
        document.write("<meta http-equiv='X-UA-Compatible' content='IE=Edge'>")
    }
    switch (nMode) {
        case 1:
            document.write(sText)
            txt := document.documentElement.innerText
            document.close()
        case 2:
            txt := document.parentWindow.decodeURIComponent(sText)
        default:
            txt := "Unknown " A_ThisFunc "() mode."
    }
    return txt
}
