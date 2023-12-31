# Grünflächen-Configurator

A Windows-only script to easily create a configuration for the enclosed GFA_Evaluation.R script.

## Detailed documentation

A detailed documentation can be found [here](https://htmlpreview.github.io/?https://github.com/Gewerd-Strauss/GFA-Utilities/blob/docs/Manual.html).

## License

See accompanying license file.

## Parameter Quick-Reference

For further, and particularly usage-dependent information, see the tooltip informations on each parameter.
This section serves as a quick reference for modifying an existing config-file without necessarily opening the program, and assumes the user is informed about the basic functionality of the parameters they alter.
If unsure, it is recommended to modify config files via this script - although that is only possible on Windows.

### 1. Grouping

#### `Facet2D`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Facet2D` [Section:`Experiment`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `Facet2D: Do you want to facet the plot, f.e. over a treatment?`                                      |
| Elaboration | `Clarification: Facetting here refers to the segmentation of the plots along the Y-Axis, NOT along the X-Axis.\nFor segmenting along the X-Axis, refer to 'UniqueGroups' and 'GroupsOrderX'.`                                        |

#### `Facet2DVar`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Facet2DVar` [Section:`Experiment`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `Facet2DVar: Set the comma-separated list of facet-members to assing to the 'UniqueGroups'`                                      |
| Elaboration | `[Facet2D==TRUE]\nClarification: The entries you specified for 'UniqueGroups' must each match a single entry in this list as well`                                        |

#### `GroupsOrderX`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `GroupsOrderX` [Section:`Experiment`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `GroupsOrderX: Set the comma-separated order of groups in the plots along X-axis`                                      |
| Elaboration | `Order the Groups along the X-Axis. Groups are ordered left to right`                                        |

#### `GroupsOrderXFacetingDaily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `GroupsOrderXFacetingDaily` [Section:`Experiment`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `GroupsOrderXFacetingDaily: Set the comma-separated order of Facets in the daily-plots along X-Axis (only for facetting)`                                      |
| Elaboration | `[Facet2D==TRUE]\nOrder the Facets along the X-Axis. Facets are ordered left to right.\nDD`                                        |

#### `GroupsOrderY`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `GroupsOrderY` [Section:`Experiment`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `GroupsOrderY: Set the comma-separated order of groups in the plots along Y-Axis (only for facetting)`                                      |
| Elaboration | `[Facet2D==TRUE]\nOrder the Groups along the Y-Axis. Groups are ordered top to bottom.`                                        |

#### `Palette_Boxplot`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Palette_Boxplot` [Section:`Experiment`]   |
| Value       | `yellow,orange,orangered,red,darkred,black,white`                                       |
| Default     | `yellow,orange,orangered,red,darkred,black,white`                                     |
| Type        | `String`                                        |
| Options     | `w400/`                                 |
| Instruction | `Palette_Boxplot: Set the colors for the Summaryplot`                                      |
| Elaboration | `Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the overview plot`                                        |

#### `Palette_Boxplot2`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Palette_Boxplot2` [Section:`Experiment`]   |
| Value       | `white,yellow,orange,orangered,red,darkred,black`                                       |
| Default     | `white,yellow,orange,orangered,red,darkred,black`                                     |
| Type        | `String`                                        |
| Options     | `w400/`                                 |
| Instruction | `Palette_Boxplot2: Set the colors for the daily plots`                                      |
| Elaboration | `Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the daily plots`                                        |

#### `Palette_Lines`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Palette_Lines` [Section:`Experiment`]   |
| Value       | `yellow,orange,orangered,red,darkred,black,black`                                       |
| Default     | `yellow,orange,orangered,red,darkred,black,black`                                     |
| Type        | `String`                                        |
| Options     | `w400/`                                 |
| Instruction | `Palette_Lines: Set the colors for the Summaryplot`                                      |
| Elaboration | `Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the overview plot`                                        |

#### `Palette_Lines2`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Palette_Lines2` [Section:`Experiment`]   |
| Value       | `black,yellow,orange,orangered,red,darkred,black`                                       |
| Default     | `black,yellow,orange,orangered,red,darkred,black`                                     |
| Type        | `String`                                        |
| Options     | `w400/`                                 |
| Instruction | `Palette_Lines2: Set the colors for the daily plots`                                      |
| Elaboration | `Colors are assigned regardless of order of the plots, and always in the following order:\nLeft to right, Top to bottom\n\nThis set of colors is responsible for the daily plots`                                        |

#### `PotsPerGroup`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `PotsPerGroup` [Section:`Experiment`]   |
| Value       | `7`                                       |
| Default     | `7`                                     |
| Type        | `Integer`                                        |
| Options     | `number/`                                 |
| Instruction | `PotsPerGroup: Set the number of pots per group/combination`                                      |
| Elaboration | `[Facet2D==TRUE]\nHere, combination is a combination of a member of 'UniqueGroups' and a member of 'Facet2DVar'`                                        |

#### `RefGroup`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `RefGroup` [Section:`Experiment`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `RefGroup: Set the reference group for all statistical tests`                                      |
| Elaboration | `\n[Facet2D==FALSE]\nFor a normal plot, this must be a member of 'UniqueGroups'\n\n[Facet2D==TRUE]\nFor a facetted plot, this must be a combination of 1 member of 'Facet2DVar' and 'UniqueGroups', separated by a dot (.).\nThe order is always '[UniqueGroups_Member].[Facet2DVar_Member]'\nExample:\n'Ungestresst.Unbehandelt'`                                        |

#### `UniqueGroups`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `UniqueGroups` [Section:`Experiment`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `UniqueGroups: Set the comma-separated list of all unique group names, AS ORDERED IN THE DATA-FILES`                                      |
| Elaboration | `It is required to ensure that groups are located at the same indeces across all data files.\n\nIf you set 'Facet2D' to TRUE, this must have as many entries as 'Facet2DVar'`                                        |

### 2. GeneralConfiguration

#### `Debug`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Debug` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `Debug: Do you want to print debug information?`                                      |
| Elaboration |                                         |

#### `filename_date_format`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `filename_date_format` [Section:`Experiment`]   |
| Value       | `%Y-%m-%d`                                       |
| Default     | `%Y-%m-%d`                                     |
| Type        | `String`                                        |
| Options     | `%d.%m.%Y|%Y-%m-%d||`                                 |
| Instruction | `filename_date_format: Select the date format for saved files. Editing allowed`                                      |
| Elaboration | `Does not control the date format on the figure. For that, see option 'figure_date_format'.`                                        |

#### `Filename_Prefix`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Filename_Prefix` [Section:`Experiment`]   |
| Value       | `GF`                                       |
| Default     | `GF`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `Filename_Prefix:`                                      |
| Elaboration | `Decide the file-prefix used when saving figures and statistical results.\n\nATTENTION:\nChanging this if files have been generated before will result in those files not\nbeing overwritten so you will end up with an old and a current set of result-\nfiles (images/excel-sheets/RData-files)`                                        |

#### `language`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `language` [Section:`General`]   |
| Value       | `English`                                       |
| Default     | `English`                                     |
| Type        | `String`                                        |
| Options     | `English||German`                                 |
| Instruction | `language: Select language for auto-generated labels`                                      |
| Elaboration |                                         |

#### `Normalise`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Normalise` [Section:`Experiment`]   |
| Value       | `TRUE`                                       |
| Default     | `1`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `Normalise: Do you want to normalise your leaf area?`                                      |
| Elaboration | `This accesses the data-column 'plant_area_normalised'. For more info, check the documentation.`                                        |

#### `T0`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `T0` [Section:`Experiment`]   |
| Value       | `20231220073557`                                       |
| Default     | `20231220073557`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `T0: Set the T0-date for calculating 'plant-age' for your experiment, in format dd.MM.yyyy (24.12.2023)`                                      |
| Elaboration | `This is relevant mostly for calculating the plant-age plotted on the y-axis.`                                        |

#### `used_filesuffix`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `used_filesuffix` [Section:`General`]   |
| Value       | `xlsx`                                       |
| Default     | `xlsx`                                     |
| Type        | `String`                                        |
| Options     | `xlsx||csv`                                 |
| Instruction | `used_filesuffix: Select the filetype you want to ingest`                                      |
| Elaboration | `'xlsx' is recommended. 'csv' was tested, but not as adamantly as xlsx. It should not make any difference, but that is not guaranteed.`                                        |

#### `used_plant_area`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `used_plant_area` [Section:`Experiment`]   |
| Value       | `plant_area`                                       |
| Default     | `plant_area`                                     |
| Type        | `String`                                        |
| Options     | `plant_area||plant_area_green|plant_area_complete|plant_area_drought`                                 |
| Instruction | `used_plant_area: Select the name of the column which contains the area you are trying to plot. Editing allowed`                                      |
| Elaboration | `Examples:\n- 'plant_area'\n- 'plant_area_green'\n- 'plant_area_complete'\n- 'plant_area_drought'.`                                        |

### 3. Figure

#### `Name`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Name` [Section:`Experiment`]   |
| Value       | `Experiment X`                                       |
| Default     | `Experiment X`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `Name: Set the name of the Experiment as seen in the figure title`                                      |
| Elaboration |                                         |

#### `PlotMeanLine`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `PlotMeanLine` [Section:`General`]   |
| Value       | `TRUE`                                       |
| Default     | `1`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `PlotMeanLine: Do you want to plot the line connecting the means of each group's boxplots?`                                      |
| Elaboration |                                         |

#### `Theme`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Theme` [Section:`General`]   |
| Value       | `7`                                       |
| Default     | `7`                                     |
| Type        | `Integer`                                        |
| Options     | `Number`                                 |
| Instruction | `Theme: Choose your default theme.`                                      |
| Elaboration |                                         |

### 4. Axes

#### `axis_units_x`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `axis_units_x` [Section:`General`]   |
| Value       | `Tage,days`                                       |
| Default     | `Tage,days`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `axis_units_x: Set the unit of the X-axis (for the Overview-plot).`                                      |
| Elaboration | `Format: '[German Text],[English Text]'. Replace a field with "/" to skip it`                                        |

#### `axis_units_x_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `axis_units_x_Daily` [Section:`General`]   |
| Value       | `/,/`                                       |
| Default     | `/,/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `axis_units_x_Daily: Set the unit of the X-axis (for the daily plots).`                                      |
| Elaboration | `Format: '[German Text],[English Text]'. Replace a field with "/" to skip it`                                        |

#### `axis_units_y`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `axis_units_y` [Section:`General`]   |
| Value       | `cm^2,cm^2`                                       |
| Default     | `cm^2,cm^2`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `axis_units_y: Set the unit of the Y-axis (for the Overview-plot).`                                      |
| Elaboration | `Format: '[German Text],[English Text]'. Replace a field with "/" to skip it`                                        |

#### `axis_units_y_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `axis_units_y_Daily` [Section:`General`]   |
| Value       | `cm^2,cm^2`                                       |
| Default     | `cm^2,cm^2`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `axis_units_y_Daily: Set the unit of the Y-axis (for the daily plots).`                                      |
| Elaboration | `Format: '[German Text],[English Text]'. Replace a field with "/" to skip it`                                        |

#### `BreakStepSize`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `BreakStepSize` [Section:`Experiment`]   |
| Value       | `25`                                       |
| Default     | `25`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `BreakStepSize: Set the spacing between numbered breaks on the Y-Axis. Requires ForceAxes=T`                                      |
| Elaboration |                                         |

#### `figure_date_format`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `figure_date_format` [Section:`Experiment`]   |
| Value       | `%d.%m.%Y`                                       |
| Default     | `%d.%m.%Y`                                     |
| Type        | `String`                                        |
| Options     | `%d.%m.%Y||%Y-%m-%d`                                 |
| Instruction | `figure_date_format: Select the date format for dates on the x-axis or in titles. Editing allowed`                                      |
| Elaboration | `[RelativeColNames==TRUE]\nDoes not take effect\n\n\n[RelativeColNames==FALSE]\nSet the format for dates on the x-axis\n\nDoes not control the date format for the saved files. For that, see option 'filename_date_format'.`                                        |

#### `ForceAxes`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ForceAxes` [Section:`Experiment`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ForceAxes: Do you want to force the Y-Axis scaling? This requires setting 'YLimits'`                                      |
| Elaboration |                                         |

#### `RelativeColnames`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `RelativeColnames` [Section:`General`]   |
| Value       | `TRUE`                                       |
| Default     | `1`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `RelativeColnames: Do you want to display the X-positions as 'days since T0'?`                                      |
| Elaboration |                                         |

#### `ShowBothColnames`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowBothColnames` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowBothColnames: Do you want to display the X-positions as 'days since T0 - date'?`                                      |
| Elaboration |                                         |

#### `XLabel`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `XLabel` [Section:`Experiment`]   |
| Value       | `Time since repotting`                                       |
| Default     | `Time since repotting`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `XLabel: Set the xlabel-string for the summary plot.`                                      |
| Elaboration |                                         |

#### `XLabel_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `XLabel_Daily` [Section:`Experiment`]   |
| Value       | `Treatment Groups`                                       |
| Default     | `Treatment Groups`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `XLabel_Daily: Set the xlabel-string for the daily analyses.`                                      |
| Elaboration |                                         |

#### `YLabel`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `YLabel` [Section:`Experiment`]   |
| Value       | `green plant area`                                       |
| Default     | `green plant area`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `YLabel: Set the ylabel-string for the summary plot and daily analyses.`                                      |
| Elaboration |                                         |

#### `YLimits`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `YLimits` [Section:`Experiment`]   |
| Value       | `0,150`                                       |
| Default     | `0,150`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `YLimits: Set the minimum and maximum limit for the Y-Axis. Does not take effect if 'ForceAxes' is false. Used for all plots`                                      |
| Elaboration |                                         |

### 5. Statistics and its displaying

#### `PlotSampleSize`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `PlotSampleSize` [Section:`General`]   |
| Value       | `TRUE`                                       |
| Default     | `1`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `PlotSampleSize: Do you want to plot the sample size of each group's boxplots?`                                      |
| Elaboration |                                         |

#### `ShowNAtallboxplots`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowNAtallboxplots` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowNAtallboxplots: Do you want to print 'n=XX' above every boxplot in the daily plots?`                                      |
| Elaboration | `[ShowNAtallboxplot==TRUE]:\nThe Sample size is printed above every day.\nThis is generally not recommended as it will become cluttered with increasing number of days.\n\n[ShowNAtallboxplot==FALSE]\nDo not print sample sizes above every day. Sample size is displayed via the plot_subtitle element instead (but only if you enable rr)`                                        |

#### `ShowOnlyIrregularN`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowOnlyIrregularN` [Section:`General`]   |
| Value       | `TRUE`                                       |
| Default     | `1`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowOnlyIrregularN: Do you want to only plot sample sizes which differ from 'PotsPerGroup'?`                                      |
| Elaboration | `Requires also ticking 'PlotSampleSize'`                                        |

### 6. Fontsizes

#### `Fontsize_General`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_General` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_General: Set the general fontsize text elements on all plots.`                                      |
| Elaboration | `Default is 10.0. Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_LegendText`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_LegendText` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_LegendText: Set the fontsize for the legend entries`                                      |
| Elaboration | `That is, the group names in the legend itself.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_LegendTitle`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_LegendTitle` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_LegendTitle: Set the fontsize for the legend title`                                      |
| Elaboration | `That is, the 'title' of the legend.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_PValue`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_PValue` [Section:`Fontsizes`]   |
| Value       | `2.500000`                                       |
| Default     | `2.5`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_PValue: Set the fontsize for the p-values in the daily plots`                                      |
| Elaboration | `Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_SampleSize`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_SampleSize` [Section:`Fontsizes`]   |
| Value       | `2.500000`                                       |
| Default     | `2.5`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_SampleSize: Set the fontsize for the sample size in the daily plots`                                      |
| Elaboration | `Note that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_XAxisLabel`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_XAxisLabel` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_XAxisLabel: Set the fontsize for the axis names/titles`                                      |
| Elaboration | `That is, the dates/plant ages.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_XAxisTicks`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_XAxisTicks` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_XAxisTicks: Set the fontsize for the axis ticks`                                      |
| Elaboration | `That is, the numerical/date-scaling on the x-axis.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_YAxisLabel`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_YAxisLabel` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_YAxisLabel: Set the fontsize for the axis names/titles`                                      |
| Elaboration | `That is, plant area values, '25','50','75',...\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

#### `Fontsize_YAxisTicks`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Fontsize_YAxisTicks` [Section:`Fontsizes`]   |
| Value       | `10.000000`                                       |
| Default     | `10.0`                                     |
| Type        | `number`                                        |
| Options     | `/`                                 |
| Instruction | `Fontsize_YAxisTicks: Set the fontsize for the axis ticks`                                      |
| Elaboration | `That is, the numerical scaling on the y-axis.\n\nNote that the zeros can be omitted in principle, but are a side-effect of the validation used. You can ignore them.`                                        |

### 7. Titles

#### `DebugText`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `DebugText` [Section:`General`]   |
| Value       | `"Setting [DEBUG==TRUE]" in section '2. General Configuration' will overwrite any settings made in this section"`                                       |
| Default     | `"Setting [DEBUG==TRUE]" in section '2. General Configuration' will overwrite any settings made in this section"`                                     |
| Type        | `text`                                        |
| Options     | `/`                                 |
| Instruction | `Setting [DEBUG==TRUE] in section '2. General Configuration' will overwrite any settings made in this section`                                      |
| Elaboration |                                         |

#### `ShowTitle`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowTitle` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowTitle: Do you want to show the title above the summary plot?`                                      |
| Elaboration |                                         |

#### `ShowTitle_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowTitle_Daily` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowTitle_Daily: Do you want to show the title above the daily plots?`                                      |
| Elaboration |                                         |

#### `ShowTitleDateWhere`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowTitleDateWhere` [Section:`General`]   |
| Value       | `SubTitle`                                       |
| Default     | `SubTitle`                                     |
| Type        | `String`                                        |
| Options     | `Title|SubTitle||nowhere`                                 |
| Instruction | `ShowTitleDateWhere: Select if the date (range) should be appended to the end of the title- or subtitle-element.`                                      |
| Elaboration | `For date-format, see key 'figure_date_format' under section '4. Axes'\n\n[ShowTitle==FALSE]\nNo effect.`                                        |

#### `ShowTitleSub`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowTitleSub` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowTitleSub: Do you want to show the sub-title above the summary plot?`                                      |
| Elaboration |                                         |

#### `ShowTitleSub_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `ShowTitleSub_Daily` [Section:`General`]   |
| Value       | `FALSE`                                       |
| Default     | `0`                                     |
| Type        | `boolean`                                        |
| Options     | `TRUE/FALSE`                                 |
| Instruction | `ShowTitleSub_Daily: Do you want to show the sub-title above the daily plots?`                                      |
| Elaboration |                                         |

#### `Title`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Title` [Section:`General`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `Title: Enter the title you want to use for the summary plot. Leave empty to use the default title.`                                      |
| Elaboration | `Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.`                                        |

#### `Title_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `Title_Daily` [Section:`General`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `Title_Daily: Enter the title you want to use for the daily plots. Leave empty to use the default title.`                                      |
| Elaboration | `Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.`                                        |

#### `TitleSub`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `TitleSub` [Section:`General`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `TitleSub: Enter the sub-title you want to use for the summary plot. Leave empty to use the default sub-title.`                                      |
| Elaboration | `Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhere'.`                                        |

#### `TitleSub_Daily`

|             |                                                                     |
| ----------- | ------------------------------------------------------------------- |
| Parameter   | `TitleSub_Daily` [Section:`General`]   |
| Value       | `/`                                       |
| Default     | `/`                                     |
| Type        | `String`                                        |
| Options     | `/`                                 |
| Instruction | `TitleSub_Daily: Enter the sub-title you want to use for the daily plots. Leave empty to use the default sub-title.`                                      |
| Elaboration | `Note that the respective days' date is appended to either the title or subtitle, depending on what you choose under 'ShowTitleDateWhereA'.`                                        |
