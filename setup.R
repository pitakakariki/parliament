
load("data/data.Rda")

#
# Party names, colours etc
#

parties <- read.table(header=TRUE, row.names = "Party", stringsAsFactors = FALSE, comment="",
    text = "
    Party           Colour   Contrast
    National        #00529F  #CCDDFF
    Labour          #FF0000  #FFBAA8
    'NZ First'      #000000  #CCCCCC
    Green           #098137  #B3FFB3
    Maori           #EF4A42  #FFCC80
    ACT             #FFE401  #FFFF80
    'United Future' #501557  #DD99DD
    TOP             #FF0000  #0000FF
    Mana            #770808  #FF6E6E
    ")

parties$Lname <- names(L)[c(11,8,12,6,10,1,16,15,9)]
parties$Cname <- unique(C$Party)[c(5,8,1,6,9,7,10,3,20)]

parties$Vote <- c(46.0, 35.8, 7.5, 5.9, 1.1, 0.5, 0.1, 2.2, 0.1)

row.names(parties)[5] <- "M\u0101ori"
#parties[c(5,7,8,9), ] <- NULL

partyNames <- row.names(parties)

#
# Default electorate selections - incumbents, candidates replacing incumbents, most likely winner etc.
#

default <- c(7,15,21,31,39,47,52,56,64,77, 85,92,94,101,113,118,127,134,144,154,
    161,165,178,187,196,198,206,223,229,239, 246,256,258,266,273,284,289,295,303,308,
    312,320,327,333,342,346,357,362,374,378, 386,389,405,414,417,425,429,443,446,455, 469,475,485,496,
    498,503,506,510,514,521,524)
stopifnot(length(default)==71)
default <- default - (1:71) - 1

C$Winner <- FALSE
C$Winner[default] <- TRUE

C <- subset(C, Party %in% parties$Cname)
C$Party <- row.names(parties)[match(C$Party, parties$Cname)]

source("apportion.R")
source("housePlot.R")



