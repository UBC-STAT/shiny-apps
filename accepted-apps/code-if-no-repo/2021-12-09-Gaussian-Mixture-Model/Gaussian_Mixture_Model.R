
library(shiny)

ui <- fluidPage(
  sidebarPanel(
    textOutput("Explanation"),
    sliderInput("p1", "prob. of dist. 1:",
                min = 0, max = 1,
                value = 0.5, step = 0.01),
    sliderInput("mu1", "mean of dist. 1:", min = 1, max = 15, value=1, step=0.1),
    sliderInput("mu2", "mean of dist. 2:", min = 1, max = 15, value=10, step=0.1),
    sliderInput("sigma1", "standard dev. of dist. 1:", min = 1, max = 15, value=2, step=0.1),
    sliderInput("sigma2", "standard dev. of  dist. 2:", min = 1, max = 15, value=2, step=0.1)
    #actionButton("go", "Sample") # Next year show how to sample from it
  ),
  mainPanel(
    plotOutput("plot_gmm", height = "30%")
  )

)

server <- function(input, output) {
  
  
 #resample_val <- reactiveVal(0)
 
  #randomVals <- eventReactive(input$go, {
    #resample_val <- # SAMPLE P1
    # SAMPLE VALUE  
  #  print(resample_val())
  #  return(resample_val)
  #})
  
  output$Explanation <- renderText(
    "Let's explore a simple Gaussian mixture model. 
    First, change the weight of the first component (prob. of dist. 1).
    See how it affects the shape of the distribution.
    Second, see how changing the mean values of each distribution affect the shape of the distribution.
    Finally, see how changing the standard deviation values of each distribution affect the shape of the distribution."
  )
  

  
  
  
  output$plot_gmm <- renderPlot({
    mu1 <-input$mu1
    mu2 <-input$mu2
    sigma1 <-input$sigma1
    sigma2 <-input$sigma2
    p1 <-input$p1
    
    curve(p1*dnorm(x, mu1, sigma1) + (1-p1)*dnorm(x,mu2,sigma2), 
          -20, 40, n=1000, lwd=4, lty=3,
          las=1, ylab="PDF", xlab="y")
    curve(p1*dnorm(x, mu1, sigma1), -20, 40, n=1000, add=TRUE, col="hotpink", lwd=3)
    curve((1-p1)*dnorm(x, mu2, sigma2), -20, 40, n=1000, add=TRUE, col="purple", lwd=3)
    curve(p1*dnorm(x, mu1, sigma1) + (1-p1)*dnorm(x,mu2,sigma2), 
          -20, 40, n=1000, lwd=4, lty=3, add=TRUE)
    legend("topright", c("Dist. 1", "Dist. 2", "Mixture"), col=c("hotpink", "purple", "black"),
           pch=NA, lwd=c(3,3,4), lty=c(1,1,3), bty="n")
    
  
    }, height = 500, width = 600)

  
  #output$table <- renderTable(data.frame(Original_sample = caff, 
  #                                       Resample = randomVals()), digits = 1)
  
}

shinyApp(ui, server)
