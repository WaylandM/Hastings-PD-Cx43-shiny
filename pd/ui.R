fluidPage(
  title = "Neuropathology of Parkinson's patients vs controls.",
  titlePanel("Neuropathology of Parkinson's disease"),
  tabsetPanel(
    id = 'dataset',
    tabPanel("About", p("p creates a paragraph of text."),
             p("A new p() command starts a new paragraph. Supply a style attribute to change the format of the entire paragraph.", style = "font-family: 'times'; font-si16pt"),
             strong("strong() makes bold text."),
             em("em() creates italicized (i.e, emphasized) text."),
             br(),
             code("code displays your text similar to computer code"),
             div("div creates segments of text with a similar style. This division of text is all blue because I passed the argument 'style = color:blue' to div", style = "color:blue"),
             br(),
             p("span does the same thing as div, but it works with",
               span("groups of words", style = "color:blue"),
               "that appear inside a paragraph."),
             a(href="http://www.google.com", "link to Google"),
             strong(textOutput('numDonors'))),
    tabPanel("Data table", DT::dataTableOutput("mainTable")),
    tabPanel("Histogram", sidebarLayout(
      sidebarPanel(
        selectInput(inputId="histVar", label="Variable:", 
                    choices=list("Donor Metadata"=c("Age (years)", 
                                                    "PD duration (years)"),
                                 "Protein Expression"=c("ALdh1L1 expression in substantia nigra",
                                                        "Aldh1L1 expression in parietal cortex",
                                                        "Aldh1l1 expression in striatum of basal ganglia",
                                                        "Cx43 expression in substantia nigra",
                                                        "Cx43 expression in parietal cortex",
                                                        "Cx43 expression in striatum of basal ganglia",
                                                        "GDNF expression in substantia nigra",
                                                        "GDNF expression in parietal cortex",
                                                        "GDNF expression in striatum of basal ganglia",
                                                        "GFAP expression in substantia nigra",
                                                        "GFAP expression in parietal cortex",
                                                        "GFAP expression in striatum of basal ganglia"),
                                 "Puncta per cell"=c("Puncta per cell in caudate nucleus of basal ganglia",
                                                     "Puncta per cell in globus pallidus of basal ganglia",
                                                     "Puncta per cell in putamen of basal ganglia",
                                                     "Puncta per cell in frontal cortex",
                                                     "Puncta per cell in insular cortex",
                                                     "Puncta per cell in substantia nigra",
                                                     "Puncta per cell in parietal cortex"))),
        colourInput(inputId = "histCol", label="Select colour", value="slateblue", showColour="both", palette="square", returnName=T),
        sliderInput(inputId = "histBins", label="Number of bins", min=5, max=20, value=10),
        downloadButton('downloadHistPDF', 'PDF Histogram'), 
        downloadButton('downloadHistPNG', 'PNG Histogram')
      ),
      mainPanel(
        plotOutput('histogram')
      ),
      position = c("left", "right"),
      fluid = TRUE
    )),
    tabPanel("Boxplot"),
    tabPanel("Scatterplot"),
    tabPanel("Correlation Matrix", sidebarLayout(
      sidebarPanel(),
      mainPanel(),
      position=c("left", "right"),
      fluid = TRUE
    ))
    )
  )
