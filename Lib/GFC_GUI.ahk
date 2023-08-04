class gfcGUI extends dynamicGUI {
    generateConfig() {
        this.SubmitDynamicArguments()
        Object:={}
        for key, Argument in this.Arguments {
            Object[Argument.ConfigSection]:={}
        }
        for key, Argument in this.Arguments {
            Object[Argument.ConfigSection][key]:=Argument.Value
        }
        this.ConfigObject:=Object
        String:=""
        if IsObject(Object) {
            for SectionName, Entry in Object
            {
                String.="[" SectionName "]" "`n"
                Pairs := ""
                for key, Value in Entry
                {
                    WriteInd++
                    if !Instr(Pairs,key "=" Value "`n")
                        Pairs .= key "=" Value "`n"
                }
                String.=Pairs
            }
        } else {
            for SectionName, Entry in this.config
            {
                String.="[" SectionName "]" "`n"
                Pairs := ""
                for key, Value in Entry
                {
                    WriteInd++
                    if !Instr(Pairs,key "=" Value "`n")
                        Pairs .= key "=" Value "`n"
                }
                String.=Pairs
            }
        }
        this.ConfigString:=String
    }
    getTab3Parents() {
        sections:={}
        for _, Argument in this.Arguments {
            sections[Argument.Tab3Parent]:=Argument.Tab3Parent
        }
        return sections
    }
}
