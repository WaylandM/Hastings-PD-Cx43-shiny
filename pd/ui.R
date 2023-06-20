fluidPage(
  title = "Neuropathology of Parkinson's patients vs controls.",
  titlePanel("Neuropathology of Parkinson's disease"),
  tabsetPanel(
    id = 'dataset',
    tabPanel("About", p("paragraph of text", strong("some bold text"))),
    tabPanel("Data table", DT::dataTableOutput("mainTable")),
    tabPanel("Histogram"),
    tabPanel("Boxplot"),
    tabPanel("Scatterplot"),
    tabPanel("Correlation Matrix")
    )
  )
