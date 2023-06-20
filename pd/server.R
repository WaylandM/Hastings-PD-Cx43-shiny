library(shiny)
library(ggplot2)

function(input, output) {
  
  dat <- read.csv("data/data.csv", row.names=1)
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
  output$mainTable <- DT::renderDataTable({
    DT::datatable(dat, extensions='Buttons', options = list(lengthMenu = c(10, 20, 40), pageLength = 40, dom = 'Bfrtip',
                                      buttons = c('copy', 'csv', 'excel', 'pdf', 'print')), rownames=F, filter="top")
  })
  
  
  
}

