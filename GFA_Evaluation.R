# Nach Vorlage von 'Grünfläche_Verlauf.R' und 'Grünflächenanalyse_v3.R'
# abgewandelt zur Anwendung im Rahmen des Versuches 2 meines Praktikums
# 
# 
# 
# ~CA
#
#
#
#sink("output.txt",T)
# clear environment variables
#cat("\014")  ## clear console
#remove (list=ls())  ## clear environment variables
#------ LIBARIES
#------ SETUP

# This is the startup path used to initialise the folder-search, and the only thing that needs to be edited in-script at the end. the entire rest is depending on the data-folder's ini-file
# Development
#cat("\014") ## clear console
#remove (list=ls()) ## clear environment variables
#cat("\014") ## clear console
#remove (list=ls()) ## clear environment variables   


#todo: setting to fixate axes

#folder_path <- choose.dir(folder_path,"Choose Foleder")
#----- FUNCTIONS
#
#

assignDaysToVariables <- function(Files,List,ini) {
    return(List <- setColnames(Files,List,ini))
}
calculateColnames  <-  function(Files,List,ini,bGetDiff=FALSE,bForceActualDates=FALSE) {
    
    TimeSinceT0 <- list() # Initiate a list
    Ind <- 1
    strLen_max <- 0
    for (file in Files){
        Date <- str_extract(file,"\\d+\\.\\d+\\.\\d+")
        Date <- as.Date.character(Date,format = "%d.%m.%Y")
        Conditions <- {}
        Conditions$UseRelativeColnames <- as.logical(ini$General$RelativeColnames)
        if ((isFALSE(as.logical(ini$General$RelativeColnames)) & isFALSE(bGetDiff)) | bForceActualDates) { # print full dates
            TimeSinceT0[Ind] <- as.character.Date(Date,"%d.%m.%Y")
            #todo: figure out how to format them as date instead of character ._.
            Ind <- Ind+1
            next
        } else {                                                          # print relative date-spans
            DateDiff <- Date - as.Date.character(ini$Experiment$T0,format = "%d.%m.%Y")
            TimeSinceT0[Ind] <- as.numeric(DateDiff)
            if (str_length(as.numeric(DateDiff))>strLen_max) {
                strLen_max <- as.integer(str_length(as.numeric(DateDiff)))
            }
            Ind <- Ind+1
            IndA <- 1
        }
    }
    if (bForceActualDates) {
        return(TimeSinceT0)
    }
    if (as.logical(ini$General$RelativeColnames)) {
        for (file in Files) {
            TimeSinceT0[[IndA]] <- as.character(padAgeNumber(TimeSinceT0[[IndA]],strLen_max))
            IndA <- IndA+1
            
        }
    }
    IndB <- 1
    if (isFALSE(as.logical(ini$General$RelativeColnames)) & bGetDiff) {
        for (file in Files) {
            TimeSinceT0[[IndB]] <- as.character(padAgeNumber(TimeSinceT0[[IndB]],strLen_max))
            IndB <- IndB+1
            
        }
    }
    return(TimeSinceT0)
}
calculateChange <- function(DailyAnalyses,ChosenDays) {
    dayID <- 1
    ChosenDays <- str_trim(ChosenDays)
    SortedFormattedDates <- as.character.Date(sort(as.Date.character(unlist(str_trim(ChosenDays)),format = "%d.%m.%Y")),format = "%d.%m.%Y")
    print("Changes in Leaf-Area relative to the previous day: ")
    for (curr_day in SortedFormattedDates) {
        if (dayID==1) {
            ld <- curr_day
            dayID <- dayID + 1
            lastVals <- DailyAnalyses[[str_trim(curr_day)]]
            lastmean <- lastVals$Res$summary$mean
            name <- lastVals$Res$summary$name
            print(str_c(curr_day, " -> ",curr_day,str_pad("/",width = max(str_length(name))+1,side = "left"), "    Mean: ",str_pad("/",width = 13,side = "left")," -> ",str_pad("/",side = "left",width = 12),str_pad("  [cm^2]",width = 13,side = "left"),"    |absC: ", str_pad("/",side = "left",width = 16), " [cm^2]","    |relC: ", str_pad("/",side = "left",width = 16), " [%]"))
            next
        } else {
            lastVals <- DailyAnalyses[[str_trim(ld)]]
            lastmean <- lastVals$Res$summary$mean
            thisVals <- DailyAnalyses[[str_trim(curr_day)]]
            thismean <- thisVals$Res$summary$mean
            absolute_change <- (thismean-lastmean)
            relative_change <- absolute_change/abs(lastmean)*100
            name <- lastVals$Res$summary$name
            console_print <- str_c(ld, " -> ",curr_day,str_pad(name,width = max(str_length(name))+1), "    Mean: ",str_pad(signif(lastmean,digits = 12),width = 12,side = "right")," -> ",str_pad(signif(thismean,digits = 11),side = "left",width = 12),str_pad(" [cm^2]",width = 13,side="left"),"    |absC: ", absolute_change, " [cm^2]","    |relC: ", relative_change, " [%]")
            print(console_print)
            print(str_pad("-",width = max(str_length(console_print)),pad = "-"))
            #print(str_c(ld, " -> ",curr_day,str_pad(name,width = max(str_length(name))+1), "    Mean: ",str_pad(signif(lastmean,digits = 12),width = 13,side = "right")," -> ",str_pad(signif(thismean,digits = 11),side = "right",width = 13)," [cm^2]    |absC: ", absohttp://127.0.0.1:18555/graphics/ecd75976-e096-42d0-9013-c79382ece4db.pnglute_change, " [cm^2]","    |relC: ", relative_change, " [%]"))
            CurrSum <- DailyAnalyses[[str_trim(curr_day)]]$Res$summary
            CurrSum$relative_change <- relative_change
            CurrSum$absolute_change <- absolute_change
            DailyAnalyses[[str_trim(curr_day)]]$Res$summary <- CurrSum #todo: figure out how to do this right!!
            ld <- curr_day
        }
    }
    return(DailyAnalyses)
}
getRelative_change <- function(this,last,Object=FALSE) {
    # Funktion berechnet die relative Veränderung zwischen zwei Werten.
    
    # Fall 1: Parameter 'this' und 'last' sind numerisch: der relative Unterschied dieser beiden Werte wird zurückgegeben
    # Fall 2: Parameter 'this' und 'last' sind Datenangaben im Format "%d.%m.%Y": der relative Unterschied von allen Versuchsgliedern zu den beiden gegebenen Zeitpunkten wird zurückgegeben
    if (isFALSE(Object)) { # compare values
        if (is.numeric(this) && is.numeric(last))  {
            #a <- as.character(thisVals$Res$summary$name)
            relative_change <- (this-last)/abs(last)*100
            b <- as.character(last)
            c <- as.character(relative_change)
            d <- as.character(this)
            
            names <- c("Last mean","rel. Change [%]", "this mean")
            table <- dplyr::tibble(b,c,d)
            table <- as.data.frame(table)
            colnames(table) <- names
            kable <- knitr::kable(table)
            print(kable)
            return(relative_change)
        } else {
            # error?
        }
    } else { # compare values of a dailyAnalyses-Object
        thisVals <- Object[[str_trim(this)]]
        lastVals <- Object[[str_trim(last)]]
        if (is.null(lastVals)) {
            lastmean <- last
        } else {
            lastmean <- lastVals$Res$summary$mean
        }
        if (is.null(thisVals)) {
            thismean <- this
        } else {
            thismean <- thisVals$Res$summary$mean
        }
        relative_change <- (thismean-lastmean)/abs(lastmean)*100
    }
    a <- as.character(thisVals$Res$summary$name)
    b <- as.character(lastmean)
    c <- as.character(relative_change)
    d <- as.character(thismean)
    names <- c("Groups","Last mean","rel. Change [%]", "this mean")
    table <- dplyr::tibble(a,b,c,d)
    table <- as.data.frame(table)
    colnames(table) <- names
    kable <- knitr::kable(table)
    print(kable)
    return(relative_change)
}
getAbsolute_change <- function(this,last,Object=FALSE) {
    # Funktion berechnet die absolute Veränderung zwischen zwei Werten.
    
    # Fall 1: Parameter 'this' und 'last' sind numerisch: der absolute  Unterschied dieser beiden Werte wird zurückgegeben
    # Fall 2: Parameter 'this' und 'last' sind Datenangaben im Format "%d.%m.%Y": der relative Unterschied von allen Versuchsgliedern zu den beiden gegebenen Zeitpunkten wird zurückgegeben
    if (isFALSE(Object)) { # compare values
        if (is.numeric(this) && is.numeric(last))  {
            return((this-last))
        }
    } else { # compare values of a dailyAnalyses-Object
        thisVals <- Object[[str_trim(this)]]
        lastVals <- Object[[str_trim(last)]]
        if (is.null(lastVals)) {
            lastmean <- last
        } else {
            lastmean <- lastVals$Res$summary$mean
        }
        if (is.null(thisVals)) {
            thismean <- this
        } else {
            thismean <- thisVals$Res$summary$mean
        }
        absolute_change <- (thismean-lastmean)
    }
    a <- as.character(thisVals$Res$summary$name)
    b <- as.character(lastmean)
    c <- as.character(absolute_change)
    d <- as.character(thismean)
    names <- c("Groups","Last mean","abs. Change", "this mean")
    table <- dplyr::tibble(a,b,c,d)
    table <- as.data.frame(table)
    colnames(table) <- names
    kable <- knitr::kable(table)
    print(kable)
    return(absolute_change)
}
getMeanofVectorElements <- function(Vector, Elements) {
    lenVector <- length(Vector)
    map <- rep(0,lenVector)
    map <- replace(map,Elements,1)
    map <- as.logical(map)
    selection <- subset(Vector,map)
    return(mean(selection))
}
checkExistence <-function(Path=""){
    if (isFALSE(file.exists(Path))) {
        return(FALSE)
    } else {
        return(TRUE)
    }
    
}
createFactors <- function(List,Groups) {
    # Diese Function formatiert die Spalte List$Group zum datentyp "Faktor" um. Notwendig um die Daten im GGPLot anhand der Gruppe zu unterteilen.
    List$Group <- factor(List$Group,levels=Groups)
    #List$Group <- factor(List$Group,levels=Da)
    # Listas.factor()
    return(List)
}
csv2xlsx <- function(path) {
    df <- read.csv(path,sep = ";",header = T)
    filename <- tools::file_path_sans_ext(path)
    openxlsx::write.xlsx(df,file = stringr::str_c(filename,".xlsx"),
                         colNames=T,
                         sheetName="1",asTable = T)
    return(stringr::str_c(filename,".xlsx"))
}
forcePLANT_AREAtoNumeric <- function(List,ini) {
    #List[,3:8] <- sapply(List[,3:8], as.numeric)
    if (isTRUE(as.logical(ini$Experiment$Facet2D))) {
        List[,4:(length(List)-0)] <- sapply(List[,4:(length(List)-0)], as.numeric)
    } else {
        e <- List[,3:(length(List)-0)]
        e <- stringr::str_trim(e)
        List[,3:(length(List)-0)] <- sapply(List[,3:(length(List)-0)], as.numeric)
    }
    return(List)
}
formatPValue = function(x) {
    if_else(
        is.na(x), 
        NA_character_,
        if_else(x < 0.001, format(x, digits = 3, scientific = TRUE), format(round(x, 3), scientific = F))
    )
}
getFilesInFolder <- function(folder,filesuffix="csv",out_prefix="GFResults_",recursive=TRUE){
    if (substring(filesuffix,1,1)==".")
        filesuffix=substring(filesuffix,2)
    else {
        if (isFALSE(exists("Conditions$IsIncluded",where = -1))) {
            #print("filesuffix provided is correct")
        }
    }
    fileQuery <- paste0(folder,".+.",filesuffix) 
    pattern_old <- paste0(".*\\",filesuffix,"$") ## used when all Files are in the same folder
    #pattern <- paste0("\\.*\\.*",filesuffix,"$")
    pattern <- paste0(".",filesuffix,"$") ## used when all Files are in the same folder
    Files <- list.files(
        path = folder,
        pattern=pattern,
        full.names=TRUE,
        recursive = TRUE)
    if (isFALSE(exists("Conditions$IsIncluded",where = -1))) {
        print(paste0("Selected Folder: ",folder))
        print(paste0("Selected File Suffix: ",filesuffix))
        print(paste0("Selected File Prefix: ",out_prefix))
    }
    otp <- out_prefix
    lapply(Files,checkExistence)
    Files <- RemoveOutputFiles(as.list(Files),out_prefix)
    return(Files)
}
getLastNElementsOfPalette <- function(palette,n) {
    pal <- brewer.pal(n = 99,palette)  # load the palette
    Max <- length(pal) # get the number of entries
    logical <- rep(TRUE,Max) # create a logical vector
    logical[Max-n:Max] <- FALSE # populate the last values with 
    return(pal[logical])
}
importCSV_Data1 <- function(Files,List,ini) {
    for (file in Files) {
        if (ini$General$used_filesuffix=="csv") {
            csv1 <- read.csv(file,sep=";")
            csv1$plant_area <- str_replace(csv1$plant_area,",",".")
            csv1$plant_area <- as.numeric(csv1$plant_area)
            if (hasName(csv1,"plant_area_drought")) {
                csv1$plant_area_drought <- str_replace(csv1$plant_area_drought,",",".")
                csv1$plant_area_drought <- as.numeric(csv1$plant_area_drought)
            }
            if (hasName(csv1,"plant_area_green")) {
                csv1$plant_area_green <- str_replace(csv1$plant_area_green,",",".")
                csv1$plant_area_green <- as.numeric(csv1$plant_area_green)
            }
            if (hasName(csv1,"plant_area_complete")){
                csv1$plant_area_complete <- str_replace(csv1$plant_area_complete,",",".")
                csv1$plant_area_complete <- as.numeric(csv1$plant_area_complete)
            }
            if (hasName(csv1,"pixel_area")){
                csv1$pixel_area <- str_replace(csv1$pixel_area,",",".")
                csv1$pixel_area <- as.numeric(csv1$pixel_area)
            }
            if (hasName(csv1,"plant_pixel_count")) {
                csv1$plant_pixel_count <- str_replace(csv1$plant_pixel_count,",",".")
                csv1$plant_pixel_count <- as.numeric(csv1$plant_pixel_count)
            }
            csv <- csv1
            #file <- csv2xlsx(file)
            #csv <- read_xlsx(file)
            #view(csv1)
            #view(csv)
        } else if (ini$General$used_filesuffix=="xlsx") {
            csv <- read_xlsx(file)
        }
        if (ini$Experiment$Normalise) {  
            if (hasName(csv,"plant_area_normalised")) {
                csv$plant_area_normalised <- csv$plant_area_normalised
            }
            else {
                if (hasName(csv,"plants_in_pot")) {
                    csv$plant_area_normalised <- csv$plant_area/csv$plants_in_pot
                } else {
                    print(str_c("importCSV_Data1: ","Error occured: While intending to usea normalised plant_area-vector, the script was unable to find a table column named 'plant_area_normalised', nor was it able to normalise on its own because you did not provide the then-required vector 'plants_in_pot'. The script will exit prematurely. Please provide either of the two vectors mentioned above and restart the script."))
                }
            }
            List <- cbind(List,csv$plant_area_normalised);
        } else {
            if (hasName(csv,"plant_area")) {
                List <- cbind(List,csv$plant_area);
            } else {
                List <- cbind(List,csv$plant_area_complete);
            }
        }
    }
    return(List)
}
is.dmy <- function(x) {
    ret <- !is.na(lubridate::dmy(x,quiet = TRUE))
    return(ret) 
}
isNormallyDistributed <- function(norm_obj,Threshold=0.05) {
    # Function überprüft, wie viele der Gruppen den Test zur Normalverteilung bestehen. Wenn alle ihn bestehen, gibt sie als boolean TRUE zurück
    boolean <- ""
    Count <- dim(norm_obj)[1]
    ThresholdPassing <- subset(norm_obj,subset = statistic>Threshold) # Get the entries which fulfill the Threshold.
    Count_Threshold <- dim(ThresholdPassing)[1]
    boolean <- (Count==Count_Threshold) #Evaluate threshold comparison
    return(boolean)
}
labelSample_n <- function(x){
    Value <- length(x)
    Threshold <- as.integer(PotsPerGroup)
    bLabeledOnlynonmaxed <<- F
    df <- data.frame(y = 0
                     ,label = paste0("n=",length(x)))
    if (isFALSE(as.logical(ini$General$ShowNatallboxplots))) {
        if(Value<Threshold) {
            bLabeledOnlynonmaxed <<- T
            df <- data.frame(y = 0
                             ,label = paste0("n=",length(x)))
            
        }
    }
    return(df)
}
padAgeNumber <- function(Value,Length) {
    retVal <- str_pad(Value,width = Length,pad=as.character(0))
    return(retVal)
}
setColnames <- function(Files,List,ini) {
    DateDifference_Integers <- calculateColnames(Files,List,ini)
    if (isTRUE(as.logical(ini$General$RelativeColnames))) {
        if (isTRUE(as.logical(ini$Experiment$Facet2D))) {
            colnames(List)[c(4:(4+length(DateDifference_Integers)-1))] <- as.integer(DateDifference_Integers)
        } else {
            colnames(List)[c(3:(3+length(DateDifference_Integers)-1))] <- as.integer(DateDifference_Integers)
        }
    } else {
        DateDifference_Integers <- calculateColnames(Files,List,ini)
        CharacterString <- as.character(unlist(DateDifference_Integers))
        factoredDates <- as.factor(CharacterString)
        updated <- as.Date(CharacterString,format = "%d.%m.%Y")
        updated <- as.list.Date(updated,format = "%d.%m.%Y")
        #vect <- unlist(strsplit(DateDifference_Integers," "))
        #colnames(List)[c(3:(3+length(DateDifference_Integers)-1))] <- updated
        if (isTRUE(as.logical(ini$Experiment$Facet2D))) {
            colnames(List)[c(4:(4+length(DateDifference_Integers)-1))] <- unlist(as.character(factoredDates,format="%d.%m.%Y"))
            order <- c(c(1,2,3),unlist(order(as.Date(CharacterString,format="%d.%m.%Y"))+3))
        } else {
            order <- c(c(1,2),unlist(order(as.Date(CharacterString,format="%d.%m.%Y"))+2))
            colnames(List)[c(3:(3+length(DateDifference_Integers)-1))] <- unlist(as.character(factoredDates,format="%d.%m.%Y"))
        }
        #colnames(List)[c(3:(3+length(DateDifference_Integers)-1))] <- as.Date(vect,format="%d.%m.%Y")
        List <- List[order]
    }
    return(List)
}
validateINI <- function(ini_List) {
    #toValidate:
    #Experiment               
    # T0                    Must be validated
    # PotsPerGroup          can't be validated, must be given in good faith
    # UniqueGroups          can't be validated, must be given in good faith
    # Normalise            falls back if not prepared TODO: give notice if falllback to plant_area/plant_number, so that user knows they must provide the column or not use the number
    #General                  
    # Debug                 not applicable, the debug switch is used to generate more detailed information on what is going on
    # Theme                 falls back to 
    # language              
    # used_filesuffix       
    # axis_units_x          
    # axis_units_y          
    
    
    #T0
    ret <- FALSE
    bIsDateValid <- is.dmy(ini_List$Experiment$T0)
    if (isFALSE(bIsDateValid)) {
        ret <- "'Date' in 'configfile'->'Experiment'->'T0' is not valid"
    }
    
    return(ret)
}
getMaximumDateRange  <- function(Colnames) {
    CharacterString <- as.character(unlist(Colnames))
    updated <- as.Date(CharacterString,format = "%d.%m.%Y")
    min <- min(updated)
    min <- format(min,"%d.%m.%Y")
    max <- max(updated)
    max <- format(max,"%d.%m.%Y")
    return(list(min,max))
}
RemoveOutputFiles <- function(Files="",Output_prefix="") {
    Files_out <- Files[!stringr::str_detect(Files,pattern=Output_prefix)]
    return(Files_out)
}
RunDetailed <- function(ChosenDays,Files,PotsPerGroup,numberofGroups,grps,folder_path,Conditions,ini,data_all_dailies,saveFigures=FALSE,saveExcel=FALSE,saveRDATA=FALSE) {
    ret <- list()
    retOutliers <- list()
    #1 Summary for mean, std, etc..
    #data_detailed <- cbind(Group,Number)
    #data_detailed <- importCSV_Data1(Files,data_detailed)
    #data_detailed <- as.data.frame(data_detailed)
    #data_all_CA <- assignDaysToVariables(Files,data_all_CA)
    #data_orig_CA <- data_all_CA
    #data_all_CA <- createFactors(data_all_CA,grps,PotsPerGroup)
    
    RObj=list()
    #1. Load Data
    Day_Index <- 0
    for (curr_Day in ChosenDays) {
        for (curr_file in Files) {
            if (isFALSE(as.logical(str_count(curr_file,str_trim(curr_Day))))) {
                next
            }
            
            #Data <- as.data.frame(importCSV_Data1(curr_file,""))
            if (ini$General$used_filesuffix=="csv") {
                csv1 <- read.csv(curr_file,sep=";")
                csv1$plant_area <- str_replace(csv1$plant_area,",",".")
                csv1$plant_area <- as.numeric(csv1$plant_area)
                if (hasName(csv1,"plant_area_drought")) {
                    csv1$plant_area_drought <- str_replace(csv1$plant_area_drought,",",".")
                    csv1$plant_area_drought <- as.numeric(csv1$plant_area_drought)
                }
                if (hasName(csv1,"plant_area_green")) {
                    csv1$plant_area_green <- str_replace(csv1$plant_area_green,",",".")
                    csv1$plant_area_green <- as.numeric(csv1$plant_area_green)
                }
                if (hasName(csv1,"plant_area_complete")){
                    csv1$plant_area_complete <- str_replace(csv1$plant_area_complete,",",".")
                    csv1$plant_area_complete <- as.numeric(csv1$plant_area_complete)
                }
                if (hasName(csv1,"pixel_area")){
                    csv1$pixel_area <- str_replace(csv1$pixel_area,",",".")
                    csv1$pixel_area <- as.numeric(csv1$pixel_area)
                }
                if (hasName(csv1,"plant_pixel_count")) {
                    csv1$plant_pixel_count <- str_replace(csv1$plant_pixel_count,",",".")
                    csv1$plant_pixel_count <- as.numeric(csv1$plant_pixel_count)
                }
                Data <- csv1
                #file <- csv2xlsx(file)
                #csv <- read_xlsx(file)
                #view(csv1)
                #view(csv)
            } else {
                Data <- read_xlsx(curr_file)
            }
            if (ini$Experiment$Normalise) {
                if (hasName(Data,"plant_area_normalised")) {
                    Data$plant_area_normalised <- Data$plant_area_normalised
                } else {
                    if (hasName(Data,"plants_in_pot")) {
                        Data$plant_area_normalised <- Data$plant_area/Data$plants_in_pot
                    }
                }
                Data$plant_area_nonnormalised <- Data$plant_area
                Data$plant_area <- Data$plant_area_normalised #TODO: Verify that this is correct. Also find out where the normal          #ised area is loaded for the develoment-plot so I can use that logic here instead. 
            } else {
                #List <- cbind(1:length(Data$plant_area),Data$plant_area)
            }
            break
        }
        Day_Index <- Day_Index + 1
        Nummer <- rep(c(1:PotsPerGroup),times=numberofGroups)
        Gruppe1 <- rep(grps,numberofGroups/length(grps),numberofGroups)
        Gruppe  <- rep(grps,each=PotsPerGroup)
        # green pixels per day
        Data$Gruppe <- Gruppe
        Data$Nummer <- Nummer
        #Data <- cbind(Data,Gruppe,Nummer)
        if (ini$Experiment$Facet2D) {
            treatments <- unlist(strsplit(ini$Experiment$UniqueFacets,","))
            treatments2 <- unlist(strsplit(ini$Experiment$Facet2DVar,","))
            Facet <- rep(treatments2, each = PotsPerGroup)
            Data$Facet <- Facet
        }
        Data$Gruppe <- factor(Data$Gruppe,levels = grps)
        
        
        
        summary <- describeBy(Data$plant_area,Data$Gruppe) #todo: implement logic for choosing normalised data. 
        #in that case, we either take the Data$plant_area_normalised-column, or we normalise via 'Data$plant_area/Data$plants_in_pot'
        #
        #
        Outliers <- Data %>%
            group_by(Gruppe) %>%
            identify_outliers("plant_area") 
        
        labelOutliers <- function(y) {
            o  <- boxplot.stats(y)$out
            if(length(o) == 0) NA else o
        }
        summary <- do.call("rbind",summary)
        summary <- data.frame(name=row.names(summary), summary)
        
        GFA_p_Outlier <- ggplot(Data
                                , aes(x = Gruppe, y = plant_area)) +
            geom_boxplot(outlier.color = "red"
                         , outlier.size = 2)
        p_Outlier2 <- ggplot(Data
                             , aes(x = Gruppe, y = plant_area)) +
            scale_x_discrete() +
            scale_y_discrete() +
            ggtitle(str_c("Day: ", curr_Day))+
            geom_boxplot(outlier.color = "red"
                         , outlier.size = 2) +
            stat_summary(
                aes(label = str_c(round(stat(y),1))),
                geom="text",
                fun=labelOutliers,
                hjust = -1
            )
        
        
        #print(p_Outlier2) # this will label the outlier with its value. 
        
        #TODO: figure out what to group_by by... 
        Outliers <- Data %>%
            group_by(Gruppe) %>%
            identify_outliers("plant_area") 
        
        wo_outliers <- Data %>% 
            anti_join(Outliers, by = "file") 
        
        
        ## Execute tests for 
        ##  Daten normalverteilt?
        ## if TRUE  -> uniforme Varianz durch Bartlett's Test | nutze wo_outliers_data
        ## if FALSE -> Varianz durch Levene-Test | nutze wo_outliers_data
        
        ##  
        
        norm <- wo_outliers %>%
            group_by(Gruppe) %>%
            summarise(statistic = shapiro.test(plant_area)$statistic,
                      p.value = shapiro.test(plant_area)$p.value)
        
        if (isNormallyDistributed(norm)) {
            #print(norm)
            BT   <- bartlett.test(plant_area ~ Gruppe, wo_outliers)
            BT <- do.call("rbind", BT)
            BT <- data.frame(names = row.names(BT), BT)
            
            #TODO: Double-Check if ref.group=UU is valid or if I must use a single-sided test here
            Data_stat_test <- subset(Data, select = -c(file) )
            Data_stat_test <- cbind(Data_stat_test,Data$file) # this makes no sense, but not removing and re-adding the file-column causes the stat-test to fail
            Data_stat_test <- group_by(Data)
            Data_stat_test$Group <- as.character(Data_stat_test$Gruppe)
            stat.test <- Data_stat_test %>%
                t_test(plant_area ~ Gruppe, var.equal = TRUE, alternative = "two.sided", ref.group = ini$Experiment$RefGroup) %>%
                add_significance("p") %>%
                add_xy_position(x = "Gruppe")
            # stat.test2 <- Data_stat_test %>% 
            #     t_test(plant_area ~ Gruppe, var.equal = T,alternative = "two.sided",ref.group = "Unstressed") %>%
            #     add_significance("p") %>%
            #     add_xy_position(x = "Gruppe")
            # stat.test3 <- Data_stat_test %>% 
            #     t_test(plant_area ~ Gruppe, var.equal = T,alternative = "two.sided",ref.group = "High Stress") %>%
            #     add_significance("p") %>%
            #     add_xy_position(x = "Gruppe")
        } else {
            levene   <- leveneTest(wo_outliers$plant_area, wo_outliers$Gruppe)
            
            #TODO: Double-Check if ref.group=UU is valid or if I must use a single-sided test here
            stat.test <- Data %>%
                group_by(Gruppe) %>%
                wilcox_test(plant_area ~ Gruppe, var.equal = TRUE, alternative = "two.sided", ref.group = ini$Experiment$RefGroup) %>%
                add_significance("p") %>%
                add_xy_position(x = "Gruppe")
        }
        XLSX_Path <- str_c(folder_path,"\\ROutput\\GFResults_" 
                           ,str_trim(curr_Day)
                           ,".xlsx")
        if (isTRUE(as.logical(saveExcel))) {
            write_xlsx(
                list("Data" = Data
                     ,"Outlier"= Outliers
                     , "data_wo_Outlier" = wo_outliers
                     , "Norm" = norm
                     , "BT" = BT
                     , "T.test" = stat.test
                     , "summary" = summary)
                , XLSX_Path)
        }
        scale_y_lowerEnd <- 0
        if (isTRUE(as.logical(ini$Experiment$ForceAxes))) {
            scale_y_upperEnd <- as.integer(ini$Experiment$ForcedUpperY)
        } else {
            scale_y_upperEnd <- round_any(ceiling(max(as.vector(Data$plant_area),na.rm = T)),25,f = ceiling)
        }
        
        #Palette_Boxplot <- getLastNElementsOfPalette("Reds",numberofGroups)
        #Palette_Lines   <- getLastNElementsOfPalette("Reds",numberofGroups)
        
        # replace the last colour because the group UU is placed there and is not strictly part of the drought groups, so to say.
        #Palette_Boxplot <- replace(Palette_Boxplot,list = numberofGroups,"white") 
        #Palette_Lines <- replace(Palette_Lines,list = numberofGroups,"#112734")
        Palette_Boxplot <- unlist(stringr::str_split(ini$Experiment$Palette_Boxplot,","))
        Palette_Lines <- unlist(stringr::str_split(ini$Experiment$Palette_Lines,","))
        
        if (hasName(ini$General,"Theme")) {
            Theme_Index <- ini$General$Theme
        }  else {
            Theme_Index <- 1   
        }
        numberofThemes <- 7 # Change this if you edit the switch-statement for 'Theme' below
        if (Theme_Index>numberofThemes) {
            Conditions$GenerateAllThemes <- TRUE #TODO: put set_theme-swtich, Theme_Switch and ggplot-call into a loop for 1:1:7 for Conditions$GenerateAllThemes==TRUE
        } else {
            Conditions$GenerateAllThemes <- FALSE
        }
        
        
        #
        set_theme <- switch(as.integer(Theme_Index),"tufte","bw","pubr","pubclean","labs_pubr","pubclean","clean") ## IF YOU WANT TO EDIT THEMES: There are 6 places  where this array must be changed, which are all located at and around occurences of the string 'switch(as.integer(' in the code. 
        
        # REMEMBER TO EDIT 'numberofThemes' above if you add/remove themes from this switch-statement
        Theme <- switch(as.integer(Theme_Index),
                        theme_tufte(base_size = 10),
                        theme_bw(base_size = 10),
                        theme_pubr(base_size = 10),
                        theme_pubclean(base_size = 10),
                        labs_pubr(10),
                        theme_pubclean(base_size = 10),
                        clean_theme())
        
        # Select the required number of colours from a sequencial color palette
        Palette_Boxplot <- getLastNElementsOfPalette("Reds",numberofGroups)
        Palette_Lines   <- getLastNElementsOfPalette("Reds",numberofGroups)
        Palette_Boxplot <- c("white",Palette_Boxplot)
        Palette_Boxplot <- Palette_Boxplot[1:6]
        Palette_Lines <- c("#112734",Palette_Lines)
        Palette_Lines <- Palette_Lines[1:6]
        if (hasName(ini$Experiment,"Palette_Boxplot2")) {
            Palette_Boxplot <- unlist(stringr::str_split(ini$Experiment$Palette_Boxplot2,","))
        }
        if (hasName(ini$Experiment,"Palette_Boxplot2")) {
            Palette_Lines <- unlist(stringr::str_split(ini$Experiment$Palette_Lines2,","))
        }
        
        
        
        # coerce boolean checks into logical
        Conditions$Language <- as.logical(ini$General$language=='German')
        Conditions$Normalise  <- as.logical(ini$Experiment$Normalise)
        Conditions$UseRelativeColnames <- as.logical(ini$General$RelativeColnames)
        Conditions$PlotMeanLine <- as.logical(ini$General$PlotMeanLine)
        Conditions$PlotSampleSize <- as.logical(ini$General$PlotSampleSize)
        
        # assemble label strings
        unit_x <- stringr::str_split(ini$General$axis_units_x,",")
        unit_y <- stringr::str_split(ini$General$axis_units_y,",")
        unit_x <- if_else(Conditions$Language
                          , true=unit_x[[1]][1]
                          , false=unit_x[[1]][2])
        unit_y <- if_else(Conditions$Language
                          , true=unit_y[[1]][1]
                          , false=unit_y[[1]][2])
        
        TitleTimeSpan <- calculateColnames(Files,List,ini,T)
        if (isFALSE(is.null(ini$Experiment$Title_Daily))) {
            plot_Title <- str_c(ini$Experiment$Title_Daily[[1]]," (",str_trim(curr_Day),")")
        } else {
            plot_Title <- if_else(Conditions$Language
                                  , true=str_c("Grünfläche (",  str_trim(curr_Day) ,")")
                                  , false=str_c("Green area (", str_trim(curr_Day) ,")"))
        }
        if (as.logical(ini$General$Debug)) {
            plot_Subtitle <- str_c("Experiment: " , ini$Experiment$Name
                                   , "\nT0: ", ini$Experiment$T0
                                   # , "\nrelative column names: ", Conditions$UseRelativeColnames
                                   , "\nNormalised: NOT IMPLEMENTED ", Conditions$Normalise
                                   , "\nPots per Group: ", PotsPerGroup
                                   , "\nFigure generated: ", as.character.POSIXt(now(),"%d.%m.%Y %H:%M:%S")
                                   , "\n  Theme: ",set_theme, " (", Theme_Index, ")"
                                   , "\n  Sample-Size: ", Conditions$PlotSampleSize
                                   , "\n  Palette:", str_c(Palette_Boxplot,collapse = ", "))
            
            #, "\n  Lines: ", Conditions$PlotMeanLine
        } else {
            if (isFALSE(is.null(ini$Experiment$YLabel))) {
                plot_Subtitle <- str_c(ini$Experiment$SubTitle_Daily[[1]]," (",str_trim(curr_Day),")")
            } else {
                plot_Subtitle <- str_c("Experiment: " , ini$Experiment$Name
                                       , if_else(Conditions$Language
                                                 , true=str_c("\nUmtopfen: ", ini$Experiment$T0
                                                              ,"\nSample-Size: ", PotsPerGroup)
                                                 , false=str_c("\nDate of Repotting: ", ini$Experiment$T0
                                                               ,"\nSample-Size: ", PotsPerGroup))
                                       ,""
                                       ,"")
            }
        }
        
        
        if (isFALSE(is.null(ini$Experiment$YLabel))) {
            x_label <- str_c(ini$Experiment$XLabel[[1]]," [",unit_x,"]")
        } else {
            x_label <- if_else(Conditions$Language
                               , true=str_c("Versuchs-Gruppen")
                               , false=str_c("Treatment groups")
                               , missing=if_else(Conditions$UseRelativeColnames
                                                 , true=str_c("Versuchs-Gruppen")
                                                 , false=str_c("Treatment groups")))
            
        }
        
        if (isFALSE(is.null(ini$Experiment$YLabel))) {
            y_label <- str_c(ini$Experiment$YLabel[[1]]," [",unit_y,"]")
        } else {
            y_label <- if_else(Conditions$Normalise, 
                               if_else(Conditions$Language
                                       , true=str_c("Normalisierte Grünfläche  [",unit_y,"]")
                                       , false=str_c("normalised green plant area [",unit_y,"]")
                                       , missing=str_c("normalised green plant area [",unit_y,"]")),
                               if_else(Conditions$Language
                                       , true=str_c("Grünfläche  [",unit_y,"]")
                                       , false=str_c("Green plant area [",unit_y,"]")
                                       , missing=str_c("Green plant area [",unit_y,"]")))
        }
        filename <- str_c("GF-Einzelanalyse"
                          , " ("
                          , ini$Experiment$Name
                          , ", "
                          , str_trim(curr_Day)
                          , ") "
                          , if_else(Conditions$Normalise
                                    , "norm"
                                    , "non-norm")
                          , "_"
                          , if_else(Conditions$UseRelativeColnames
                                    , "relColNms"
                                    , "absColNms")
                          , "_"
                          , ini$General$language
                          , "_"
                          , Theme_Index
                          , ").jpg")
        
        #facet_grid(. ~ factor(Group,levels=c("UU","G14","G21","G28","G35","GMax")),space = "fixed")+
        #facet_grid(. ~ factor(Group,levels=unlist(stringr::str_split(ini$Experiment$GroupsOrder,","))),space = "fixed")+
        Limits <- as.numeric(unlist(stringr::str_split(ini$Experiment$YLimits,",")))
        if (isTRUE(as.logical(ini$Experiment$ForceAxes))) {
            
            #scale_y_upperEnd <- as.integer(ini$Experiment$ForcedUpperY)
            scale_y_upperEnd <- round_any(ceiling(max(as.vector(Data$plant_area),na.rm = T)),25,f = ceiling)
            Limits[[2]] <- scale_y_upperEnd
        } else {
            
            scale_y_upperEnd <- round_any(ceiling(max(as.vector(Data$plant_area),na.rm = T)),25,f = ceiling)
            Limits[[2]] <- scale_y_upperEnd
        }
        #$Gruppe = factor(Data$Gruppe,levels=ini$Experiment$GroupsOrder)
        Data$Gruppe = factor(Data$Gruppe,levels=unlist(stringr::str_split(ini$Experiment$GroupsOrder,",")))
        GFA_plot_box <-  ggboxplot(Data, x= "Gruppe"
                                   , y = "plant_area"
                                   , fill = "Gruppe"
                                   , palette = Palette_Boxplot
                                   , color = "black"
                                   , add = "jitter"
                                   , ylab = y_label
                                   , xlab = x_label) +
            #, facet.by = "Gruppe") +
            #, facet.by = "Stress") +
            font("xy.text", size = 10, color = "black") +
            font("ylab", size = 10, color = "black") +
            font("legend.title", size = 10, color = "black") +
            ggtitle(plot_Title
                    , plot_Subtitle)
        if (hasName(ini$General,"Breakstepsize")) {
            Breakstepsize <- ini$General$Breakstepsize
            if (Limits[[2]] %% 4) {
                nbreaks <- 4
            } else {
                nbreaks <- 5
            }
        } else {
            maximum <- Limits[[2]]
            if (maximum<100) {
                Breakstepsize <- 20
                if (Limits[[2]] %% 4) {
                    nbreaks <- 4
                } else {
                    nbreaks <- 5
                }
            }
            if (maximum>=100) {
                Breakstepsize <- 25
                nbreaks <- 4
            }
            if (maximum>=150) {
                Breakstepsize <- 50
                nbreaks <- 3
            }
            if (maximum>=300) {
                Breakstepsize <- 100
                nbreaks <- 3
            }
            if (maximum>=500) {
                Breakstepsize <- 125
                nbreaks <- 4
            }
            if (maximum>=1000) {
                Breakstepsize <- 250
                nbreaks <- 4
            }
        }
        GFA_plot_box <- GFA_plot_box + scale_y_continuous(breaks = seq(Limits[[1]],Limits[[2]],Breakstepsize),n.breaks = nbreaks, ## round_any is used to get the closest multiple of 25 above the maximum value of the entire dataset to generate tick
                                                          limits = c(Limits[[1]],Limits[[2]]))
        
        
        stat.test$p.scient <- formatPValue(stat.test$p)
        #GFA_plot_box2 <- GFA_plot_box + stat_pvalue_manual(stat.test,xmin="group2"
        #                                                  , label = "{p} {p.adj.signif}"
        #                                                  , size = 2.5
        #                                                  , remove.bracket = TRUE
        #                                                  , y.position = Limits[[2]]-1)
        GFA_plot_box <- GFA_plot_box + stat_pvalue_manual(stat.test,xmin="group2"
                                                          , label = "{p.scient} {p.adj.signif}"
                                                          , size = 2.5
                                                          , remove.bracket = TRUE
                                                          , y.position = Limits[[2]]-1)
        GFA_plot_box <- GFA_plot_box + 
            guides(fill=guide_legend(title="Groups")) +
            theme(plot.title = element_text(hjust = 0.5))
        
        if (ini$General$Debug) {
            GFA_plot_box <- GFA_plot_box + theme(plot.subtitle = element_text(size = 5))
        } else {
            GFA_plot_box <- GFA_plot_box + theme(plot.subtitle = element_text(size = 5))
        }
        
        # Speicher den Boxplot als jpg Datei unter dem eingegebenen Namen 
        if (Conditions$PlotSampleSize) {
            if (as.logical(ini$General$Debug)) {
                GFA_plot_box <- GFA_plot_box + stat_summary(fun.data = labelSample_n
                                                            , geom = "text"
                                                            , hjust = 0.5
                                                            , size = 2.5
                                                            , fontface = "bold")
            }
        }
        GFA_plot_box <- GFA_plot_box + ggpubr::theme_pubclean() + theme(legend.position = "bottom", legend.key = element_rect(fill = "transparent")) + ggpubr::grids("y",linetype=1)
        if (str_length(str_c(folder_path,"ROutput\\",filename))>256) {
            clen <- str_length(str_c(folder_path,"ROutput\\",filename))
            deslen <- 256
            lendiff <- clen-deslen+4
            filename2 <- str_sub(filename,1,str_length(filename)-lendiff)
            new <- str_c(folder_path,"ROutput\\",filename2,".jpg")
            old <- str_c(folder_path,"ROutput\\",filename2)
            if (str_length(new)==256) {
                filename <- str_c(filename2,".jpg")
            }
            rm(new,old,clen,deslen,lendiff)
        }
        if (isTRUE(as.logical(saveFigures))) {
            ggsave(filename = filename
                   , plot=GFA_plot_box
                   , width=7
                   , height=5
                   , dpi = 300
                   , path = str_c(folder_path,"ROutput\\"))
        }
        Results=list("Data" = Data
                     ,"Outlier"= Outliers
                     , "data_wo_Outlier" = wo_outliers
                     , "Norm" = norm
                     , "BT" = BT
                     , "T.test" = stat.test
                     , "summary" = summary)
        ret[[str_trim(curr_Day)]]=list(boxplot=GFA_plot_box,outlierplot=GFA_p_Outlier,Res=Results)
        if (Conditions$GenerateAllThemes) {
            if (Day_Index==1) { # if we are testing all themes, no need to print multiple figures of the same stup
                break
            } 
        }
        
    }
    return(ret)
}


#----- MAIN SCRIPT
#
#
library(rstatix)
library(tidyverse)
library(writexl)
library(RColorBrewer)
library(stringr)
library(dplyr)
library(lubridate)
library(svDialogs)
library(ggpubr)
library(ggthemes)
library(tidyr)
library(readxl)
library(tufte)
library(ini)
library(forcats)
library(psych)
library(plyr)
library(ini)
GFA_main <- function(folder_path,returnDays=FALSE,saveFigures=FALSE,saveExcel=FALSE,saveRDATA=FALSE) {
    
    path <- stringr::str_c(folder_path,stringr::str_replace('\\GFA_conf.ini',"\\\\","\\"))
    if (isFALSE(checkExistence(path))) {
        Experiment <- list(Name="Experiment 2"
                           ,Facet2D="F"
                           ,Facet2DVar="Treatment"
                           ,T0="15.05.2023"
                           ,PotsPerGroup="8"
                           ,UniqueGroups="High Stress,High Stress + ABA,Low Stress,Unstressed"
                           ,GroupsOrder="Unstressed,Low Stress,High Stress,High Stress + ABA"
                           ,RefGroup="Unstressed"
                           ,FixateAxes="F"
                           ,ForceAxes="F"
                           ,XLabel="Time since repotting"
                           ,YLabel="normalised green and drought plant area"
                           ,YLimits="0,125"
                           ,Normalise="T"
                           ,Filename_Prefix="GF2.3"
                           ,Palette_Boxplot="#CB181D,#406a41,#EF3B2C,white"
                           ,Palette_Lines="#CB181D,#406a41,#EF3B2C,#112734,"
                           ,Palette_Boxplot2="white,#EF3B2C,#CB181D,#406a41,"
                           ,Palette_Lines2="#112734,#EF3B2C,#CB181D,#406a41,")
        General <- list( ShowNatallboxplots=F
                         ,ShowTitle=F
                         ,PlotMeanLine=T
                         ,PlotSampleSize=T
                         ,Debug=F
                         ,Theme=6
                         ,language="English"
                         ,used_filesuffix="xlsx"
                         ,axis_units_x="Tage,days"
                         ,axis_units_y="cm^2,cm^2"
                         ,RelativeColnames="F"
                         ,ShowBothColnames="T")
        object <- list()
    }
    ini <- ini::read.ini(path)
    if (isFALSE(exists("Conditions",where = -1))) {
        Conditions <- {}
    }
    #ini <- ini::read.ini(filepath = "GFA_conf.ini",)
    Files <- getFilesInFolder(folder_path,ini$General$used_filesuffix,'GFResults_',T)
    
    # Error out if ini is invalid.
    ErrorString <- validateINI(ini)
    if (isFALSE((typeof(ErrorString)=="logical"))) {
        Error <- simpleError(str_c("\nIni does not contain all required information. Please double-Check the config file 'GFA_conf.ini':" , ErrorString,sep = "\n"))
        stop(Error)
    }
    
    
    #todo: figure out an algorithm or user interface for doing this here
    
    # calculate group sizes
    PotsPerGroup <- ini$Experiment$PotsPerGroup
    Number <- as.integer(PotsPerGroup)
    
    UniqueGroups <- ini$Experiment$UniqueGroups
    UniqueGroups <- as.character(UniqueGroups)
    numberofGroups <- length(strsplit(UniqueGroups,",")[1][[1]])
    Number <- rep(1:Number, times = numberofGroups)
    grps <- unlist(strsplit(UniqueGroups, split = ','))
    Group <- rep(grps, each = PotsPerGroup)
    
    
    data_all_CA <- cbind(Group,Number)
    if (ini$Experiment$Facet2D) {
        treatments <- unlist(strsplit(ini$Experiment$UniqueFacets,","))
        treatments2 <- unlist(strsplit(ini$Experiment$Facet2DVar,","))
        Facet <- rep(treatments2, each = PotsPerGroup)
        data_all_CA <- cbind(data_all_CA,Facet)
    }
    data_all_CA <- importCSV_Data1(Files,data_all_CA,ini)
    data_all_dailies <- data_all_CA
    data_all_CA <- as.data.frame(data_all_CA);
    data_all_CA <- assignDaysToVariables(Files,data_all_CA,ini)
    data_all_CA <- createFactors(data_all_CA,grps)
    Colnames <- calculateColnames(Files,List,ini)
    if (isTRUE(as.logical(ini$General$RelativeColnames))) {
        data_all_CA <- forcePLANT_AREAtoNumeric(data_all_CA,ini)
    } else {
        data_all_CA <- forcePLANT_AREAtoNumeric(data_all_CA,ini)
    }
    if (ini$Experiment$Facet2D) {
        GroupNoFacet <- ini$Experiment$GroupNoFacet
        GroupNoFacet <- as.character(GroupNoFacet)
        numberofGroups <- length(strsplit(GroupNoFacet,",")[1][[1]])
        Number <- rep(1:Number, times = numberofGroups)
        newgrps <- unlist(strsplit(GroupNoFacet, split = ','))
        Group <- rep(newgrps, each = PotsPerGroup)
        data_all_CA$Group <- Group
        data_pivot_CA <- pivot_longer(data_all_CA,cols=4:(length(data_all_CA)-0),names_to = "Days")
        data_pivot_CA$Group <- factor(data_pivot_CA$Group)
        data_pivot_CA$Facet <- factor(data_pivot_CA$Facet)
    } else {
        data_pivot_CA <- pivot_longer(data_all_CA,cols=3:(length(data_all_CA)-0),names_to = "Days")
    }
    
    if (isTRUE(as.logical(ini$General$RelativeColnames))) {
    } else {
        data_pivot_CA$Days <- as.factor(data_pivot_CA$Days)
        if (ini$Experiment$Facet2D) {
            data_pivot_CA$Facet <- as.factor(data_pivot_CA$Facet)
        }
    }
    
    
    
    if (hasName(ini$General,"Theme")) {
        Theme_Index <- ini$General$Theme
    }  else {
        Theme_Index <- 1   
    }
    numberofThemes <- 7 # Change this if you edit the switch-statement for 'Theme' below
    if (Theme_Index>numberofThemes) {
        Conditions$GenerateAllThemes <- TRUE #TODO: put set_theme-swtich, Theme_Switch and ggplot-call into a loop for 1:1:7 for Conditions$GenerateAllThemes==TRUE
    } else {
        Conditions$GenerateAllThemes <- FALSE
    }
    
    
    Themes <- c("tufte","bw","pubr","pubclean","labs_pubr","pubclean","clean")
    set_theme <- switch(as.integer(Theme_Index),Themes) ## IF YOU WANT TO EDIT THEMES: There are 6 places  where this array must be changed, which are all located at and around occurences of the string 'switch(as.integer(' in the code. 
    if (Theme_Index>numberofThemes) {
        set_theme <- stringr::str_c(Themes,collapse = ", ")
        
    } else {
        # REMEMBER TO EDIT 'numberofThemes' above if you add/remove themes from this switch-statement
        Theme <- switch(as.integer(Theme_Index),
                        theme_tufte(base_size = 10),
                        theme_bw(base_size = 10),
                        theme_pubr(base_size = 10),
                        theme_pubclean(base_size = 10),
                        labs_pubr(10),
                        theme_pubclean(base_size = 10),
                        clean_theme())
    }
    
    # Select the required number of colours from a sequencial color palette
    Palette_Boxplot <- getLastNElementsOfPalette("Reds",numberofGroups)
    Palette_Lines   <- getLastNElementsOfPalette("Reds",numberofGroups)
    
    # replace the last colour because the group UU is placed there and is not strictly part of the drought groups, so to say.
    Palette_Boxplot <- replace(Palette_Boxplot,list = numberofGroups,"white") 
    Palette_Lines <- replace(Palette_Lines,list = numberofGroups,"#112734")
    if (hasName(ini$Experiment,"Palette_Boxplot")) {
        Palette_Boxplot <- unlist(stringr::str_split(ini$Experiment$Palette_Boxplot,","))
    }
    if (hasName(ini$Experiment,"Palette_Lines")) {
        Palette_Lines <- unlist(stringr::str_split(ini$Experiment$Palette_Lines,","))
    }
    
    
    # coerce boolean checks into logical
    Conditions$Language <- as.logical(ini$General$language=='German')
    Conditions$Normalise  <- as.logical(ini$Experiment$Normalise)
    Conditions$UseRelativeColnames <- as.logical(ini$General$RelativeColnames)
    Conditions$PlotMeanLine <- as.logical(ini$General$PlotMeanLine)
    Conditions$PlotSampleSize <- as.logical(ini$General$PlotSampleSize)
    
    # assemble label strings
    unit_x <- stringr::str_split(ini$General$axis_units_x,",")
    unit_y <- stringr::str_split(ini$General$axis_units_y,",")
    unit_x <- if_else(Conditions$Language
                      , true=unit_x[[1]][1]
                      , false=unit_x[[1]][2])
    unit_y <- if_else(Conditions$Language
                      , true=unit_y[[1]][1]
                      , false=unit_y[[1]][2])
    
    TitleTimeSpan <- calculateColnames(Files,List,ini,T)
    
    SortedTitleTimespan <- sort(unlist(as.vector(TitleTimeSpan)))
    TitleDates <- calculateColnames(Files,List,ini,T,T)
    TitleDates  <- getMaximumDateRange(TitleDates)
    #todo: subtitle: Give experiment number (2.1 vs 2.2)
    plot_Title <- if_else(Conditions$Language
                          , true=str_c("Entwicklung der Grünfläche (", min(as.vector(unlist(TitleTimeSpan))), "-", max(as.vector(unlist(TitleTimeSpan)))," ",unit_x," nach Umtopfen)")
                          , false=str_c("Green area development (", min(as.vector(unlist(TitleTimeSpan))), "-", max(as.vector(unlist(TitleTimeSpan)))," ",unit_x ," post repotting)"))
    if (as.logical(ini$General$Debug)) {
        plot_Subtitle <- str_c("Experiment: " , ini$Experiment$Name
                               , "\nT0: ", ini$Experiment$T0
                               # , "\nrelative column names: ", Conditions$UseRelativeColnames
                               , "\nSample-Size: ", PotsPerGroup
                               , "\nFigure generated: ", as.character.POSIXt(now(),"%d.%m.%Y %H:%M:%S")
                               , "\n  Theme: ",set_theme, " (", Theme_Index, ")"
                               , "\n  Sample-Size: ", Conditions$PlotSampleSize
                               , "\n  Palette: ", str_c(str_c(Palette_Boxplot,collapse = ", ")," || ",str_c(Palette_Lines,collapse = ", "))
                               , "\n  Date-Range: ", str_c(TitleDates[[1]]," - ", TitleDates[[2]]))
        
        #, "\n  Lines: ", Conditions$PlotMeanLine
    } else {
        
        plot_Subtitle <- str_c("Experiment: " , ini$Experiment$Name
                               #, if_else(Conditions$Language
                               #          , true=str_c("\nUmtopfen: ", ini$Experiment$T0)
                               #          , false=str_c("\nDate of Repotting: ", ini$Experiment$T0))
                               , if_else(Conditions$Language
                                         , true=str_c("\nUmtopfen: ", ini$Experiment$T0
                                                      ,"\nSample-Size: ", PotsPerGroup)
                                         , false=str_c("\nDate of Repotting: ", ini$Experiment$T0
                                                       ,"\nSample-Size: ", PotsPerGroup))
                               ,""
                               ,"")
    }
    if (isFALSE(as.logical(ini$General$ShowNatallboxplots))) {
        if (isTRUE(as.logical(ini$General$bLabeledOnlynonmaxed))) {
            plot_Subtitle <- str_c(plot_Subtitle,"\nSample Size")
        }
    }
    if (isFALSE(is.null(ini$Experiment$XLabel))) {
        x_label <- str_c(ini$Experiment$XLabel[[1]]," [",unit_x,"]")
    } else {
        x_label <- if_else(Conditions$Language
                           , true=if_else(Conditions$UseRelativeColnames
                                          , true=str_c("Pflanzenalter [",unit_x,"]")
                                          , false=str_c("Messtage")
                                          , missing=str_c("Pflanzenalter [",unit_x,"]"))
                           , false=if_else(Conditions$UseRelativeColnames
                                           , true=str_c("Plant age [",unit_x,"]")
                                           , false=str_c("Dates of measurement")
                                           , missing=str_c("Plant age [",unit_x,"]"))
                           , missing=if_else(Conditions$UseRelativeColnames
                                             , true=str_c("Plant age [",unit_x,"]")
                                             , false=str_c("Dates of measurement")
                                             , missing=str_c("Plant age [",unit_x,"]")))
    }
    
    
    
    if (isFALSE(is.null(ini$Experiment$YLabel))) {
        y_label <- str_c(ini$Experiment$YLabel[[1]]," [",unit_y,"]")
    } else {
        y_label <- if_else(Conditions$Normalise, 
                           if_else(Conditions$Language
                                   , true=str_c("Normalisierte Grünfläche  [",unit_y,"]")
                                   , false=str_c("normalised green plant area [",unit_y,"]")
                                   , missing=str_c("normalised green plant area [",unit_y,"]")),
                           if_else(Conditions$Language
                                   , true=str_c("Grünfläche  [",unit_y,"]")
                                   , false=str_c("Green plant area [",unit_y,"]")
                                   , missing=str_c("Green plant area [",unit_y,"]")))
    }
    
    
    
    filename <- str_c("GF-Verlauf"
                      , " (" 
                      , ini$Experiment$Name
                      , ", "
                      , TitleDates[1]
                      , " - "
                      , TitleDates[length(TitleDates)]
                      , ") "
                      , if_else(Conditions$Normalise
                                , "norm"
                                , "non-norm")
                      , "_"
                      , if_else(Conditions$UseRelativeColnames
                                , "relColNms"
                                , "absColNms")
                      , "_"
                      , ini$General$language
                      , "_"
                      , Theme_Index
                      , ").jpg")
    
    
    scale_y_lowerEnd <- 0
    if (isTRUE(as.logical(ini$Experiment$ForceAxes))) {
        
        scale_y_upperEnd <- as.integer(ini$Experiment$ForcedUpperY)
        Limits <- as.numeric(unlist(stringr::str_split(ini$Experiment$YLimits,",")))
    } else {
        
        scale_y_upperEnd <- round_any(ceiling(max(as.vector(data_pivot_CA$value),na.rm = T)),25,f = ceiling)
        Limits <- c(scale_y_lowerEnd,scale_y_upperEnd)
    }
    if (Conditions$UseRelativeColnames) {
        
        data_pivot_CA$Days <- as.numeric(data_pivot_CA$Days)
    } else {
        data_pivot_CA$Days <- factor(data_pivot_CA$Days, ordered = T)
        data_pivot_CA$Days <- as.Date(data_pivot_CA$Days,format = "%d.%m.%Y")
    }
    
    if (isTRUE(as.logical(ini$Experiment$Facet2D))) {
        GFA_SummaryPlot <- ggplot(data_pivot_CA,aes(x = Days,
                                                    y = value,
                                                    fill = interaction(Group,Facet),
                                                    group = Days))
    } else {
        GFA_SummaryPlot <- ggplot(data_pivot_CA,aes(x = Days,
                                                    y = value,
                                                    fill = Group,
                                                    group = Days))
    }
    if (isTRUE(as.logical(ini$Experiment$Facet2D))) {
        facetFormula <- "Facet"
        GFA_SummaryPlot <- GFA_SummaryPlot + facet_grid(Facet ~ factor(Group,levels=unlist(unique(data_pivot_CA$Group))),space = "fixed")
    } else {
        GFA_SummaryPlot <- GFA_SummaryPlot + facet_grid(. ~ factor(Group,levels=unlist(stringr::str_split(ini$Experiment$GroupsOrder,","))),space = "fixed")
    }
    GFA_SummaryPlot <- GFA_SummaryPlot + 
        #todo::: how to fix this boxplot to be split per date
        geom_boxplot(outlier.shape = "X", 
                     alpha =0.5,) +
        geom_point(pch = 21, 
                   position = position_jitterdodge())
    if (isTRUE(as.logical(ini$Experiment$Facet2D))) {
        GFA_SummaryPlot <- GFA_SummaryPlot + 
            scale_fill_manual(values = Palette_Boxplot)+
            scale_colour_manual(values = Palette_Lines)
    } else {
        GFA_SummaryPlot <- GFA_SummaryPlot + 
            scale_fill_manual(values = Palette_Boxplot)+
            scale_colour_manual(values = Palette_Lines)
    }
    if (isTRUE(as.logical(ini$General$ShowTitle)) || isTRUE(as.logical(ini$General$Debug))) {
        GFA_SummaryPlot <- GFA_SummaryPlot + 
            ggtitle(plot_Title,plot_Subtitle)
    }
    GFA_SummaryPlot <- GFA_SummaryPlot + guides(x=guide_axis(angle=90))
    
    if (isTRUE(as.logical(ini$General$ShowBothColnames))) {
        if (Conditions$UseRelativeColnames) { ## continuous scale  <-  scale needs numbers, labels need format "{date} - {age}"
            GFA_summary_Breaks <- calculateColnames(Files,List,ini,bGetDiff = T,bForceActualDates = F)
            GFA_summary_Labels <- paste(calculateColnames(Files,List,ini,bGetDiff = T,bForceActualDates = T)," - ",GFA_summary_Breaks)
            GFA_SummaryPlot <- GFA_SummaryPlot + scale_x_continuous(breaks=as.integer(GFA_summary_Breaks),labels = GFA_summary_Labels) #todo: figure out if I can use this properly
        } else {                              ## date-scale  <-  scale needs dates, labels need format "{date} - {age}"
            GFA_summary_Breaks <- sort(as.Date.character(unlist(calculateColnames(Files,List,ini,bGetDiff = F,bForceActualDates = T)),format = "%d.%m.%Y"))
            GFA_summary_Labels <- paste(calculateColnames(Files,List,ini,bGetDiff = T,bForceActualDates = T)," - ",calculateColnames(Files,List,ini,bGetDiff = T,bForceActualDates = F))
            GFA_summary_Labels <- GFA_summary_Labels[order(unlist(calculateColnames(Files,List,ini,bGetDiff = T,bForceActualDates = F)))]
            GFA_SummaryPlot <- GFA_SummaryPlot + scale_x_date(breaks=GFA_summary_Breaks,labels = GFA_summary_Labels) #todo: figure out if I can use this properly
        }
        
    } else {
        if (Conditions$UseRelativeColnames) { ## continuous scale  <- scale needs numbers, labels need format "{age}"       || validated to label correctly
            GFA_summary_Breaks <- calculateColnames(Files,List,ini,bGetDiff = T,bForceActualDates = F)
            GFA_summary_Labels <- paste(GFA_summary_Breaks)
            GFA_SummaryPlot <- GFA_SummaryPlot + scale_x_continuous(breaks=as.integer(GFA_summary_Breaks),labels = GFA_summary_Labels) #todo: figure out if I can use this properly
        } else {                              ## date-scale  <- scale needs dates, labels need format "{date}"              || validated to label correctly
            GFA_summary_Breaks <- sort(as.Date.character(unlist(calculateColnames(Files,List,ini,bGetDiff = F,bForceActualDates = T)),format = "%d.%m.%Y"))
            GFA_summary_Labels <- paste(format(GFA_summary_Breaks, "%d.%m.%Y"))
            GFA_SummaryPlot <- GFA_SummaryPlot + scale_x_date(breaks=GFA_summary_Breaks,labels = GFA_summary_Labels) #todo: figure out if I can use this properly
        }
    }
    GFA_SummaryPlot <- GFA_SummaryPlot + scale_y_continuous(breaks = seq(Limits[[1]],Limits[[2]],25), ## round_any is used to get the closest multiple of 25 above the maximum value of the entire dataset to generate tick
                                                            limits = c(Limits[[1]],Limits[[2]])) ## same here to scale the axis
    if (Conditions$PlotMeanLine) {
        GFA_SummaryPlot <- GFA_SummaryPlot + stat_summary(fun = mean,
                                                          geom = "line",
                                                          linewidth = 0.8,
                                                          position = position_dodge(width=0.75),
                                                          aes(group = Group,
                                                              colour = Group),
                                                          show.legend = F) # set this to true if you want to have extra legend entries for the geom_line-objects plotting the means. 
    }
    
    GFA_SummaryPlot <- GFA_SummaryPlot +labs(x=x_label
                                             , y=y_label
                                             ,fill = if_else(Conditions$Language
                                                             , "Gruppen"
                                                             , "Groups")
    )
    #Conditions$PlotSampleSize <- T
    if (Conditions$PlotSampleSize) {
        if (as.logical(ini$General$Debug)) {
            #todo: only label those differing in size, then put the general sample size in the subtitle
            GFA_SummaryPlot <- GFA_SummaryPlot + stat_summary(fun.data = labelSample_n, 
                                                              geom = "text", 
                                                              hjust = 0.5, 
                                                              size = 2.5, 
                                                              fontface = "bold",
                                                              position = position_dodge(width=0.75))
        }
    }
    if (hasName(ini$Experiment,"FixateAxes")) {
        if (isTRUE(as.logical(ini$Experiment$FixateAxes))) {
            Limits <- as.numeric(unlist(stringr::str_split(ini$Experiment$YLimits,",")))
            GFA_SummaryPlot <- GFA_SummaryPlot + scale_y_continuous(breaks = seq(Limits[[1]],Limits[[2]],25), ## round_any is used to get the closest multiple of 25 above the maximum value of the entire dataset to generate tick
                                                                    limits = c(Limits[[1]],Limits[[2]]))
        }
    }
    
    
    
    if (ini$General$Debug) {
        GFA_SummaryPlot <- GFA_SummaryPlot + theme(plot.subtitle = element_text(size=5))
    } else {
        GFA_SummaryPlot <- GFA_SummaryPlot + theme(plot.subtitle = element_text(size=8))
    }
    
    
    
    GFA_SummaryPlot + grids("y",linetype=1)
    
    
    
    
    if (Conditions$GenerateAllThemes) {
        curr_ThemeIndex <- 1   
        for (Theme in a <- c("tufte","bw","pubr","pubclean","labs_pubr","pubclean","clean")) { ## IF YOU WANT TO EDIT THEMES: There are 6 places  where this array must be changed, which are all located at and around occurences of the string 'switch(as.integer(' in the code. 
            curr_Theme <- switch(as.integer(curr_ThemeIndex),
                                 theme_tufte(base_size = 10),
                                 theme_bw(base_size = 10),
                                 theme_pubr(base_size = 10),
                                 theme_pubclean(base_size = 10),
                                 labs_pubr(10),
                                 theme_pubclean(base_size = 10),
                                 clean_theme())
            filename_themeReview <- str_replace_all(filename,pattern = "_99\\)",replacement = str_c('_',curr_ThemeIndex,')'))
            curr_ThemeIndex <- curr_ThemeIndex+1
            GFA_SummaryPlot <- GFA_SummaryPlot + curr_Theme
            GFA_SummaryPlot <- GFA_SummaryPlot + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0)) # rotate the axis labels.
            GFA_SummaryPlot <- GFA_SummaryPlot + theme(legend.position = "bottom", legend.key = element_rect(fill = "transparent"))  # set the legend stylings
            GFA_SummaryPlot <- GFA_SummaryPlot + ggpubr::grids("y",linetype=1)
            # 
            #print(GFA_SummaryPlot)
            # Save the figure
            if (str_length(str_c(folder_path,"ROutput\\",filename_themeReview))>256) {
                clen <- str_length(str_c(folder_path,"ROutput\\",filename_themeReview))
                deslen <- 256
                lendiff <- clen-deslen+4
                filename_themeReview2 <- str_sub(filename_themeReview,1,str_length(filename_themeReview)-lendiff)
                new <- str_c(folder_path,"ROutput\\",filename_themeReview2,".jpg")
                old <- str_c(folder_path,"ROutput\\",filename_themeReview)
                if (str_length(new)==256) {
                    filename_themeReview <- str_c(filename_themeReview2,".jpg")
                }
                rm(new,old,clen,deslen,lendiff,filename_themeReview2)
            }
            print(GFA_SummaryPlot)
            if (isTRUE(as.logical(saveFigures))) {
                ggsave(file=filename_themeReview
                       , plot=GFA_SummaryPlot, width=12, height=10, dpi = 300,path=str_c(folder_path,"ROutput\\"))
            }
            
        }
    } else { ## use a single theme
        if (hasName(ini$General,"Theme")) { ## choosing a theme via the config only takes effect when you plot a specific theme. if you plot all themes, you won't see this.
            curr_ThemeIndex <- ini$General$Theme
        }  else {
            curr_ThemeIndex <- 1   
        }
        curr_Theme <- switch(as.integer(curr_ThemeIndex),  ## IF YOU WANT TO EDIT THEMES: There are 6 places  where this array must be changed, which are all located at and around occurences of the string 'switch(as.integer(' in the code. 
                             theme_tufte(base_size = 10),
                             theme_bw(base_size = 10),
                             theme_pubr(base_size = 10),
                             theme_pubclean(base_size = 10),
                             labs_pubr(10),
                             theme_pubclean(base_size = 10),
                             clean_theme())
        GFA_SummaryPlot <- GFA_SummaryPlot + curr_Theme
        #GFA_SummaryPlot <- GFA_SummaryPlot + labs(caption = "Data source: ToothGrowth") # does not render properly in docx-report for it to be suitable for me.
        GFA_SummaryPlot <- GFA_SummaryPlot + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=0)) # rotate the axis labels.
        GFA_SummaryPlot <- GFA_SummaryPlot + theme(legend.position = "bottom", legend.key = element_rect(fill = "transparent"))  # set the legend stylings
        GFA_SummaryPlot <- GFA_SummaryPlot + ggpubr::grids("y",linetype=1)
        #print(GFA_SummaryPlot)
        # Save the figure
        if (str_length(str_c(folder_path,"ROutput\\",filename))>256) {
            clen <- str_length(str_c(folder_path,"ROutput\\",filename))
            deslen <- 256
            lendiff <- clen-deslen+4
            filename2 <- str_sub(filename,1,str_length(filename)-lendiff)
            new <- str_c(folder_path,"ROutput\\",filename2,".jpg")
            old <- str_c(folder_path,"ROutput\\",filename)
            if (str_length(new)==256) {
                filename <- str_c(filename2,".jpg")
            }
        }
        #print(GFA_SummaryPlot)
        rm(new,old,clen,deslen,lendiff)
        if (isTRUE(as.logical(saveFigures))) {
            ggsave(file=filename
                   , plot=GFA_SummaryPlot, width=12, height=10, dpi = 300,path=str_c(folder_path,"ROutput\\"))
        }
    }
    
    # Display the figure.
    #setwd(folder_path)
    Dates <- calculateColnames(Files,List,ini,T,T)
    ChosenDays <- as.character(str_flatten_comma(unlist(Dates)))
    
    
    if (returnDays) {    # Evaluate daily analyses
        print("RUNNING DAYLIES")
        
        ChosenDays <- unlist(strsplit(ChosenDays,","))
        GFA_DailyAnalyses <- RunDetailed(ChosenDays,Files,PotsPerGroup,numberofGroups,grps,folder_path,Conditions,ini,data_all_dailies,saveFigures,saveExcel,saveRDATA)
        GFA_DailyAnalyses <- calculateChange(GFA_DailyAnalyses,ChosenDays)
        Conditions$IsIncluded <- F
        RDATA_Path <- str_c(folder_path
                            ,"ROutput\\GFA_Analyse"
                            , ".RData")
        rm(ChosenDays)
        if (isTRUE(as.logical(saveRDATA))) {
            save(GFA_DailyAnalyses,GFA_SummaryPlot,ini,getRelative_change,getAbsolute_change,fixscient,formatPValue,file = RDATA_Path)
        }
    } else {                                            # skip and only return overview
        RDATA_Path <- str_c(folder_path
                            ,"ROutput\\GFA_Analyse"
                            , ".RData")
        if (isTRUE(as.logical(saveRDATA))) {
            save(GFA_SummaryPlot,ini,getRelative_change,getAbsolute_change,fixscient,formatPValue,file = RDATA_Path)
        }
    }
    
    Titles <- list(plot_Title=plot_Title,plot_Subtitle=plot_Subtitle, numbers=c(min(as.vector(unlist(TitleTimeSpan))), max(as.vector(unlist(TitleTimeSpan)))))
    
    rm(d,filename,folder_path,Palette_Boxplot,Palette_Lines)
    rm(Number,numberofThemes,e,ErrorString)
    rm(Group,grps,numberofGroups,PotsPerGroffup,UniqueGroups)
    rm(path)
    rm(Datesr,Files)
    rm(x_label,y_label,unit_x,unit_y,scale_y_lowerEnd,scale_y_upperEnd
       ,TitleDates,TitleTimeSpan,SortedTitleTimespan,plot_Subtitle,plot_Title
       ,Limits,
       Theme,Themes,Theme_Index,curr_Theme,curr_ThemeIndex,set_theme)
    
    rm(Colnames,Conditions)
    if (returnDays) {
        return(list(GFA_SummaryPlot,Titles,GFA_DailyAnalyses,scaleXdates,ini,RDATA_Path,getRelative_change,getAbsolute_change,formatPValue))
    } else {
        return(list(GFA_SummaryPlot,Titles,0,scaleXdates,ini,RDATA_Path,getRelative_change,getAbsolute_change,formatPValue))
    }
}
#ret <- GFA_main(r"(D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\assets\GFA_Development\GFA_Dev_Treatments\)",F,F,F,F)
#print(ret)
cat("\014") ## clear console
#remove (list=ls()) ## clear environment variables

plot_1 <- GFA_main(r"(D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\assets\Exp2.1\GFA\)",returnDays = F)
if (isTRUE(as.logical(plot_1[[5]]$General$RelativeColnames))) {
    plot_1[[1]] + geom_vline(aes(xintercept = as.integer(as.Date("31.03.2023",format="%d.%m.%Y")-as.Date(plot_1[[5]]$Experiment$T0,format="%d.%m.%Y")[[1]]))) +
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G14"),aes(xintercept = as.integer(as.Date("31.03.2023",format="%d.%m.%Y")-as.Date(plot_1[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#FC9272") +
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G21"),aes(xintercept = as.integer(as.Date("11.04.2023",format="%d.%m.%Y")-as.Date(plot_1[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#FB6A4A") + 
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G28"),aes(xintercept = as.integer(as.Date("17.04.2023",format="%d.%m.%Y")-as.Date(plot_1[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#EF3B2C") + 
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G35"),aes(xintercept = as.integer(as.Date("24.04.2023",format="%d.%m.%Y")-as.Date(plot_1[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#CB141D") +
        geom_vline(data=filter(plot_1[[1]]$data,Group=="GMax"),aes(xintercept = as.integer(as.Date("03.05.2023",format="%d.%m.%Y")-as.Date(plot_1[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#A50F15")
} else {
    plot_1[[1]] + 
        geom_vline(aes(xintercept = as.Date("31.03.2023",format="%d.%m.%Y")),linetype=1,color="black") +
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G14"),aes(xintercept = as.Date("31.03.2023",format="%d.%m.%Y")),linetype=4,color="#FC9272") +
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G21"),aes(xintercept = as.Date("11.04.2023",format="%d.%m.%Y")),linetype=4,color="#FB6A4A") + 
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G28"),aes(xintercept = as.Date("17.04.2023",format="%d.%m.%Y")),linetype=4,color="#EF3B2C") + 
        geom_vline(data=filter(plot_1[[1]]$data,Group=="G35"),aes(xintercept = as.Date("24.04.2023",format="%d.%m.%Y")),linetype=4,color="#CB141D") +
        geom_vline(data=filter(plot_1[[1]]$data,Group=="GMax"),aes(xintercept = as.Date("03.05.2023",format="%d.%m.%Y")),linetype=4,color="#A50F15")
}
#plot_1[[4]]
#plot_2 <- GFA_main(r"(D:\Dokumente neu\Obsidian NoteTaking\The Universe\200 University\06 Interns and Unis\BE28 Internship Report\assets\Exp2.3\GFA\)",F,F,F,F)
#if (isTRUE(as.logical(plot_2[[5]]$General$RelativeColnames))) {
#    plot_2[[1]] + 
#            geom_vline(aes(xintercept = as.integer(as.Date("11.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=1,color="black") +
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="Low Stress"),aes(xintercept = as.integer(as.Date("12.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#FB6A4A") + 
#            geom_vline(data=filter(plot_2[[1]]$data,Group=="Low Stress"),aes(xintercept = as.integer(as.Date("11.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#EF3B2C") + 
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress"),aes(xintercept = as.integer(as.Date("27.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#FC9272") +
#            geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress"),aes(xintercept = as.integer(as.Date("27.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#CB181D") +
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress + ABA"),aes(xintercept = as.integer(as.Date("27.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#EF3B2C") + 
#            geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress + ABA"),aes(xintercept = as.integer(as.Date("27.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#406a41") 
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="Unstressed"),aes(xintercept = as.integer(as.Date("11.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=4,color="#EF3B2C") + 
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="Unstressed"),aes(xintercept = as.integer(as.Date("11.06.2023",format="%d.%m.%Y")-as.Date(plot_2[[5]]$Experiment$T0,format="%d.%m.%Y"))),linetype=1,color="#EF3B2C") 
#} else {
#    plot_2[[1]] + 
#            geom_vline(aes(xintercept = as.Date("11.06.2023",format="%d.%m.%Y")),linetype=1,color="black") +
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="Low Stress"),aes(xintercept = as.Date("12.06.2023",format="%d.%m.%Y")),linetype=4,color="#FB6A4A") + 
#            geom_vline(data=filter(plot_2[[1]]$data,Group=="Low Stress"),aes(xintercept = as.Date("11.06.2023",format="%d.%m.%Y")),linetype=4,color="#EF3B2C") + 
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress"),aes(xintercept = as.Date("27.06.2023",format="%d.%m.%Y")),linetype=4,color="#FC9272") +
#            geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress"),aes(xintercept = as.Date("27.06.2023",format="%d.%m.%Y")),linetype=4,color="#CB181D") +
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress + ABA"),aes(xintercept = as.Date("27.06.2023",format="%d.%m.%Y")),linetype=4,color="#EF3B2C") + 
#            geom_vline(data=filter(plot_2[[1]]$data,Group=="High Stress + ABA"),aes(xintercept = as.Date("27.06.2023",format="%d.%m.%Y")),linetype=4,color="#406a41") 
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="Unstressed"),aes(xintercept = as.Date("11.06.2023",format="%d.%m.%Y")),linetype=4,color="#EF3B2C") + 
#            #geom_vline(data=filter(plot_2[[1]]$data,Group=="Unstressed"),aes(xintercept = as.Date("11.06.2023",format="%d.%m.%Y")),linetype=1,color="#EF3B2C") 
#}
#
