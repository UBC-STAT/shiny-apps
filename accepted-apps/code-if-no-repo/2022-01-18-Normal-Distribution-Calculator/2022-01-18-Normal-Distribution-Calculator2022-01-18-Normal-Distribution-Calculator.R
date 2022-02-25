#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

# Define UI for application that draws a histogram
ui <- fluidPage(
  #actionButton("browser", "browser"),
  tags$head(
    tags$style(type="text/css", "label{ display: table-cell; text-align: center; vertical-align: middle; } .form-group { display: table-row;}")
  ),
  tags$hr(style="border-color: purple;"),
  
  # Application title
  titlePanel("Normal Distribution App"),
  h5("Created by Ian Murphy"),

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      
      textAreaInput("mean",
                withMathJax("$$ \\text{(Mean)} \\;\\;\\; \\mu = \\;$$"),
                width = "40%",
                height = "30px",
                resize = "none",
                value = 0),
      
      textAreaInput("sd",
                withMathJax("$$\\text{(Std.Dev.)} \\;\\;\\;\\sigma = \\;$$"),
                width = "40%",
                height = "30px",
                resize = "none",
                value = 1),
      
      tabsetPanel(id = "tab",
                  type = "tabs",
                  tabPanel(title = "Probability",
                           value = "ComputeProbability",
                           textAreaInput("xval",
                                     withMathJax("$$x = \\;$$"),
                                     width = "40%",
                                     height = "30px",
                                     resize = "none",
                                     value = 0),
                           selectInput("prob", "",
                                       choices = list("P(X > x)" = 1,
                                                      "P(X < x)" = 2,
                                                      "2P(X > |x|)" = 3,
                                                      "P(-x < X < x)" = 4),
                                       selected = 1),
                           hr(style = "border-top: 3px solid #2e598f;"),
                           htmlOutput("probability")),
                  
                  tabPanel(title = "Percentiles",
                           value = "ComputeQuantile",
                           textAreaInput("prob_quant",
                                     "Probability = ",
                                     width = "40%",
                                     height = "30px",
                                     resize = "none",
                                     value = 0.5),
                           selectInput("prob2", "",
                                       choices = list("P(X > x)" = 1,
                                                      "P(X < x)" = 2,
                                                      "2P(X > |x|)" = 3,
                                                      "P(-x < X < x)" = 4),
                                       selected = 1),
                           hr(style = "border-top: 3px solid #2e598f;"),
                           htmlOutput("x_quant"))
                  
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("distPlot1")
    )
  )
  #h6("This work is licensed under a Creative Commons Attribution 3.0 Unported License.")
)

# Define server logic required to draw a histogram
server <- function(input, output, session) {
  # observeEvent(input$browser,{
  #   browser()
  # })
  
  
  observe({
    req(!is.na(as.numeric(input$mean)))
    req(!is.na(as.numeric(input$xval)))

    x <- as.numeric(input$mean)
    
    if(x != 0){
      updateSelectInput(session, "prob", "",
                        choices = list("P(X > x)" = 1,
                                       "P(X < x)" = 2))
    }
    
    if(x == 0){
      updateSelectInput(session, "prob", "",
                        choices = list("P(X > x)" = 1,
                                       "P(X < x)" = 2,
                                       "2P(X > |x|)" = 3,
                                       "P(-x < X < x)" = 4))
    }
    
  })
  
  observe({
    req(!is.na(as.numeric(input$mean)))
    req(!is.na(as.numeric(input$xval)))
    
    x <- as.numeric(input$mean)
    
    if(x != 0){
      updateSelectInput(session, "prob2", "",
                        choices = list("P(X > x)" = 1,
                                       "P(X < x)" = 2),
                        selected = 1)
    }
    
    if(x == 0){
      updateSelectInput(session, "prob2", "",
                        choices = list("P(X > x)" = 1,
                                       "P(X < x)" = 2,
                                       "2P(X > |x|)" = 3,
                                       "P(-x < X < x)" = 4))
    }
    
  })
  
  pr <- reactiveValues(pr = 0)
  xval_print <- reactiveValues(x = 0)
  
  observe({
    if(input$xval != ""){
      req(!is.na(as.numeric(input$mean)))
      req(!is.na(as.numeric(input$xval)))
      req(!is.na(as.numeric(input$prob)))
      
      m <- as.numeric(input$mean)
      s <- as.numeric(input$sd)
      xv <- as.numeric(input$xval)
      
      req(s > 0)
      
      if(input$prob == 1){
        pp <- pnorm(xv, mean = m, sd = s, lower.tail = FALSE)
      }
      if(input$prob == 2){
        pp <- 1 - pnorm(xv, mean = m, sd = s, lower.tail = FALSE)
      }
      if(input$prob == 3){
        pp <- 2 * pnorm(abs(xv), mean = m, sd = s, lower.tail = FALSE)
      }
      if(input$prob == 4){
        pp <- pnorm(abs(xv), mean = m, sd = s, lower.tail = TRUE) - 
          pnorm(-1 * abs(xv), mean = m, sd = s, lower.tail = TRUE)
      }
      
      if(round(pp, 4) == 1){
        pp <- 0.9999
      }
      
      pr$pr <- round(pp, 4)
    }
    else{
      pr$pr <- 0
    }
  })
  
  
  output$probability <- renderText({
    paste("Area of shaded region is ", "<font color=\"#FF0000\"><b>", as.character(pr$pr), "</b></font>")
  })
  
  observe({
    updateTextInput(session, 
                    "prob_box",
                    value = 0)
    
  })
  
  graph1 <- reactive({
    if(input$tab == "ComputeProbability"){
      req(!is.na(as.numeric(input$mean)))
      req(!is.na(as.numeric(input$xval)))
      req(!is.na(as.numeric(input$prob)))
      m <- as.numeric(input$mean)
      s <- as.numeric(input$sd)
      xv <- as.numeric(input$xval)
      
      req(s > 0)
      
      left_limit <- m - 3*s
      right_limit <- m + 3*s
      
      top_curve <- dnorm(xv, mean = m, sd = s)
      
      funcShaded <- function(x, lower_bound) {
        y = dnorm(x, mean = m, sd = s)
        if(input$prob == 1){
          y[x < lower_bound] <- NA
        }
        if(input$prob == 2){
          y[x > lower_bound] <- NA
        }
        if(input$prob == 3){
          y[-1 * abs(lower_bound) < x & x < abs(lower_bound)] <- NA
        }
        if(input$prob == 4){
          y[!(-1 * abs(lower_bound) < x & x < abs(lower_bound))] <- NA
        }
        return(y)
      }
      
      p <- ggplot(data = data.frame(x = c(left_limit, right_limit)), aes(x = x)) + 
        stat_function(fun = dnorm, n = 101, args = list(mean = m, sd = s)) +
        stat_function(fun = funcShaded, args = list(lower_bound = xv), 
                      geom = "area", fill = "#84CA72", alpha = .2) +
        geom_segment(aes(x = xv, 
                         xend = xv, 
                         y = 0, 
                         yend = top_curve),
                     lty = "dashed") +
        geom_hline(aes(yintercept = 0)) +
        theme(axis.line.y=element_blank(),
              axis.text.y=element_blank(),
              axis.ticks=element_blank(),
              axis.title.y=element_blank(),
              axis.text.x = element_text(face="bold", color="#993333", 
                                         size=14),
              legend.position="none",
              panel.background=element_blank(),
              panel.border=element_blank(),
              panel.grid.major=element_blank(),
              panel.grid.minor=element_blank(),
              plot.background=element_blank()) + 
        scale_x_continuous(breaks=c(m - 3*s, 
                                    m - 2*s,
                                    m - 1*s,
                                    m, 
                                    m + 1*s,
                                    m + 2*s,
                                    m + 3*s))
      
      if(input$prob == 3 | input$prob == 4){
        p <- p +
          geom_segment(aes(x = -1 * xv, 
                           xend = -1 * xv, 
                           y = 0, 
                           yend = top_curve),
                       lty = "dashed")
      }
      p
    }
  })
  
  graph2 <- reactive({
    if(input$tab == "ComputeQuantile"){
      req(!is.na(as.numeric(input$mean)))
      req(!is.na(as.numeric(input$xval)))
      req(!is.na(as.numeric(input$prob)))
      
      m <- as.numeric(input$mean)
      s <- as.numeric(input$sd)
      xv <- as.numeric(input$xval)
      prob_q <- as.numeric(input$prob_quant)
      
      req(s > 0)
      req(prob_q <= 1)
      req(prob_q >= 0)
      
      left_limit <- m - 3*s
      right_limit <- m + 3*s
      
      if(input$prob2 == 1){
        new_xval <- qnorm(prob_q, mean = m, sd = s, lower.tail = FALSE)
      }
      if(input$prob2 == 2){
        new_xval <- qnorm(prob_q, mean = m, sd = s, lower.tail = TRUE)
      }
      if(input$prob2 == 3){
        new_xval <- abs(qnorm(prob_q / 2, mean = m, sd = s, lower.tail = TRUE))
      }
      if(input$prob2 == 4){
        new_xval <- qnorm((1 - prob_q) / 2, mean = m, sd = s, lower.tail = FALSE)
      }
      
      xval_print$x <- new_xval
      
      funcShaded <- function(x, lower_bound) {
        y = dnorm(x, mean = m, sd = s)
        if(input$prob2 == 1){
          y[x < lower_bound] <- NA
        }
        if(input$prob2 == 2){
          y[x > lower_bound] <- NA
        }
        if(input$prob2 == 3){
          y[-1 * abs(lower_bound) < x & x < abs(lower_bound)] <- NA
        }
        if(input$prob2 == 4){
          y[!(-1 * abs(lower_bound) < x & x < abs(lower_bound))] <- NA
        }
        return(y)
      }
      
      top_curve <- dnorm(new_xval, mean = m, sd = s)
      
      p <- ggplot(data = data.frame(x = c(left_limit, right_limit)), aes(x = x)) + 
        stat_function(fun = dnorm, n = 101, args = list(mean = m, sd = s)) +
        stat_function(fun = funcShaded, args = list(lower_bound = new_xval), 
                      geom = "area", fill = "#FCA391", alpha = .2) +
        geom_segment(aes(x = new_xval, 
                         xend = new_xval, 
                         y = 0, 
                         yend = top_curve),
                     lty = "dashed") +
        geom_hline(aes(yintercept = 0)) +
        theme(axis.line.y=element_blank(),
              axis.text.y=element_blank(),
              axis.ticks=element_blank(),
              axis.title.y=element_blank(),
              axis.text.x = element_text(face="bold", color="#993333", 
                                         size=14),
              legend.position="none",
              panel.background=element_blank(),
              panel.border=element_blank(),
              panel.grid.major=element_blank(),
              panel.grid.minor=element_blank(),
              plot.background=element_blank()) + 
        scale_x_continuous(breaks=c(m - 3*s, 
                                    m - 2*s,
                                    m - 1*s,
                                    m, 
                                    m + 1*s,
                                    m + 2*s,
                                    m + 3*s))
      
      if(input$prob2 == 3 | input$prob2 == 4){
        p <- p +
          geom_segment(aes(x = -1 * new_xval, 
                           xend = -1 * new_xval, 
                           y = 0, 
                           yend = top_curve),
                       lty = "dashed")
      }
      p
    }
  })
  
  output$x_quant <- renderText({
    paste("Desired x-value is", "<font color=\"#FF0000\"><b>", as.character(round(xval_print$x, 4)), "</b></font>")
  })

  output$distPlot1 <- renderPlot({
    if(input$tab == "ComputeProbability"){
      graph1()
    }
    else{
      graph2()
    }
  })

}

# Run the application 
shinyApp(ui = ui, server = server)
