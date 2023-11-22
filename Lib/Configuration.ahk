fEditSettings() {
    ; A_ThisHotkey
    gui GC: -AlwaysOnTop
    if ((!globalLogicSwitches.bIsAuthor & !globalLogicSwitches.bIsDebug) || (globalLogicSwitches.bIsAuthor & !globalLogicSwitches.bIsDebug)) {
        if ACS_InisettingsEditor(script.Name,script.scriptconfigfile,0,1,0) {
            OnMessage(0x44, "OnMsgBox_ChangedSettings")
            answer := AppError(script.name " > Editing program settings", "You changed settings. In order for these settings to take effect`, you need to reload the program. `n`nDoing so will discard any changes which are not yet saved. `n`nDo you want to reload the program with the updated settings now`, or use the previous settings to continue working?", 0x44)
            OnMessage(0x44, "")
            if (answer = "Yes") {
                reload()
            }
        } else {
            gui % "GC: "((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
        }
    } else if ACS_InisettingsEditor(script.Name,script.scriptconfigfile,0,1,1) {
        OnMessage(0x44, "OnMsgBox_ChangedSettings")
        answer := AppError(script.name " > Editing program settings", "You changed settings. In order for these settings to take effect`, you need to reload the program. `n`nDoing so will discard any changes which are not yet saved. `n`nDo you want to reload the program with the updated settings now`, or use the previous settings to continue working?", 0x44)
        OnMessage(0x44, "")
        if (answer = "Yes") {
            reload()
        }
    } else {
        gui % "GC: " ((script.config.Configurator_settings.AlwaysOnTop)?"+":"-") "AlwaysOnTop"
    }
    return
}
OnMsgBox_ChangedSettings() {
    DetectHiddenWindows On
    Process Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        ControlSetText Button1, Reload
        ControlSetText Button2, Keep settings
    }
}
restoredefaultConfig() {

}
setupdefaultconfig(Switch) {
    DefaultConfig=
        (LTrim

            [Version]
            ;Version Type: Text
            ;Version Hidden:
            build=130
            GFC_version=1.5.35
            [Configurator_settings]
            bDebugSwitch=0
            ;bDebugSwitch hidden:
            ;bDebugSwitch Type: Checkbox
            ;bDebugSwitch CheckboxName: Enable Debugging-Mode?
            ;bDebugSwitch Allow extended logging of various information to be output in the program's directory.
            ;bDebugSwitch Furthermore allows modifying hidden configuration keys, although it is not suggested to do so.
            ;bDebugSwitch Pressing Alt+Escape while in debug-mode will discard all data and restart the program. THIS CAN LEAD TO DATA-LOSS.
            ;bDebugSwitch Default: 0
            AlwaysOnTop=0
            ;AlwaysOnTop Type: Checkbox
            ;AlwaysOnTop CheckboxName: Set the GUI to be always on top?
            ;AlwaysOnTop This will keep the gui front and center on your screen. You can still hide the GUI via the tray-menu item.
            ;AlwaysOnTop Default: 0
            SizeSetting=1080p
            ;SizeSetting Determine how to scale the GUI: Auto will calculate the GUI-dimensions based on your main monitor's size. '1080p' and '1440p' will force a scaling based on that assumption.
            ;SizeSetting Type: DropDown 1080p|1440p||auto
            ;SizeSetting Default: auto
            ConfigHistoryLimit=25
            ;ConfigHistoryLimit Type: Integer
            ;ConfigHistoryLimit How many previous config files do you want to keep in your history?
            ;ConfigHistoryLimit Files that got moved are automatically removed
            ;ConfigHistoryLimit Default: 25
            bRunAsAdmin=0
            ;bRunAsAdmin Do you want to always start the script with Administrator-privileges?
            ;bRunAsAdmin Type: Checkbox
            ;bRunAsAdmin CheckboxName: Always start as Administrator? (Requires restart to take effect.)
            ;bRunAsAdmin Default: 0
            GFA_Evaluation_InstallationPath=%A_ScriptDir%\GFA_Evaluation.R
            ;GFA_Evaluation_InstallationPath Type: File
            ;GFA_Evaluation_InstallationPath Please select the location of your 'GFA_Evaluation.R'-Script.
            ;GFA_Evaluation_InstallationPath By default, this utility is shipped with a copy on hand, so you can use this.
            ;GFA_Evaluation_InstallationPath
            ;GFA_Evaluation_InstallationPath
            UseRelativeConfigPaths=0
            ;UseRelativeConfigPaths CheckboxName: Use relative paths to the starter-R-Script?
            ;UseRelativeConfigPaths Type: Checkbox
            ;UseRelativeConfigPaths Do you want to use relative configuration-paths when calling GFA_main()?
            ;UseRelativeConfigPaths This will make the script less reliant on the user's setup, but REQUIRES 
            ;UseRelativeConfigPaths that the r-script is located in the same folder as the configuration file.
            ;UseRelativeConfigPaths The configuration file must still remain at the top of the folder structure
            ;UseRelativeConfigPaths which contains all input data files.
            ;UseRelativeConfigPaths which contains all input data files.
            ;UseRelativeConfigPaths NOTE: The source-function loading the 'GFA_Evaluation.R'-script must be an absolute path.
            ;UseRelativeConfigPaths Default: 0
            INI_Encoding=UTF-16
            ;INI_Encoding Type: DropDown UTF-8|UTF-16||UTF-8-RAW
            ;INI_Encoding Select which encoding to use when generating the configuration-files for the R-Script.
            ;INI_Encoding 
            ;INI_Encoding MODIFYING FILE-ENCODINGS IS NOT TRIVIAL, and it is not recommended to change this setting unless you absolutely must.
            ;INI_Encoding 
            ;INI_Encoding 
            ;INI_Encoding You should KNOW WHAT YOU ARE DOING, and absolutely make a backup of any config-file you want to edit after changing encodings.
            ;INI_Encoding Note that 'UTF-8' specifically is 'UTF-8 with BOM', whereas 'UTF-8-RAW' is a BOM-less UTF-8-encoding. 
            ;INI_Encoding 
            ;INI_Encoding Default: UTF-16
            Custom_R_Script_Template=
            ;Custom_R_Script_Template Type: File
            ;Custom_R_Script_Template Default: <.R-File>
            ;Custom_R_Script_Template You can use a custom RCode template, instead of the default one given by this script. 
            ;Custom_R_Script_Template Once selected, the script will try to load it in, but may discard it and use its own if either of the following is true:
            ;Custom_R_Script_Template - the file the path points towards does not exist
            ;Custom_R_Script_Template - certain keywords are not present in the file
            ;Custom_R_Script_Template - %A_Tab% {GFA_EVALUATIONUTILITY}
            ;Custom_R_Script_Template - %A_Tab% {GFA_CONFIGLOCATIONFOLDER_WINDOWS}
            ;Custom_R_Script_Template - %A_Tab% {GFA_CONFIGLOCATIONFOLDER_MAC}
            ;Custom_R_Script_Template As a rule of thumb, your template should not change this default portion of it. 
            ;Custom_R_Script_Template You may add additional lines above or below.
            ;Custom_R_Script_Template Be aware that clearing the workspace after the lines sourcing 'GFA_Evaluation.R' will cause the script to fail.
            CheckUpdatesOnScriptStart=1
            ;CheckUpdatesOnScriptStart Type: Checkbox
            ;CheckUpdatesOnScriptStart CheckboxName: Do you want to always check for updates when running the program?
            ;CheckUpdatesOnScriptStart Default:1
            UpdateChannel=stable
            ;UpdateChannel Do you want to check for updates to the stable release, or keep up to date with the development-version?
            ;UpdateChannel Type: DropDown development||stable
            ;UpdateChannel Default: stable
            ;UpdateChannel 
            [GFA_Renamer_settings]

            filetype=jpg
            ;filetype Type: DropDown png||jpg
            ;filetype Set the image filetype that the Image-renamer considers.
            ;filetype You cannot choose multiple filetypes at once
            ;filetype Default: JPG

            PutFilesOnClipboard=1
            ;PutFilesOnClipboard Type: Checkbox
            ;PutFilesOnClipboard CheckboxName: Put renamed files onto the clipboard?
            ;PutFilesOnClipboard This allows you to f.e. directly paste them onto a stick so you can transfer them for analysis.
            ;PutFilesOnClipboard Default: 1

            CopyFiles=1
            ;CopyFiles Type: Checkbox
            ;CopyFiles CheckboxName: copy Files to the clipboard instead of cutting them?
            ;CopyFiles If you want to copy ("Ctrl+C") the resulting files, set this to 1. If you want to cut them ("Ctrl+X"), set this to 0.
            ;CopyFiles This has no effect if you set 'PutFilesOnClipboard' to 0.
            ;CopyFiles Default: 1

            CopyParentDirectory=1
            ;CopyParentDirectory Type: Checkbox
            ;CopyParentDirectory CheckboxName: Put the parent directory containing the resulting files on the clipboard instead?
            ;CopyParentDirectory This makes it easier to copy the images to a stick all-together because you do not need to create a folder for them first
            ;CopyParentDirectory Default: 1
            [TestSet]
            ;TestSet Hidden:
            ; only edit this if you know what you are doing.
            ;; The URL below points to the newest version of the gist. If this may ever change in a way you do not want, you can replace it with
            ; "https://gist.github.com/Gewerd-Strauss/d944d8abc295253ced401493edd377f2/archive/0d46c65c3993b1e8eef113776b68190e0802deb5.zip"
            ; to grab the first set that was published for this.
            URL=https://gist.github.com/Gewerd-Strauss/d944d8abc295253ced401493edd377f2/archive/main.zip
            Names= G14,G21,G28,G35,G42,UU
            PlantsPerGroup= 7
            [LastConfigsHistory]
            ;LastConfigsHistory Hidden:
            1=%A_ScriptDir%\res\Examples\Example 1 - keine Behandlung\GFA_conf.ini
            2=%A_ScriptDir%\res\Examples\Example 2 - 1 Behandlung\Beispiel-Konfiguration für Veersuch mit Behandlung.ini
            3=%A_ScriptDir%\res\Examples\Example 3 - Analog zum Tomaten-Verlauf\GFA_Evaluation_Example\Beispiel-Konfiguration für Veersuch mit Behandlung.ini
            4=%A_ScriptDir%\res\Examples\Example 4 - Establishment Drought Stress in Cornetto Exp2.1\GFA_conf.ini
            5=%A_ScriptDir%\res\Examples\Example 5 - Refinement Drought Stress in Cornetto Exp2.3\GFA_conf.ini
            [LastRScriptHistory]
            ;LastRScriptHistory Hidden:
            1=%A_ScriptDir%\res\Examples\Example 1 - keine Behandlung\EX1 RScript.R
            2=%A_ScriptDir%\res\Examples\Example 2 - 1 Behandlung\EX2 RScript.R
            3=%A_ScriptDir%\res\Examples\Example 3 - Analog zum Tomaten-Verlauf\GFA_Evaluation_Example\EX3 RScript.R
            4=%A_ScriptDir%\res\Examples\Example 4 - Establishment Drought Stress in Cornetto Exp2.1\EX4 RScript.R
            5=%A_ScriptDir%\res\Examples\Example 5 - Refinement Drought Stress in Cornetto Exp2.3\EX5 RScript.R
        )
    gfcGUIconfig=
        (LTRIM
            Experiment::blank
            %A_Tab%;; 1. Grouping
            %A_Tab%PotsPerGroup:Edit|Type:Integer|Default:7|String:"Set the number of pots per group/combination"|TTIP:[Facet2D==TRUE]\nHere, combination is a combination of a member of 'UniqueGroups' and a member of 'Facet2DVar'|ctrlOptions:number|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%UniqueGroups:Edit|Type:String|Default:""|String:"Set the comma-separated list of all unique group names, AS ORDERED IN THE DATA-FILES"|TTIP:It is required to ensure that groups are located at the same indeces across all data files.\n\nIf you set 'Facet2D' to TRUE, this must have as many entries as 'Facet2DVar'|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%GroupsOrderX:Edit|Type:String|Default:""|String:"Set the comma-separated order of groups in the plots along X-axis"|TTIP:Order the Groups along the X-Axis. Groups are ordered left to right|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%GroupsOrderY:Edit|Type:String|Default:""|String:"Set the comma-separated order of groups in the plots along Y-Axis (only for facetting)"|TTIP:[Facet2D==TRUE]\nOrder the Groups along the Y-Axis. Groups are ordered top to bottom.|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%RefGroup:Edit|Type:String|Default:""|String:"Set the reference group for all statistical tests"|TTIP:\n[Facet2D==FALSE]\nFor a normal plot, this must be a member of 'UniqueGroups'\n\n[Facet2D==TRUE]\nFor a facetted plot, this must be a combination of 1 member of 'Facet2DVar' and 'UniqueGroups', separated by a dot (.).\nThe order is always '[UniqueGroups_Member].[Facet2DVar_Member]'\nExample:\n'Ungestresst.Unbehandelt'|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Facet2D:Checkbox|Type:boolean|Default:0|String:"Do you want to facet the plot, f.e. over a treatment?"|TTIP:Clarification: Facetting here refers to the segmentation of the plots along the Y-Axis, NOT along the X-Axis.\nFor segmenting along the X-Axis, refer to 'UniqueGroups' and 'GroupsOrderX'.|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Facet2DVar:Edit|Type:String|Default:""|String:"Set the comma-separated list of facet-members to assing to the 'UniqueGroups'"|TTIP:[Facet2D==TRUE]\nClarification: The entries you specified for 'UniqueGroups' must each match a single entry in this list as well|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;
            %A_Tab%Palette_Boxplot:Edit|Type:String|Default:"yellow","orange","orangered","red","darkred","black","white"|String:Set the colors for the Summaryplot|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the overview plot|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%Palette_Lines:Edit|Type:String|Default:"yellow","orange","orangered","red","darkred","black","black"|String:Set the colors for the Summaryplot|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the overview plot|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%Palette_Boxplot2:Edit|Type:String|Default:"white","yellow","orange","orangered","red","darkred","black"|String:Set the colors for the daily plots|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the daily plots|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%Palette_Lines2:Edit|Type:String|Default:"black","yellow","orange","orangered","red","darkred","black"|String:Set the colors for the daily plots|TTIP:Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the daily plots|Tab3Parent:1. Grouping|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|ctrlOptions:w400|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;
            %A_Tab%;; 2. General Configuration
            %A_Tab%T0:DateTime|Type:String|Default:{A_Now}|String:"Set the T0-date for calculating 'plant-age' for your experiment, in format dd.MM.yyyy (24.12.2023)"|TTIP:This is relevant mostly for calculating the plant-age plotted on the y-axis.|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Normalise:Checkbox|Type:boolean|Default:1|String:"Do you want to normalise your leaf area?"|TTIP:This accesses the data-column 'plant_area_normalised'. For more info, check the documentation.|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%language:DDL|Type:String|Default:"English"|String:"Select language for auto-generated labels"|ctrlOptions:English,German|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%used_filesuffix:DDL|Type:String|Default:"xlsx"|String:"Select the filetype you want to ingest"|ctrlOptions:xlsx,csv|TTIP:'xlsx' is recommended. 'csv' was tested, but not as adamantly as xlsx. It should not make any difference, but that is not guaranteed.|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Filename_Prefix:Edit|Type:String|Default:"GF"|TTIP:Decide the file-prefix used when saving figures and statistical results.\n\nATTENTION:\nChanging this if files have been generated before will result in those files not\nbeing overwritten so you will end up with an old and a current set of result-\nfiles (images/excel-sheets/RData-files)|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%filename_date_format:Combobox|Type:String|Default:"`%Y-`%m-`%d"|String:"Select the date format for saved files. Editing allowed"|TTIP:Does not control the date format on the figure. For that, see option 'figure_date_format'.|ctrlOptions:r5,`%d.`%m.`%Y,`%Y-`%m-`%d|Tab3Parent:2. GeneralConfiguration|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%Debug:Checkbox|Type:boolean|Default:0|String:"Do you want to print debug information?"|Tab3Parent:2. GeneralConfiguration|Link:Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}f|Linktext:?|ConfigSection:General
            %A_Tab%;;; figure
            %A_Tab%Name:Edit|Type:String|Default:"Experiment X"|String:"Set the name of the Experiment as seen in the figure title"|Tab3Parent:3. Figure|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%PlotMeanLine:Checkbox|Type:boolean|Default:1|String:"Do you want to plot the line connecting the means of each group's boxplots?"|Tab3Parent:3. Figure|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Theme:Edit|Type:Integer|Default:7|String:"Choose your default theme."|Max:99|Min:1|ctrlOptions:Number|Tab3Parent:3. Figure|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
        )
    gfcGUIconfig2=
        (LTRIM
            %A_Tab%;;; axes
            %A_Tab%RelativeColnames:Checkbox|Type:boolean|Default:1|String:"Do you want to display the X-positions as 'days since T0'?"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowBothColnames:Checkbox|Type:boolean|Default:0|String:"Do you want to display the X-positions as 'days since T0 - date'?"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ForceAxes:Checkbox|Type:boolean|Default:0|String:"Do you want to force the Y-Axis scaling? This requires setting 'YLimits'"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%YLimits:Edit|Type:String|Default:"0,150"|String:"Set the minimum and maximum limit for the Y-Axis. Does not take effect if 'ForceAxes' is false. Used for all plots"|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%BreakStepSize:Edit|Type:number|Default:25|String:Set the spacing between numbered breaks on the Y-Axis. Requires ForceAxes=T"|ctrlOptions: gcheckDecimalsOnEdit|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%axis_units_x:Edit|Type:String|Default:Tage,days|String:"Set the unit of the X-axis (for the Overview-plot)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%axis_units_y:Edit|Type:String|Default:cm^2,cm^2|String:"Set the unit of the Y-axis (for the Overview-plot)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%axis_units_x_Daily:Edit|Type:String|Default:/,/|String:"Set the unit of the X-axis (for the daily plots)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%axis_units_y_Daily:Edit|Type:String|Default:cm^2,cm^2|String:"Set the unit of the Y-axis (for the daily plots)."|TTIP:Format: '[German Text],[English Text]'. Replace a field with "/" to skip it|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%figure_date_format:Combobox|Type:String|Default:"`%d.`%m.`%Y"|String:"Select the date format for dates on the x-axis or in titles. Editing allowed"|TTIP:[RelativeColNames==TRUE]\nDoes not take effect\n\n\n[RelativeColNames==FALSE]\nSet the format for dates on the x-axis\n\nDoes not control the date format for the saved files. For that, see option 'filename_date_format'.|ctrlOptions:`%d.`%m.`%Y,`%Y-`%m-`%d|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%XLabel:Edit|Type:String|Default:"Time since repotting"|String:"Set the xlabel-string for the summary plot."|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%XLabel_Daily:Edit|Type:String|Default:"Treatment Groups"|String:"Set the xlabel-string for the daily analyses."|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%YLabel:Edit|Type:String|Default:"green plant area"|String:"Set the ylabel-string for the summary plot and daily analyses."|Tab3Parent:4. Axes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Experiment
            %A_Tab%;;
            %A_Tab%;;; Statistics on Plot
            %A_Tab%ShowNAtallboxplots:Checkbox|Type:boolean|Default:0|String:"Do you want to print 'n=XX' above every boxplot in the daily plots?"|TTIP:[ShowNAtallboxplot==TRUE]:\nThe Sample size is printed above every day.\nThis is generally not recommended as it will become cluttered with increasing number of days.\n\n[ShowNAtallboxplot==FALSE]\nDo not print sample sizes above every day. Sample size is displayed via the plot_subtitle element instead (but only if you enable rr)|Tab3Parent:5. Statistics and its displaying|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%PlotSampleSize:Checkbox|Type:boolean|Default:1|String:"Do you want to plot the sample size of each group's boxplots?"|Tab3Parent:5. Statistics and its displaying|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowOnlyIrregularN:Checkbox|Type:boolean|Default:1|String:"Do you want to only plot sample sizes which differ from 'PotsPerGroup'?|TTIP:Requires also ticking 'PlotSampleSize'|Tab3Parent:5. Statistics and its displaying|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%;;
            %A_Tab%;;; Fontsizes
            %A_Tab%Fontsize_General:Edit|Type:number|Default:10.0|String:"Set the general fontsize text elements on all plots."|TTIP:Default is 10.0. Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_XAxisLabel:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis names/titles"|TTIP:That is, the dates/plant ages.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_YAxisLabel:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis names/titles"|TTIP:That is, plant area values, '25','50','75',...\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_XAxisTicks:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis ticks"|TTIP:That is, the numerical/date-scaling on the x-axis.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_YAxisTicks:Edit|Type:number|Default:10.0|String:"Set the fontsize for the axis ticks"|TTIP:That is, the numerical scaling on the y-axis.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_LegendText:Edit|Type:number|Default:10.0|String:"Set the fontsize for the legend entries"|TTIP:That is, the group names in the legend itself.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_LegendTitle:Edit|Type:number|Default:10.0|String:"Set the fontsize for the legend title"|TTIP:That is, the 'title' of the legend.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_PValue:Edit|Type:number|Default:2.5|String:"Set the fontsize for the p-values in the daily plots"|TTIP:Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%Fontsize_SampleSize:Edit|Type:number|Default:2.5|String:"Set the fontsize for the sample size in the daily plots"|TTIP:Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.|ctrlOptions: w400 gcheckDecimalsOnEdit|Tab3Parent:6. Fontsizes|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:Fontsizes
            %A_Tab%;;
            %A_Tab%;;; Titles
            %A_Tab%DebugText:Text|Type:text|Default:"Setting [DEBUG==TRUE]" in section '2. General Configuration' will overwrite any settings made in this section"|String:"Setting [DEBUG==TRUE]" in section '2. General Configuration' will overwrite any settings made in this section"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitle:Checkbox|Type:boolean|Default:0|String:"Do you want to show the title above the summary plot?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitleSub:Checkbox|Type:boolean|Default:0|String:"Do you want to show the sub-title above the summary plot?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitle_Daily:Checkbox|Type:boolean|Default:0|String:"Do you want to show the title above the daily plots?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitleSub_Daily:Checkbox|Type:boolean|Default:0|String:"Do you want to show the sub-title above the daily plots?"|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%ShowTitleDateWhere:DDL|Type:String|Default:"SubTitle"|String:"Select if the date (range) should be appended to the end of the title- or subtitle-element.|TTIP:For date-format, see key 'figure_date_format' under section '4. Axes'\n\n[ShowTitle==FALSE]\nNo effect.|ctrlOptions:Title,SubTitle,nowhere|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Title:Edit|Type:String|Default:""|String:"Enter the title you want to use for the summary plot. Leave empty to use the default title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%Title_Daily:Edit|Type:String|Default:""|String:"Enter the title you want to use for the daily plots. Leave empty to use the default title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%TitleSub:Edit|Type:String|Default:""|String:"Enter the sub-title you want to use for the summary plot. Leave empty to use the default sub-title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General
            %A_Tab%TitleSub_Daily:Edit|Type:String|Default:""|String:"Enter the sub-title you want to use for the daily plots. Leave empty to use the default sub-title."|TTIP:Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhereA'.|Tab3Parent:7. Titles|Link:https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/Gr-nfl-chen-Utilities/blob/docs/res/Manual.html#sec-{Parameter}|Linktext:?|ConfigSection:General

        )
    gfcGUIconfig.="`n" gfcGUIconfig2
    if (Switch=1) {
        if (!FileExist(script.scriptconfigfile) || globalLogicSwitches.DEBUG ) {
            SplitPath % script.scriptconfigfile,,configDirectory
            if (!FileExist(configDirectory)) {
                FileCreateDir % configDirectory
            }
            DefaultConfig:=DerefAHKVariables(DefaultConfig)
            writeFile(script.scriptconfigfile,DefaultConfig,"UTF-16",,true)
            return
        }
    } else if (Switch=2) {
        if (!FileExist(script.gfcGUIconfigfile) || globalLogicSwitches.DEBUG ) {
            SplitPath % script.gfcGUIconfigfile,,configDirectory
            if (!FileExist(configDirectory)) {
                FileCreateDir % configDirectory
            }
            gfcGUIconfig:=LTrim(gfcGUIconfig)
                , gfcGUIconfig:=DerefAHKVariables(gfcGUIconfig)
            writeFile(script.gfcGUIconfigfile,gfcGUIconfig,"UTF-16",,true)
            return
        }
    }
    return
}



;#############   Edit ini file settings in a GUI   #############################
;  A function that can be used to edit settings in an ini file within it's own
;  GUI. Just plug this function into your script.
;
;  by Rajat, mod by toralf
;  www.autohotkey.com/forum/viewtopic.php?p=69534#69534
;
;   Tested OS: Windows XP Pro SP2
;   AHK_version= 1.0.44.09     ;(http://www.autohotkey.com/download/)
;   Language: English
;   Date: 2006-08-23
;
;   Version: 6
;
; changes since 5:
; - add key type "checkbox" with custom control name
; - added key field options (will only apply in Editor window)
; - whole sections can be set hidden
; - reorganized code in Editor and Creator
; - some fixes and adjustments
; changes since 1.4
; - Creator and Editor GUIs are resizeable (thanks Titan). The shortened Anchor function
;    is added with a long name, to avoid nameing conflicts and avoid dependencies.
; - switched from 1.x version numbers to full integer version numbers
; - requires AHK version 1.0.44.09
; - fixed blinking of description field
; changes since 1.3:
; - added field option "Hidden" (thanks jballi)
; - simplified array naming
; - shorted the code
; changes since 1.2:
; - fixed a bug in the description (thanks jaballi and robiandi)
; changes since 1.1:
; - added statusbar (thanks rajat)
; - fixed a bug in Folder browsing
; changes since 1.0:
; - added default value (thanks rajat)
; - fixed error with DisableGui=1 but OwnedBy=0 (thanks kerry)
; - fixed some typos
;  
; format:
; =======
;   IniSettingsEditor(ProgName, IniFile[, OwnedBy = 0, DisableGui = 0])
;
; with
;   ProgName - A string used in the GUI as text to describe the program 
;   IniFile - that ini file name (with path if not in script directory)
;   OwnedBy - GUI ID of the calling GUI, will make the settings GUI owned
;   DisableGui - 1=disables calling GUI during editing of settings
;
; example to call in script:
;   IniSettingsEditor("Hello World", "Settings.ini", 0, 0)
;
; Include function with:
;   #Include Func_IniSettingsEditor_v6.ahk
;
; No global variables needed.
;
; features:
; =========
; - the calling script will wait for the function to end, thus till the settings
;     GUI gets closed. 
; - Gui ID for the settings GUI is not hard coded, first free ID will be used 
; - multiple description lines (comments) for each key and section possible 
; - all characters are allowed in section and key names
; - when settings GUI is started first key in first section is pre-selected and
;     first section is expanded
; - tree branches expand when items get selected and collapse when items get
;     unselected
; - key types besides the default "Text" are supported 
;    + "File" and "Folder", will have a browse button and its functionality 
;    + "Float" and "Integer" with consistency check 
;    + "Hotkey" with its own hotkey control 
;    + "DateTime" with its own datetime control and custom format, default is
;        "dddd MMMM d, yyyy HH:mm:ss tt"
;    + "DropDown" with its own dropdown control, list of choices has to be given
;        list is pipe "|" separated 
;    + "Checkbox" where the name of the checkbox can be customized
; - default value can be specified for each key 
; - keys can be set invisible (hidden) in the tree
; - to each key control additional AHK specific options can be assigned  
;
; format of ini file:
; ===================
;     (optional) descriptions: to help the script's users to work with the settings 
;     add a description line to the ini file following the relevant 'key' or 'section'
;     line, put a semi-colon (starts comment), then the name of the key or section
;     just above it and a space, followed by any descriptive helpful comment you'd
;     like users to see while editing that field. 
;     
;     e.g.
;     [SomeSection]
;     ;somesection This can describe the section. 
;     Somekey=SomeValue 
;     ;somekey Now the descriptive comment can explain this item. 
;     ;somekey More then one line can be used. As many as you like.
;     ;somekey [Type: key type] [format/list] 
;     ;somekey [Default: default key value] 
;     ;somekey [Hidden:] 
;     ;somekey [Options: AHK options that apply to the control] 
;     ;somekey [CheckboxName: Name of the checkbox control] 
;     
;     (optional) key types: To limit the choice and get correct input a key type can
;     be set or each key. Identical to the description start an extra line put a
;     semi-colon (starts comment), then the name of the key with a space, then the
;     string "Type:" with a space followed by the key type. See the above feature
;     list for available key types. Some key types have custom formats or lists,
;     they are written after the key type with a space in-between.
;     
;     (optional) default key value: To allow a easy and quick way back to a 
;     default value, you can specify a value as default. If no default is given,
;     users can go back to the initial key value of that editing session.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Default:" with a space followed by the default value.
;
;     (optional) hide key in tree: To hide a key from the user, a key can be set 
;     hidden.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Hidden:".
;
;     (optional) add additional AHK options to key controls. To limit the input
;     or enforce a special input into the key controls in the GUI, additional 
;     AHK options can be specified for each control.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "Options" with a space followed by a list of AHK options for that
;     AHK control (all separated with a space).
;
;     (optional) custom checkbox name: To have a more relavant name then e.g.
;     "status" a custom name for the checkbox key type can be specified.
;     Format: Identical to the description start an extra line, put a semi-colon
;     (starts comment line), then the name of the key with a space, then the
;     string "CheckboxName:" with a space followed by the name of the checkbox.
;
;
; limitations:
; ============
; - ini file has to exist and created manually or with the IniFileCreator script
; - section lines have to start with [ and end with ]. No comments allowed on
;     same line
; - ini file must only contain settings. Scripts can't be used to store setting,
;     since the file is read and interpret as a whole. 
; - code: can't use g-labels for tree or edit fields, since the arrays are not
;     visible outside the function, hence inside the g-label subroutines. 
; - code: can't make GUI resizable, since this is only possible with hard
;     coded GUI ID, due to %GuiID%GuiSize label

;@ahk-neko-ignore 1 line; Function too big
ACS_IniSettingsEditor(ProgName,IniFile,OwnedBy = 0,DisableGui = 0, ShowHidden = 0) {
    static Pos
    global bSettingsChanged:=false
    ;Find a GUI ID that does not exist yet 
    Loop, 99 { 
        Gui %A_Index%:+LastFoundExist
        If !WinExist() { 
            SettingsGuiID := A_Index
            break 
        }Else If (A_Index = 99){ 
            MsgBox 4112, Error in IniSettingsEditor function, Can't open settings dialog,`nsince no GUI ID was available.
            Return 0   
        } 
    } 
    Gui %SettingsGuiID%:Default

    ;apply options to settings GUI 
    If OwnedBy { 
        Gui +ToolWindow +Owner%OwnedBy%
        If DisableGui 
            Gui %OwnedBy%:+Disabled
    }Else
        DisableGui := False 

    Gui +Resize +LabelGuiIniSettingsEditor
    vCheckOldSizes:=0
    ;create GUI (order of the two edit controls is crucial, since ClassNN is order dependent) 
    if vCheckOldSizes
    {
        ;; OLD VERSION - more compact. I prefer a bigger gui when editing, as I often have much longer variable names and texts
        Gui Add, Statusbar
        Gui Add, TreeView, x16 y75 w180 h242 0x400
        Gui Add, Edit, x215 y114 w340 h20,                           ;ahk_class Edit1
        Gui Add, Edit, x215 y174 w340 h100 ReadOnly,                 ;ahk_class Edit2
        Gui Add, Button, x250 y335 w70 h30 gExitSettings , E&xit     ;ahk_class Button1
        Gui Add, Button, x505 y88 gBtnBrowseKeyValue Hidden, B&rowse ;ahk_class Button2
        Gui Add, Button, x215 y274 gBtnDefaultValue, &Restore        ;ahk_class Button3
        Gui Add, DateTime, x215 y114 w340 h20 Hidden,                ;ahk_class SysDateTimePick321
        Gui Add, Hotkey, x215 y114 w340 h20 Hidden,                  ;ahk_class msctls_hotkey321
        Gui Add, DropDownList, x215 y114 w340 h120 Hidden,           ;ahk_class ComboBox1
        Gui Add, CheckBox, x215 y114 w340 h20 Hidden,                ;ahk_class Button4
        Gui Add, GroupBox, x4 y63 w560 h263 ,                        ;ahk_class Button5
        Gui Font, Bold
        Gui Add, Text, x215 y93, Value                               ;ahk_class Static1
        Gui Add, Text, x215 y154, Description                        ;ahk_class Static2
        Gui Add, Text, x45 y48 w480 h20 +Center, ( All changes are Auto-Saved )
        Gui Font, S16 CDefault Bold, Verdana
        Gui Add, Text, x45 y13 w600 h25 +Center, Settings for %ProgName%

    }
    Else
    {
        Gui Add, Statusbar
        Gui Add, TreeView, x16 y75 w320 h484 0x400                                                       ; w180 h284 â†’ w+140, h+242
        ; Gui, Add, Edit, x360 y114 w340 h20,                           ;ahk_class Edit1
        Gui Add, Edit, x360 y114 w340 h20,                           ;ahk_class Edit1
        Gui Add, Edit, x360 y174 w340 h355 ReadOnly,                 ;ahk_class Edit2
        Gui Add, Button, x390 y533 w70 h30 gExitSettings , E&xit     ;ahk_class Button1
        Gui Add, Button, x505 y88 gBtnBrowseKeyValue Hidden, B&rowse ;ahk_class Button2
        Gui Add, Button, x505 y533 w70 h30 gBtnDefaultValue, &Restore        ;ahk_class Button3
        Gui Add, DateTime, x360 y114 w340 h20 Hidden,                ;ahk_class SysDateTimePick321
        Gui Add, Hotkey, x360 y114 w340 h20 Hidden,                  ;ahk_class msctls_hotkey321
        Gui Add, DropDownList, x360 y114 w340 h120 Hidden,           ;ahk_class ComboBox1
        Gui Add, CheckBox, x360 y114 w340 h20 Hidden,                ;ahk_class Button4
        Gui Add, GroupBox, x4 y63 w712 h504 ,                        ;ahk_class Button5
        Gui Font, Bold
        Gui Add, Text, x360 y93, Value                               ;ahk_class Static1
        Gui Add, Text, x360 y154, Description                        ;ahk_class Static2
        Gui Add, Text, x45 y48 w480 h20 +Center, ( All changes are Auto-Saved )
        Gui Font, S16 CDefault Bold, Verdana
        Gui Add, Text, x45 y13 w600 h25 +Center, Settings for %ProgName%

    }



    ;read data from ini file, build tree and store values and description in arrays 
    Loop, Read, %IniFile% 
    { 
        CurrLine := A_LoopReadLine
        CurrLineLength := StrLen(CurrLine) 

        ;blank line 
        If CurrLine is space 
            Continue 

        ;description (comment) line 
        If ( InStr(CurrLine,";") = 1 ){
            StringLeft chk2, CurrLine, % CurrLength + 2
            StringTrimLeft Des, CurrLine, % CurrLength + 2 ; create the description.
            ;description of key
            If ( %CurrID%Sec = False AND ";" CurrKey A_Space = chk2){ 
                ;handle key types  
                If ( InStr(Des,"Type: ") = 1 ){ 
                    StringTrimLeft Typ, Des, 6
                    Typ := Typ
                    Des := "`n" Des     ;add an extra line to the type definition in the description control

                    ;handle format or list  
                    If (InStr(Typ,"DropDown ") = 1) {
                        StringTrimLeft Format, Typ, 9
                        %CurrID%For := Format
                        Typ := "DropDown"
                        Des := ""
                    }Else If (InStr(Typ,"DateTime") = 1) {
                        StringTrimLeft Format, Typ, 9
                        If Format is space
                            Format := "dddd MMMM d, yyyy HH:mm:ss tt" 
                        %CurrID%For := Format
                        Typ := "DateTime"
                        Des := ""
                    }
                    ;set type
                    %CurrID%Typ := Typ 
                    ;remember default value
                }Else If ( InStr(Des,"Default: ") = 1 ){ 
                    StringTrimLeft Def, Des, 9
                    %CurrID%Def := Def
                    ;remember custom options  
                }Else If ( InStr(Des,"Options: ") = 1 ){ 
                    StringTrimLeft Opt, Des, 9
                    %CurrID%Opt := Opt
                    Des := ""
                    ;remove hidden keys from tree
                }Else If ( InStr(Des,"Hidden:") = 1 ) and (!ShowHidden){   ; allow override of invisible keys/sections if variable is specified - such as a developer wanting to edit hidden variables easier.
                    TV_Delete(CurrID)
                    Des := ""
                    CurrID := ""
                    ;handle checkbox name
                }Else If ( InStr(Des,"CheckboxName: ") = 1 ){  
                    StringTrimLeft ChkN, Des, 14
                    %CurrID%ChkN := ChkN
                    Des := ""
                } 
                %CurrID%Des := %CurrID%Des "`n" Des 
                ;; testing code
                ; d:=%CurrID%Des
                ; tooltip, % d
                ;; testing code end - remove at end.
                ;description of section 
            } Else If ( %CurrID%Sec = True AND ";" CurrSec A_Space = chk2 ){
                ;remove hidden section from tree
                If ( InStr(Des,"Hidden:") = 1 ) and (!ShowHidden) {  
                    TV_Delete(CurrID)
                    Des := ""
                    CurrSecID := ""
                }
                ;set description
                %CurrID%Des := %CurrID%Des "`n" Des 
            } 
            ;remove leading and trailing whitespaces and new lines
            If ( InStr(%CurrID%Des, "`n") = 1 )
                StringTrimLeft %CurrID%Des, %CurrID%Des, 1
            Continue 
        } 

        ;section line 
        If ( InStr(CurrLine, "[") = 1 And InStr(CurrLine, "]", "", 0) = CurrLineLength) { 
            ;extract section name
            StringTrimLeft CurrSec, CurrLine, 1
            StringTrimRight CurrSec, CurrSec, 1
            CurrSec := CurrSec
            CurrLength := StrLen(CurrSec)  ;to easily trim name off of following comment lines

            ;add to tree
            CurrSecID := TV_Add(CurrSec)
            CurrID := CurrSecID
            %CurrID%Sec := True
            CurrKey := ""
            Continue 
        } 

        ;key line 
        Pos := InStr(CurrLine,"=") 
        If ( Pos AND CurrSecID ){ 
            ;extract key name and its value
            StringLeft CurrKey, CurrLine, % Pos - 1
            StringTrimLeft CurrVal, CurrLine, %Pos%
            CurrKey := CurrKey             ;remove whitespace
            CurrVal := CurrVal
            CurrLength := StrLen(CurrKey)

            ;add to tree and store value
            CurrID := TV_Add(CurrKey,CurrSecID) 
            %CurrID%Val := CurrVal
            %CurrID%Sec := False

            ;store initial value as default for restore function
            ;will be overwritten if default is specified later on comment line
            %CurrID%Def := CurrVal 
        } 
    } 

    ;select first key of first section and expand section
    TV_Modify(TV_GetChild(TV_GetNext()), "Select")

    ;show Gui and get UniqueID
    ; Gui, Show, w570 h400, %ProgName% Settings 
    Gui Show,, %ProgName% Settings
    Gui +LastFound
    GuiID := WinExist() 

    ;check for changes in GUI 
    Loop { 
        ;get current tree selection 
        CurrID := TV_GetSelection() 

        If SetDefault { 
            %CurrID%Val := %CurrID%Def 
            LastID := 0
            SetDefault := False
            SetDefault_Checkbox:=true
            ValChanged := True
        } 

        MouseGetPos,,, AWinID, ACtrl
        If ( AWinID = GuiID){ 
            If ( ACtrl = "Button3")  
                SB_SetText("Restores Value to default (if specified), else restores it to initial value before change")
        } Else 
            SB_SetText("") 

        ;change GUI content if tree selection changed 
        If (CurrID <> LastID) {
            ;remove custom options from last control
            Loop, Parse, InvertedOptions, %A_Space%
                GuiControl %A_Loopfield%, %ControlUsed%

            ;hide/show browse button depending on key type
            Typ := %CurrID%Typ 
            If Typ in File,Folder 
                GuiControl Show , Button2,
            Else 
                GuiControl Hide , Button2,

            ;set the needed value control depending on key type
            If (Typ = "DateTime")
                ControlUsed := "SysDateTimePick321"
            Else If ( Typ = "Hotkey" )
                ControlUsed := "msctls_hotkey321"
            Else If ( Typ = "DropDown")
                ControlUsed := "ComboBox1"
            Else If ( Typ = "CheckBox")
                ControlUsed := "Button4"
            Else                    ;e.g. Text,File,Folder,Float,Integer or No Tyo (e.g. Section) 
                ControlUsed := "Edit1"

            ;hide/show the value controls
            Controls := "SysDateTimePick321,msctls_hotkey321,ComboBox1,Button4,Edit1"
            Loop, Parse, Controls, `,
                If ( ControlUsed = A_LoopField )
                    GuiControl Show , %A_LoopField%,
            Else
                GuiControl Hide , %A_LoopField%,

            If ( ControlUsed = "Button4" )
                GuiControl,  , Button4, % %CurrID%ChkN

            ;get current options
            CurrOpt := %CurrID%Opt
            ;apply current custom options to current control and memorize them inverted
            InvertedOptions := ""
            Loop, Parse, CurrOpt, %A_Space%
            {
                ;get actual option name
                StringLeft chk, A_LoopField, 1
                StringTrimLeft chk2, A_LoopField, 1
                If chk In +,-
                {
                    GuiControl %A_LoopField%, %ControlUsed%
                    If (chk = "+")
                        InvertedOptions := InvertedOptions -chk2
                    Else
                        InvertedOptions := InvertedOptions +chk2
                }Else {
                    GuiControl +%A_LoopField%, %ControlUsed%
                    InvertedOptions := InvertedOptions - A_LoopField
                }
            }

            If %CurrID%Sec {                      ;section got selected
                CurrVal := ""
                GuiControl, , Edit1,
                GuiControl Disable , Edit1,
                GuiControl Disable , Button3,
            }Else {                               ;new key got selected
                CurrVal := %CurrID%Val   ;get current value
                GuiControl, , Edit1, %CurrVal%   ;put current value in all value controls
                GuiControl Text, SysDateTimePick321, % %CurrID%For
                GuiControl, , SysDateTimePick321, %CurrVal%
                GuiControl, , msctls_hotkey321, %CurrVal%
                GuiControl, , ComboBox1, % "|" %CurrID%For
                GuiControl ChooseString, ComboBox1, %CurrVal%
                GuiControl, , Button4 ,     ;; Untested Hotfix for the Checkbox not clearing correctly. This means you cannot give anymore direct prompts, but you can use the description-edit field for that instead.
                guicontrol, ,Button4, %CurrVal%
                ; anchor here 
                if (ControlUsed="Button4") ;; Tested Hotfix for the Checkbox string not displaying after using the above hotfix to alway clear it. Allows direct checkbox prompts to be given again, this time without clearing-issues.
                {
                    CurrVal:=%CurrID%ChkN
                    GuiControl, , Button4 , %CurrVal%
                    ; GuiControl,  
                }
                Else
                    GuiControl, , Button4 , %CurrVal%
                GuiControl Enable , Edit1,
                GuiControl Enable , Button3,
                ; GuiControl, Chec

                ;;; There doesn't seem to be code to clear the description out from the previous type 
                ;;; when selecting 'CheckBox' as your next type. 


            } 
            If  !(%CurrID%Sec) 	; normal key was selected
            {                      
                GuiControl, , Edit2, ; clear out the description-field to avoid larger previous texts from "ghosting" behind the new entry.
                GuiControl, , Edit2, % %CurrID%Des
            }
            if (%CurrID%Sec) 	; section got selected
            {
                GuiControl, , Edit2,
                GuiControl, , Edit2, % %CurrID%Des
            }
        }
        LastID := CurrID                   ;remember last selection

        ;sleep to reduce CPU load
        Sleep 100

        ;exit endless loop, when settings GUI closes 
        If !WinExist("ahk_id" GuiID) 
            Break 

        ;if key is selected, get value
        If (%CurrID%Sec = False){
            ; if (%CurrID%Typ!="Checkbox")
            GuiControlGet NewVal, , %ControlUsed%  ; get the new value from the recent input
            ;save key value when it has been changed 
            If ( NewVal <> CurrVal OR ValChanged ) {
                ValChanged := False
                if (Typ= "Checkbox")
                {
                    ;  d:=%CurrID%Val
                    ; GuiControl, , Edit1, %NewVal%
                    ; guicontrol, ,Button4, %d%
                    if SetDefault_Checkbox
                    {
                        SetDefault_Checkbox:= !SetDefault_Checkbox
                        RestoredVal:=%CurrID%Def ;;; this is a functional hotfix if you want to restore to DEF. Not sure how to implement restoring to previous entry though.
                        guicontrol, ,Button4, %RestoredVal%
                    }
                }
                ; 	GuiControl
                ;consistency check if type is integer or float
                If (Typ = "Integer")
                    If NewVal is not space
                        If NewVal is not Integer
                        {
                            GuiControl, , Edit1, %CurrVal%
                            Continue
                        }
                    If (Typ = "Float")
                        If NewVal is not space
                            If NewVal is not Integer
                                If (NewVal <> ".")
                                    If NewVal is not Float
                                    {
                                        GuiControl, , Edit1, %CurrVal%
                                        Continue
                                    }

                                ;set new value and save it to INI      
                                if (%CurrID%Val!=NewVal)
                                    bSettingsChanged:=true
                %CurrID%Val := NewVal 
                CurrVal := NewVal
                PrntID := TV_GetParent(CurrID)
                TV_GetText(SelSec, PrntID) 
                TV_GetText(SelKey, CurrID) 
                If (SelSec AND SelKey) 
                    IniWrite %NewVal%, %IniFile%, %SelSec%, %SelKey%
            } 
        } 
    } 

    ;Exit button got pressed 
    ExitSettings: 
    ;re-enable calling GUI 
    If DisableGui { 
        Gui %OwnedBy%:-Disabled
        Gui %OwnedBy%:,Show
    } 
    Gui Destroy
    ;exit function 
    Return bSettingsChanged ; inform the script if settings have been changed or not.

    ;browse button got pressed
    BtnBrowseKeyValue: 
    ;get current value
    GuiControlGet StartVal, , Edit1
    Gui +OwnDialogs

    ;Select file or folder depending on key type
    If (Typ = "File"){ 
        ;get StartFolder
        if (FileExist(A_ScriptDir "\" StartVal))
            StartFolder := A_ScriptDir 
        Else if (FileExist(StartVal))
            SplitPath StartVal, , StartFolder
        Else 
            StartFolder := ""

        ;select file
        FileSelectFile Selected,, %StartFolder%, Select file for %SelSec% - %SelKey%, Any file (*.*)
    }Else If (Typ = "Folder"){ 
        ;get StartFolder
        if (FileExist(A_ScriptDir "\" StartVal))
            StartFolder := A_ScriptDir "\" StartVal
        Else if (FileExist(StartVal))
            StartFolder := StartVal
        Else 
            StartFolder := ""

        ;select folder
        FileSelectFolder Selected, *%StartFolder% , 3, Select folder for %SelSec% - %SelKey%

        ;remove last backslash "\" if any
        StringRight LastChar, Selected, 1
        If (LastChar="\") 
            StringTrimRight Selected, Selected, 1
    } 
    ;If file or folder got selected, remove A_ScriptDir (since it's redundant) and set it into GUI
    If Selected { 
        Selected:=StrReplace(Selected,A_ScriptDir "\")
        GuiControl, , Edit1, %Selected%
        %CurrID%Val := Selected 
    } 
    Return  ;end of browse button subroutine

    ;default button got pressed
    BtnDefaultValue: 
    SetDefault := True 
    Return  ;end of default button subroutine

    ;gui got resized, adjust control sizes
    GuiIniSettingsEditorSize:
    GuiIniSettingsEditorAnchor("SysTreeView321"      , "wh") 
    GuiIniSettingsEditorAnchor("Edit1"               , "x")
    GuiIniSettingsEditorAnchor("Edit2"               , "xh")
    GuiIniSettingsEditorAnchor("Button1"             , "xy",true)
    GuiIniSettingsEditorAnchor("Button2"             , "x",true)
    GuiIniSettingsEditorAnchor("Button3"             , "xy",true)
    GuiIniSettingsEditorAnchor("Button4"             , "x",true)
    GuiIniSettingsEditorAnchor("Button5"             , "wh",true)
    GuiIniSettingsEditorAnchor("SysDateTimePick321"  , "x")
    GuiIniSettingsEditorAnchor("msctls_Hotkey321"    , "x")
    GuiIniSettingsEditorAnchor("ComboBox1"           , "x")
    GuiIniSettingsEditorAnchor("Static1"             , "x")
    GuiIniSettingsEditorAnchor("Static2"             , "x")
    GuiIniSettingsEditorAnchor("Static3"             , "x")
    GuiIniSettingsEditorAnchor("Static4"             , "x")
    Return 
}  ;end of function

GuiIniSettingsEditorAnchor(ctrl, a, draw = false) { ; v3.2 by Titan (shortened)
    static pos
    sig := "`n" ctrl "="
    If !InStr(pos, sig) {
        GuiControlGet p, pos, %ctrl%

        pos := pos . sig . pX - A_GuiWidth . "/" . pW  - A_GuiWidth . "/"

            . pY - A_GuiHeight . "/" . pH - A_GuiHeight . "/"
    }

    StringTrimLeft p, pos, InStr(pos, sig) - 1 + StrLen(sig)


    StringSplit p, p, /
    c := "xwyh"
    Loop, Parse, c
        If InStr(a, A_LoopField) {
            If A_Index < 3
                e := p%A_Index% + A_GuiWidth
            Else e := p%A_Index% + A_GuiHeight
            m := m A_LoopField e
        }
    If draw
        d := "Draw"
    GuiControl Move%d%, %ctrl%, %m%
}
