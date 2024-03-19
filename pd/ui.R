library(shiny)
library(htmltools)
library(ggplot2)
library(colourpicker)
library(shinyWidgets)
library(corrplot)
library(Hmisc)
library(RColorBrewer)

corrVariableDF <- data.frame(
  category=c(rep("Donor metadata",7),
             rep("Protein expression",10),
             rep("Puncta per cell", 7)),
  variable=c("Age (years)",
             "Amyloid Braak",
             "LB / a-syn Braak",
             "PD duration (years)",
             "Substantia nigra depigmentation",
             "Tau Braak",
             "CAA",
             "ALdh1L1 expression in midbrain SN", # substantia nigra
             "Aldh1L1 expression in parietal cortex",
             "Aldh1l1 expression in striatum", # striatum of basal ganglia
             "Cx43 expression in midbrain SN", # substantia nigra
             "Cx43 expression in parietal cortex",
             "Cx43 expression in striatum", # striatum of basal ganglia
             "GFAP expression in midbrain SN", # substantia nigra
             "GFAP expression in parietal cortex",
             "GFAP expression in striatum", # striatum of basal ganglia
             "Iba1 expression in parietal cortex",
             "Puncta per cell in caudate", # caudate nucleus of basal ganglia
             "Puncta per cell in globus pallidus", # globus pallidus of basal ganglia
             "Puncta per cell in putamen", # putamen of basal ganglia
             "Puncta per cell in frontal cortex",
             "Puncta per cell in insular cortex",
             "Puncta per cell in midbrain SN", # substantia nigra
             "Puncta per cell in parietal cortex"),
  stringsAsFactors = FALSE
)

continuousVariableList <- list(
  "Donor metadata"=c("Age (years)", 
                     "PD duration (years)"),
  "Protein expression"=c("ALdh1L1 expression in midbrain SN", # substantia nigra
                         "Aldh1L1 expression in parietal cortex",
                         "Aldh1l1 expression in striatum", # striatum of basal ganglia
                         "Cx43 expression in midbrain SN", # substantia nigra
                         "Cx43 expression in parietal cortex",
                         "Cx43 expression in striatum", # striatum of basal ganglia
                         "GFAP expression in midbrain SN", # substantia nigra
                         "GFAP expression in parietal cortex",
                         "GFAP expression in striatum", # striatum of basal ganglia
                         "Iba1 expression in parietal cortex"), 
  "Puncta per cell"=c("Puncta per cell in caudate", # caudate nucleus of basal ganglia
                      "Puncta per cell in globus pallidus", # globus pallidus of basal ganglia
                      "Puncta per cell in putamen", # putamen of basal ganglia
                      "Puncta per cell in frontal cortex",
                      "Puncta per cell in insular cortex",
                      "Puncta per cell in midbrain SN", # substantia nigra
                      "Puncta per cell in parietal cortex")
  )

groupingVariableList <- c("Group (PD/Control)",
                  "Aggression",
                  "Dementia / cognitive impairment",
                  "Depression",
                  "Gender",
                  "Hallucinations",
                  "LB disease type",
                  "Memory problems",
                  "Psychotic symptoms",
                  "Sleep disturbance",
                  "None"
                  )
# https://shiny.posit.co/r/articles/build/tag-glossary/

fluidPage(
  title = "Connexin 43 pathology in late-stage human Parkinson's brains.",
  titlePanel("Connexin 43 pathology in late-stage human Parkinson's brains."),
  tabsetPanel(
    id = 'dataset',
    tabPanel("About", 
             h3("Introduction"),
             p("Parkinson's (PD) is a complex condition in which multiple cell types and protein pathways are involved. Degeneration of dopaminergic neurones in the midbrains is well-described, but we as well as others discovered profound alterations in structure and function of brain cells called astrocytes. Importantly, PD-related changes can be found in multiple regions of the brain. In the present study, we looked in-depth at the network connectivity of astrocytes mediated via connexin 43 (Cx43) protein in several key brain regions."),
             imageOutput("brainImage", inline=T),
             p('Cx43 pathway is complex where this protein can exist in "protective" structures linking astrocytes in a network called gap junctions (GJs) or "disease-associated" unopposed channels called hemichannels (HCs) which open the intracellular environment to the extracellular space. This can disturb the intracellular calcium balance and cell signalling, and also trigger inflammasome activation and the release of pro-inflammatory mediators, thus affecting bystander cell types such as dopaminergic neurones.'),
             p('Our study shows profound changes in Cx43, especially in the punctate staining associated with GJs, in several brain regions - prominently in the cerebral cortex, which has been less studies in the context of PD than the midbrain. The interactive resource allows the user to explore various correlations between this new side of PD pathology and selected disease characteristics as well as non-motor PD symptoms.'),
             imageOutput("summaryImage", inline=T),
             h3("How to use this resource"),
             tags$ol(
               tags$li("A table of data for all 40 donors is displayed on the", tags$b('Select Donors'), "tab. A filter tool at the top of each column facilitates selection of donors based on the value of any variable or combination of variables."), 
               tags$li("Tools for visualizing the selected data can be found on the ", tags$b('Histogram, Boxplot, Scatterplot'), " and ", tags$b('Correlation Matrix'), " tabs."), 
             )
             ),
    tabPanel("Select donors", DT::dataTableOutput("mainTable")),
    tabPanel("Histogram", sidebarLayout(
      sidebarPanel(width=4,
        selectInput(inputId="histVar", label="Variable:", 
                    choices=continuousVariableList),
        colourInput(inputId = "histCol", label="Select colour", value="slateblue", showColour="both", palette="square", returnName=T),
        sliderInput(inputId = "histBins", label="Number of bins", min=5, max=20, value=10),
        downloadButton('downloadHistPDF', 'PDF Histogram'), 
        downloadButton('downloadHistPNG', 'PNG Histogram'),
        br(),
        br(),
        textOutput('numObsHist')
      ),
      mainPanel(
        plotOutput('histogram')
      ),
      position = c("left", "right"),
      fluid = TRUE
    )),
    tabPanel("Boxplot", sidebarLayout(
      sidebarPanel(width=4,
                   selectInput(inputId="boxplotVar", label="Variable:",
                               choices=continuousVariableList),
                   selectInput(inputId="boxplotGroup", label="Grouping variable:",
                               choices=groupingVariableList),
                   downloadButton('downloadBoxplotPDF', 'PDF Boxplot'),
                   downloadButton('downloadBoxplotPNG', 'PNG Boxplot'),
                   br(),
                   br(),
                   fluidRow(width=2, DT::dataTableOutput("boxplotDT"))
                   
                   ),
      mainPanel(
          plotOutput('boxplotPlot')
        )
      ),
    ),
    tabPanel("Scatterplot", sidebarLayout(
      sidebarPanel(width=4,
                   selectInput(inputId="xVar", label="X-axis variable:",
                               choices=continuousVariableList),
                   selectInput(inputId="yVar", label="Y-axis variable:",
                               choices=continuousVariableList),
                   selectInput(inputId="scatterplotGroup", label="Grouping variable:",
                               choices=groupingVariableList),
                   downloadButton('downloadScatterplotPDF', 'PDF Scatterplot'),
                   downloadButton('downloadScatterplotPNG', 'PNG Scatterplot'),
                   br(),
                   br(),
                   fluidRow(DT::dataTableOutput("scatterplotDT"))
                   ),
      mainPanel(
        plotOutput('scatterPlot')
      ),
    )),
    tabPanel("Correlation Matrix", sidebarLayout(
      sidebarPanel(width=3,
                   treeInput(
                     inputId = "corMatVars",
                     label = "Select variables:",
                     choices = create_tree(corrVariableDF),
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
