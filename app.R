library(shiny)

source("setup.R")

voteWidgets <- list()

colStyle <- "display: flex; flex-direction: column; justify-content: center;"
rowStyle <- "display: flex; flex-direction: rtl; justify-content: center;"

rcolumn <- function(width, ...) column(width, ..., style=paste(colStyle, "text-align: right;"))
lcolumn <- function(width, ...) column(width, ..., style=paste(colStyle, "text-align: left;"))

for (i in seq_len(nrow(parties))) {

    this.party <- row.names(parties)[i]

    voteWidgets[[this.party]] <- fluidRow(

        rcolumn(4, strong(this.party)),
        rcolumn(3, numericInput(paste0("votes", i), "", parties$Vote[i], 0, 100, 1)),
        rcolumn(2, uiOutput(paste0("electorates", i))),
        rcolumn(2, uiOutput(paste0("total", i))),
        style=rowStyle
    )
}


ui <- fluidPage(

    titlePanel("New Zealand Parliament 2017"),

    fluidRow(

        column(6, wellPanel(
            h3("Party Votes"),

            fluidRow(
                lcolumn(4),
                lcolumn(3, h6(strong("Votes"))),
                lcolumn(2, h6(strong("Electorates"), align="right")),
                lcolumn(2, h6(strong("Total"), align="right")),
                style=rowStyle
            ),

            voteWidgets,

            fluidRow(

                rcolumn(7),
                rcolumn(2, uiOutput("electoratesTotal")),
                rcolumn(2, uiOutput("total")),
                style=rowStyle
            )
        )),

        column(6, wellPanel(h3("Seats in Parliament"), plotOutput("housePlot"), textOutput("test")))
    )





)

server <- function(input, output, session) {

    candidates <- reactive(C)

    votes <- reactive({

        rval <- sapply(seq_along(partyNames), function(i) input[[paste0("votes", i)]])
        names(rval) <- partyNames

        rval
    })

    electorateSeats <- reactive(

        tapply(candidates()$Winner, candidates()$Party, sum)[partyNames]
    )

    totalSeats <- reactive({

        v <- votes()
        s <- electorateSeats()

        x <- ifelse(v < 5 & s < 1, 0, v)
        pmax(SainteLague(x), s)
    })

    for(i in seq_along(partyNames)) {

        output[[paste0("electorates", i)]] <- eval(
            substitute(
                renderText(electorateSeats()[x]),
                list(x=partyNames[i])
            )
        )
    }

    for(i in seq_along(partyNames)) {

        output[[paste0("total", i)]] <- eval(
            substitute(
                renderText(totalSeats()[x]),
                list(x=i)
            )
        )
    }

    output$housePlot <- renderPlot(housePlot(totalSeats()))

    output$electoratesTotal <- renderUI(strong(sum(electorateSeats())))
    output$total <- renderUI(strong(sum(totalSeats())))

    #output$test <- renderText(totalSeats())

    session$onSessionEnded(stopApp)
}

shinyApp(ui, server)
