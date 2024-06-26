library(shiny)
library(htmltools)
library(ggplot2)
library(colourpicker)
library(shinyWidgets)
library(corrplot)
library(Hmisc)
library(RColorBrewer)

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

dat$GDNF.MidSN <- NULL
dat$GDNF.ParCort <- NULL
dat$GDNF.StriBG <- NULL

names(dat)[1] <- "Group (PD/Control)"
names(dat)[2] <- "ID"
names(dat)[3] <- "Brain Bank ID"
names(dat)[4] <- "Age (years)"
# 5: Aggression (doesn't need renaming)
names(dat)[6] <- "Amyloid Braak"
names(dat)[7] <- "Dementia / cognitive impairment"
# 8-10: Depression, Gender, Hallucinations
names(dat)[11] <- "LB / a-syn Braak"
names(dat)[12] <- "LB disease type"
names(dat)[13] <- "Memory problems"
names(dat)[14] <- "PD duration (years)"
names(dat)[15] <- "Psychotic symptoms"
names(dat)[16] <- "Sleep disturbance"
names(dat)[17] <- "Substantia nigra depigmentation"
names(dat)[18] <- "Tau Braak"
names(dat)[19] <- "CAA"

names(dat)[20] <- "ALdh1L1 expression in midbrain SN" # substantia nigra
names(dat)[21] <- "Aldh1L1 expression in parietal cortex"
names(dat)[22] <- "Aldh1l1 expression in striatum" # striatum of basal ganglia
names(dat)[23] <- "Cx43 expression in midbrain SN" # substantia nigra
names(dat)[24] <- "Cx43 expression in parietal cortex"
names(dat)[25] <- "Cx43 expression in striatum" # striatum of basal ganglia
names(dat)[26] <- "GFAP expression in midbrain SN" # substantia nigra
names(dat)[27] <- "GFAP expression in parietal cortex"
names(dat)[28] <- "GFAP expression in striatum" # striatum of basal ganglia
names(dat)[29] <- "Iba1 expression in parietal cortex"

names(dat)[30] <- "Puncta per cell in caudate" # caudate nucleus of basal ganglia
names(dat)[31] <- "Puncta per cell in globus pallidus" # globus pallidus of basal ganglia
names(dat)[32] <- "Puncta per cell in putamen" # putamen of basal ganglia
names(dat)[33] <- "Puncta per cell in frontal cortex"
names(dat)[34] <- "Puncta per cell in insular cortex"
names(dat)[35] <- "Puncta per cell in midbrain SN" # substantia nigra
names(dat)[36] <- "Puncta per cell in parietal cortex"

continuousVars <- c("Age (years)", 
                    "PD duration (years)", 
                    "ALdh1L1 expression in midbrain SN", # substantia nigra
                    "Aldh1L1 expression in parietal cortex",
                    "Aldh1l1 expression in striatum", # striatum of basal ganglia
                    "Cx43 expression in midbrain SN", # substantia nigra
                    "Cx43 expression in parietal cortex",
                    "Cx43 expression in striatum of basal ganglia", # striatum of basal ganglia
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
                    "Puncta per cell in parietal cortex")

#function(input, output) {
shinyServer(function(input, output, session) {
  
  output$mainTable <- DT::renderDataTable({
    DT::datatable(dat, extensions='Buttons', options = list(lengthMenu = c(10, 20, 40), pageLength = 40, dom = 'Bfrtip',
                                                            buttons = c('copy', 'csv', 'excel')), rownames=F, filter="top")
  })
  
  idxFilt <- reactive({input$mainTable_rows_all})
  
  # firstFilter$i is an index to keep track of the number of times datFilt is called
  # we create a new environment to pass firstFilter by reference rather than value
  firstFilter = new.env()
  firstFilter$i = 0
  datFilt <- reactive({
    if (is.null(idxFilt()) & firstFilter$i<1){
      datFilt <- dat
    } else {
      datFilt <- dat[idxFilt(),]
    }
    firstFilter$i = firstFilter$i+1
    return(datFilt)
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
  
  numObsHist <- reactive({
    dFilt <- datFilt()
    eval(parse(text=paste("sum(!is.na(dFilt$'", input$histVar,"'))",sep="")))
  })
  
  output$numObsHist<-reactive({paste("Number of observations:", numObsHist(), sep=" ")})
  
  output$downloadHistPDF <- downloadHandler(
    filename = function() { paste("Histogram of ", input$histVar, '.pdf', sep='') },
    content = function(file) {
      ggsave(file, plot = histoPlot(), device = "pdf", units="mm", width=180, height=120)
    }
  )
  
  output$downloadHistPNG <- downloadHandler(
    filename = function() { paste("Histogram of ", input$histVar, '.png', sep='') },
    content = function(file) {
      ggsave(file, plot = histoPlot(), device = "png", bg = 'white', units="mm", width=180, height=120)
    }
  )
  
  boxplotPlot <- reactive({
    dFilt <- datFilt()
    dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$boxplotVar,"')", sep=""))),]
    
    if(input$boxplotGroup=="None"){
      ggplot(data=dFilt, aes(y=get(input$boxplotVar))) +
        geom_boxplot(outlier.size=5, fill=brewer.pal(6,"Dark2")[6]) + theme_minimal() +
        theme(legend.position="none") + theme(axis.title.x = element_text(size = rel(2), margin = margin(t = 20, r = 0, b = 0, l = 0)),
                                              axis.text.x = element_text(size = rel(2.5)),
                                              axis.title.y = element_text(size = rel(2), margin = margin(t = 0, r = 20, b = 0, l = 0)),
                                              axis.text.y = element_text(size = rel(2.5))) +
        labs(x="", y=input$boxplotVar)
      }else{
        dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$boxplotGroup,"')", sep=""))),]
        ggplot(data=dFilt, aes(x=get(input$boxplotGroup), y=get(input$boxplotVar), fill=get(input$boxplotGroup))) +
          geom_boxplot(outlier.size=5) + scale_fill_brewer(palette="Dark2") + theme_minimal() +
          theme(legend.position="none") + theme(axis.title.x = element_text(size = rel(2), margin = margin(t = 20, r = 0, b = 0, l = 0)),
                                                axis.text.x = element_text(size = rel(2.5)),
                                                axis.title.y = element_text(size = rel(2), margin = margin(t = 0, r = 20, b = 0, l = 0)),
                                                axis.text.y = element_text(size = rel(2.5))) +
          labs(x=input$boxplotGroup, y=input$boxplotVar)
  }})
  
  output$boxplotPlot <- renderPlot({print(boxplotPlot())}, height=600)
  
  boxplotDF <- reactive({
    dFilt <- datFilt()
    dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$boxplotVar,"')", sep=""))),]
    
    if(input$boxplotGroup=="None"){
      Category="None"
      #Count=eval(parse(text=paste("sum(!is.na(datFiltNoNA$'", input$boxplotVar,"'))",sep="")))
      Count=dim(dFilt)[1]
      data.frame(cbind(Category, Count))
    }else{
      dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$boxplotGroup,"')", sep=""))),]
      #datFiltNoNA <- datFiltNoNA[eval(parse(text=paste("!is.na(datFiltNoNA$'",input$boxplotVar,"')",sep=""))),]
      #bpDF <- as.data.frame(xtabs(~get(input$boxplotGroup), datFiltNoNA, addNA=T, na.action = NULL))
      bpDF <- as.data.frame(xtabs(~get(input$boxplotGroup), dFilt))
      names(bpDF) <- c("Category", "Count")
      bpDF
    }
  })
  
  output$boxplotDT <- DT::renderDataTable({DT::datatable(boxplotDF(), options = list(info = FALSE, paging = FALSE, searching = FALSE))})
  
  output$downloadBoxplotPDF <- downloadHandler(
    filename = function() { paste("Boxplot of ", input$boxplotVar, " grouped by ", input$boxplotGroup, ".pdf", sep='') },
    content = function(file) {
      ggsave(file, plot = boxplotPlot(), device = "pdf", units="mm", width=320, height=240)
    }
  )
  
  output$downloadBoxplotPNG <- downloadHandler(
    filename = function() { paste("Boxplot of ", input$boxplotVar, " grouped by ", input$boxplotGroup, ".png", sep='') },
    content = function(file) {
      ggsave(file, plot = boxplotPlot(), device = "png", bg = 'white', units="mm", width=320, height=240)
    }
  )
  
  scatterPlot <- reactive({
    dFilt <- datFilt()
    dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$xVar,"') & !is.na(dFilt$'", input$yVar, "')", sep=""))),]
    
    if(input$scatterplotGroup=="None"){
      ggplot(data=dFilt, aes(x=get(input$xVar), y=get(input$yVar))) +
        geom_point(fill=brewer.pal(6,"Dark2")[6]) + theme_minimal() +
        theme(axis.title.x = element_text(size = rel(2), margin = margin(t = 20, r = 0, b = 0, l = 0)),
              axis.text.x = element_text(size = rel(2.5)),
              axis.title.y = element_text(size = rel(2), margin = margin(t = 0, r = 20, b = 0, l = 0)),
              axis.text.y = element_text(size = rel(2.5))) +
        labs(x=input$xVar, y=input$yVar)
      }else{
        dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$scatterplotGroup,"')", sep=""))),]
        ggplot(data=dFilt, aes(x=get(input$xVar), y=get(input$yVar), color=get(input$scatterplotGroup), shape=get(input$scatterplotGroup))) + 
          geom_point(size=5) + theme_minimal() + scale_color_brewer(palette="Dark2") + 
          guides(color = guide_legend(title=input$scatterplotGroup), shape=guide_legend(title=input$scatterplotGroup)) +
          theme(axis.title.x = element_text(size = rel(2), margin = margin(t = 20, r = 0, b = 0, l = 0)),
                axis.text.x = element_text(size = rel(2.5)),
                axis.title.y = element_text(size = rel(2), margin = margin(t = 0, r = 20, b = 0, l = 0)),
                axis.text.y = element_text(size = rel(2.5)),
                legend.title = element_text(size=rel(2)),
                legend.text = element_text(size=rel(2))) +
          labs(x=input$xVar, y=input$yVar)
        }})
  
  output$scatterPlot <- renderPlot({print(scatterPlot())}, height=600)
  
  scatterplotDF <- reactive({
    dFilt <- datFilt()
    dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$xVar,"') & !is.na(dFilt$'", input$yVar, "')", sep=""))),]
    
    if(input$scatterplotGroup=="None"){
      Category="None"
      Count=dim(dFilt)[1]
      data.frame(cbind(Category, Count))
    }else{
      dFilt <- dFilt[eval(parse(text=paste("!is.na(dFilt$'", input$scatterplotGroup,"')", sep=""))),]
      spDF <- as.data.frame(xtabs(~get(input$scatterplotGroup), dFilt))
      names(spDF) <- c("Category", "Count")
      spDF
    }
  })
  
  output$scatterplotDT <- DT::renderDataTable({DT::datatable(scatterplotDF(), options = list(info = FALSE, paging = FALSE, searching = FALSE))})
  
  output$downloadScatterplotPDF <- downloadHandler(
    filename = function() { paste("Scatterplot of ", input$xVar, " vs ", input$yVar, " labelled by ", input$scatterplotGroup, ".pdf", sep='') },
    content = function(file) {
      ggsave(file, plot = scatterPlot(), device = "pdf", units="mm", width=320, height=240)
    }
  )
  
  output$downloadScatterplotPNG <- downloadHandler(
    filename = function() { paste("Scatterplot of ", input$xVar, " vs ", input$yVar, " labelled by ", input$scatterplotGroup, ".png", sep='') },
    content = function(file) {
      ggsave(file, plot = scatterPlot(), device = "png", bg = 'white', units="mm", width=320, height=240)
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
    filename = "Correlation_plot.pdf",
    content = function(file) {
      pdf(file, width=10, height=10, title="Correlation Plot")
      cms <- corMatSpearman()
      corrplot(cms$r, method="circle")
      dev.off()
    }
  )
  
  output$downloadCorPlotPNG <- downloadHandler(
    filename = "Correlation_plot.png",
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
  
  
  output$brainImage <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    #filename <- normalizePath(file.path('./images', paste('image', input$n, '.jpeg', sep='')))
    imgFilename = "images/brain_scheme_PD.png"
    
    # Return a list containing the filename and alt text
    list(src = imgFilename,
         alt = "Brain regions studied")
    
  }, deleteFile = FALSE)
  
  
  output$summaryImage <- renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    #filename <- normalizePath(file.path('./images', paste('image', input$n, '.jpeg', sep='')))
    imgFilename = "images/Cx43_in_PD_summary_small.png"
    
    # Return a list containing the filename and alt text
    list(src = imgFilename,
         alt = "Brain regions studied")
    
  }, deleteFile = FALSE)
  
  #observe({
  #print(input[["corMatVars"]])
  #print(is.element(names(dat), input[["corMatVars"]]))
  #})
  
}
)

