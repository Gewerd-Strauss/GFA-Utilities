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
    }
    getTab3Parents() {
        sections:={}
        for _, Argument in this.Arguments {
            sections[Argument.Tab3Parent]:=Argument.Tab3Parent
        }
        return sections
    }
}
