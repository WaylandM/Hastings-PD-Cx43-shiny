library(shiny)
library(htmltools)
library(ggplot2)
library(colourpicker)
library(shinyWidgets)
library(corrplot)
library(Hmisc)

dat <- read.csv("data/data.csv", row.names=1)
dat$Group <- as.factor(dat$Group)
dat$Dementia...cognitive.impairment <- as.factor(dat$Dementia...cognitive.impairment)
dat$Depression <- factor(dat$Depression)
dat$Memory.problems <- as.factor(dat$Memory.problems)
dat$Sleep.disturbance <- as.factor(dat$Sleep.disturbance)
dat$Aggression <- as.factor(dat$Aggression)
dat$Hallucinations <- as.factor(dat$Hallucinations)
dat$Psychotic.symptoms <- as.factor(dat$Psychotic.symptoms)
dat$LB.disease.type <- factor(dat$LB.disease.type)
dat$LB.Braak.stage <- factor(dat$LB.Braak.stage, ordered=TRUE)
dat$SN.depigmentation <- factor(dat$SN.depigmentation, ordered=TRUE)
dat$Amyloid.pathology <- factor(dat$Amyloid.pathology, ordered=TRUE)
dat$Tau.pathology <- factor(dat$Tau.pathology, ordered=TRUE)
dat$Vessel.disease...CAA <- factor(dat$Vessel.disease...CAA, ordered=TRUE)
dat$Age <- as.numeric(dat$Age)
dat$PD.duration <- as.numeric(dat$PD.duration)
dat$Gender <- as.factor(dat$Gender)

names(dat)[2] <- "Brain Bank ID"
names(dat)[3] <- "Age (years)"
names(dat)[5] <- "Amyloid pathology"
names(dat)[6] <- "Dementia / cognitive impairment"
names(dat)[10] <- "LB Braak stage"
names(dat)[11] <- "LB disease type"
names(dat)[12] <- "Memory problems"
names(dat)[13] <- "PD duration (years)"
names(dat)[14] <- "Psychotic symptoms"
names(dat)[15] <- "Sleep disturbance"
names(dat)[16] <- "Substantia nigra depigmentation"
names(dat)[17] <- "Tau pathology"
names(dat)[18] <- "Vessel disease / cerebral amyloid angiopathy"

names(dat)[19] <- "ALdh1L1 expression in substantia nigra"
names(dat)[20] <- "Aldh1L1 expression in parietal cortex"
names(dat)[21] <- "Aldh1l1 expression in striatum of basal ganglia"
names(dat)[22] <- "Cx43 expression in substantia nigra"
names(dat)[23] <- "Cx43 expression in parietal cortex"
names(dat)[24] <- "Cx43 expression in striatum of basal ganglia"
names(dat)[25] <- "GDNF expression in substantia nigra"
names(dat)[26] <- "GDNF expression in parietal cortex"
names(dat)[27] <- "GDNF expression in striatum of basal ganglia"
names(dat)[28] <- "GFAP expression in substantia nigra"
names(dat)[29] <- "GFAP expression in parietal cortex"
names(dat)[30] <- "GFAP expression in striatum of basal ganglia"

names(dat)[31] <- "Puncta per cell in caudate nucleus of basal ganglia"
names(dat)[32] <- "Puncta per cell in globus pallidus of basal ganglia"
names(dat)[33] <- "Puncta per cell in putamen of basal ganglia"
names(dat)[34] <- "Puncta per cell in frontal cortex"
names(dat)[35] <- "Puncta per cell in insular cortex"
names(dat)[36] <- "Puncta per cell in substantia nigra"
names(dat)[37] <- "Puncta per cell in parietal cortex"

continuousVars <- c("Age (years)", 
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
                    "Puncta per cell in parietal cortex")

#function(input, output) {
shinyServer(function(input, output, session) {

  output$mainTable <- DT::renderDataTable({
    DT::datatable(dat, extensions='Buttons', options = list(lengthMenu = c(10, 20, 40), pageLength = 40, dom = 'Bfrtip',
                                      buttons = c('copy', 'csv', 'excel')), rownames=F, filter="top")
  })
  
  idxFilt <- reactive({input$mainTable_rows_all})
  
  datFilt <- reactive({
    if (is.null(idxFilt())){
      datFilt <- dat
    } else {
      datFilt <- dat[idxFilt(),]
    }
  })
  
  numDonors <- reactive({dim(datFilt())[1]})

  output$numDonors<-reactive({paste("Number of donors:", numDonors(), sep=" ")})
  
  histoPlot <- reactive({ggplot(data=datFilt(), aes(x=get(input$histVar))) + 
                                   geom_histogram(bins=input$histBins, fill=input$histCol) +
      theme_minimal() +
      theme(axis.title.x = element_text(size = rel(2)),
            axis.text.x = element_text(size = rel(2.5)),
            axis.title.y = element_text(size = rel(2)),
            axis.text.y = element_text(size = rel(2.5))) +
      labs(x=input$histVar, y="Count")})
  
  output$histogram <- renderPlot({print(histoPlot())}, height=600)
  
  #output$histogram <- renderPlot({print(histInput())})
  
  output$downloadHistPDF <- downloadHandler(
    filename = function() { paste("histogram ", input$histVar, '.pdf', sep='') },
    content = function(file) {
      ggsave(file, plot = histoPlot(), device = "pdf", units="mm", width=180, height=120)
    }
  )
  
  output$downloadHistPNG <- downloadHandler(
    filename = function() { paste("histogram ", input$histVar, '.png', sep='') },
    content = function(file) {
      ggsave(file, plot = histoPlot(), device = "png", bg = 'white', units="mm", width=180, height=120)
    }
  )
  
  corMatSpearman <- reactive({
    rcorr(as.matrix(datFilt()[,is.element(names(dat), input[["corMatVars"]])]), type="spearman")
  })
  
  corMatPlot <- reactive({
    cms <- corMatSpearman()
    corrplot(cms$r, method="circle")
  })
  
  output$corMat <- renderPlot({print(corMatPlot())}, height=600)
  
  output$downloadCorPlotPDF <- downloadHandler(
    filename = "correlation_plot.pdf",
    content = function(file) {
      pdf(file, width=10, height=10, title="Correlation Plot")
      cms <- corMatSpearman()
      corrplot(cms$r, method="circle")
      dev.off()
    }
  )
  
  output$downloadCorPlotPNG <- downloadHandler(
    filename = "correlation_plot.png",
    content = function(file) {
      png(file, res=1000, units="mm", width=250, height=250)
      corMatSpearman <- rcorr(as.matrix(datFilt()[,is.element(names(dat), input[["corMatVars"]])]), type="spearman")
      corrplot(corMatSpearman$r, method="circle")
      dev.off()
    }
  )
  
  
  output$downloadR <- downloadHandler(
    filename = "Spearmans_correlation_coefficient.csv",
    content = function(file) {
      cms <- corMatSpearman()
      write.csv(cms$r, file, row.names=T, quote=F)
    }
  )
  
  output$downloadP <- downloadHandler(
    filename = "Spearmans_correlation_p-value.csv",
    content = function(file) {
      cms <- corMatSpearman()
      write.csv(cms$P, file, row.names=T, quote=F)
    }
  )
  
  output$downloadN <- downloadHandler(
    filename = "Spearmans_correlation_number_observations.csv",
    content = function(file) {
      cms <- corMatSpearman()
      write.csv(cms$n, file, row.names=T, quote=F)
    }
  )
  
  
  
  #observe({
    #print(input[["corMatVars"]])
    #print(is.element(names(dat), input[["corMatVars"]]))
  #})
  
}
)

