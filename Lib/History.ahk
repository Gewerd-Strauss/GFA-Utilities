
buildHistory(History,NumberOfRecords,configpath:="") {
    if (configpath!="") {
        if HasVal(History,configpath) {
            History.RemoveAt(HasVal(History,configpath),1)
        }
        History.InsertAt(1,configpath)
    }
    if (History.Count()>NumberOfRecords) {
        History.Delete(NumberOfRecords+1,History.Count())
    }
    return History
}
