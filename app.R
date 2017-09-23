library(shiny)

source("setup.R")

voteWidgets <- list()

for (i in seq_len(nrow(parties))) {

    this.party <- row.names(parties)[i]

    voteWidgets[[this.party]] <- fluidRow(

        column(4, div(strong(this.party), style="text-align:right; vertical-align:middle")),
        column(3, numericInput(this.party, "", parties$Vote[i], 0, 100, 1)),
        column(2, uiOutput(paste0("electorates", this.party))),
        column(2, uiOutput(this.party))
    )
}


ui <- fluidPage(

    titlePanel("New Zealand Parliament 2017"),

    fluidRow(

        column(6, wellPanel(
            h3("Party Votes"),

            fluidRow(
                column(4),
                column(3, h6("Votes")),
                column(2, h6("Electorates", align="right")),
                column(2, h6("Total", align="right"))
            ),

            voteWidgets,

            fluidRow(

                column(7),
                column(2, uiOutput("electoratesTotal")),
                column(2, uiOutput("Total"))
            )
        )),

        column(6, wellPanel(h3("Seats in Parliament"), plotOutput("housePlot"), textOutput("test")))
    )





)

server <- function(input, output) {

    candidates <- reactive(C)

    votes <- reactive(sapply(partyNames, function(x) input[[x]]))

    electorateSeats <- reactive(

        tapply(candidates()$Winner, candidates()$Party, sum)[partyNames]
    )

    totalSeats <- reactive({

        v <- votes()
        s <- electorateSeats()

        x <- ifelse(v < 5 & s < 1, 0, v)
        pmax(SainteLague(x), s)
    })

    for(this.party in partyNames) {

        output[[paste0("electorates", this.party)]] <- eval(
            substitute(
                renderText(electorateSeats()[x]),
                list(x=this.party)
            )
        )
    }

    for(this.party in partyNames) {

        output[[this.party]] <- eval(
            substitute(
                renderText(totalSeats()[x]),
                list(x=this.party)
            )
        )
    }

    output$housePlot <- renderPlot(housePlot(totalSeats()))

    output$test <- renderText(totalSeats())


}

shinyApp(ui, server)
