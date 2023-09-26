library(shiny)
library(htmltools)
library(ggplot2)
library(colourpicker)
library(shinyWidgets)
library(corrplot)
library(Hmisc)

#donorVariableList

cities <- data.frame(
  continent = c("America", "America", "America", "Africa",
                "Africa", "Africa", "Africa", "Africa",
                "Europe", "Europe", "Europe", "Antarctica"),
  country = c("Canada", "Canada", "USA", "Tunisia", "Tunisia",
              "Tunisia", "Algeria", "Algeria", "Italy", "Germany", "Spain", NA),
  city = c("Trois-Rivières", "Québec", "San Francisco", "Tunis",
           "Monastir", "Sousse", "Alger", "Oran", "Rome", "Berlin", "Madrid", NA),
  stringsAsFactors = FALSE
)

continuousVariableDF <- data.frame(
  category=c(rep("Donor metadata",2),
             rep("Protein expression",12),
             rep("Puncta per cell", 7)),
  variable=c("Age (years)",
             "PD duration (years)",
             "ALdh1L1 expression in substantia nigra",
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
             "GFAP expression in striatum of basal ganglia",
             "Puncta per cell in caudate nucleus of basal ganglia",
             "Puncta per cell in globus pallidus of basal ganglia",
             "Puncta per cell in putamen of basal ganglia",
             "Puncta per cell in frontal cortex",
             "Puncta per cell in insular cortex",
             "Puncta per cell in substantia nigra",
             "Puncta per cell in parietal cortex"),
  stringsAsFactors = FALSE
)

continuousVariableList <- list(
  "Donor metadata"=c("Age (years)", 
                     "PD duration (years)"),
  "Protein expression"=c("ALdh1L1 expression in substantia nigra",
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
                      "Puncta per cell in parietal cortex"),
  stringsAsFactors = FALSE)

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
      sidebarPanel(width=4,
        selectInput(inputId="histVar", label="Variable:", 
                    choices=continuousVariableList),
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
      sidebarPanel(width=3,
                   treeInput(
                     inputId = "corMatVars",
                     label = "Select variables:",
                     choices = create_tree(continuousVariableDF),
                     selected = c("Donor metadata", "Protein expression", "Puncta per cell"),
                     returnValue = "text",
                     closeDepth = 0),
                   downloadButton('downloadCorPlotPDF', 'PDF Correlation Plot'), 
                   downloadButton('downloadCorPlotPNG', 'PNG Correlation Plot'),
                   br(),
                   br(),
                   downloadButton('downloadR', 'Correlation Coefficient'),
                   downloadButton('downloadP', 'Correlation P-value'),
                   br(),
                   br(),
                   downloadButton('downloadN', 'Number of observations')
                   ),
      
      mainPanel(
        plotOutput('corMat')
      ),
      position=c("left", "right"),
      fluid = TRUE
    )),

    )
  )
