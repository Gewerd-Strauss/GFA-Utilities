AppError(Title, Message,boxOptions:="0x40010",TitlePrefix:=" - Error occured: ") {
    Gui +OwnDialogs
    MsgBox % boxOptions, % script.name TitlePrefix Title, % Message
    Gui -OwnDialogs
    return
}
