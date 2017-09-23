#
# Clean up the excel files
#

library(readxl)

fixnames <- function(x) {

    y <- tolower(x)

    # capitalise first letter
    substr(y, 1, 1) <- toupper(substr(y, 1, 1))

    # first letter after _, -, O', Mc, Mac.
    y <- gsub("( |-|O'|Mc|Mac)([a-z])", "\\1\\U\\2", y, perl=TRUE)

    # van, de, etc
    y <- gsub("^De", "de", y)
    y <- gsub("^Van De", "van de", y)
    y <- gsub("^Van ", "van ", y)

    return(y)
}

#test <- fixnames(x)[c(13,30,130,149,152,185,191,213,247,368,482,470,7,390)]
#print(test)

#
# Party Lists
#

lists <- read_xlsx("data/2017_party_lists.xlsx")

partyIndex <- which(is.na(suppressWarnings(as.numeric(lists$Rank))))
names(partyIndex) <- partyNames <- lists$Rank[partyIndex]
partyIndex <- c(partyIndex, nrow(lists)+1)

fPartyList <- function(name) {

    i <- match(name, partyNames)

    a <- partyIndex[i]+1
    b <- partyIndex[i+1]-1

    lists$Candidate[seq(a, b)]
}

L <- sapply(partyNames, fPartyList)


#
# Electorate Candidates
#

candidates <- read_xlsx("data/2017_electorate_candidates.xlsx")

names(candidates)[c(1,2)] <- c("V1", "Electorate")

electorate <- candidates$Electorate[1]
for(i in seq_len(nrow(candidates))) {

    if(is.na(candidates$Electorate[i])) candidates$Electorate[i] <- electorate
}

candidates <- subset(candidates, is.na(V1))
candidates$V1 <- NULL

candidates$Name <- paste(candidates$`First names`, fixnames(candidates$`Last name`))
candidates$`First names` <- NULL
candidates$`Last name` <- NULL

C <- as.data.frame(candidates)

save(L, C, file="data/data.Rda")


