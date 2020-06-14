library(shiny)
library(htmltools)
library(plotly)
library(FinancialMath)
library(shinyFeedback)

ui <- shinyUI(
  
  fluidPage(
    shinyFeedback::useShinyFeedback(),
    titlePanel("Mortgage Payment Calculator"),
    sidebarLayout(
      sidebarPanel(
        
        numericInput("price", "Purchase price:", min = 1, value = 100000),
        numericInput("term", "Loan Term (months):", 1, min = 1, value = 360),
        sliderInput("interest", "Interest Rate:",  
                    round = -2, step = 0.01,
                    min = 0, 
                    max = 100,
                    value = 6,
                    sep = "" , post = "%", ticks = FALSE),
        numericInput("min_month", "Beginning of amortization view (month):", 1, min = 1),
        # submitButton(
        #   inputId = "submit_loc",
        #   label = "Submit"
        # )
        actionButton("submit_loc", "Submit!")
      ) ,#sidebar panel
      
      mainPanel(
        htmlOutput("mortgage_message"),
        tableOutput("amort_table"),
        plotlyOutput("payment_plot")
      ) # main panel
      
    )# sidebar layout
    
    
    
  )# fluidPage
)# ShinyUI

server <- shinyServer(function(input, output, session) {
  
  observeEvent(
    eventExpr = input[["submit_loc"]],
    handlerExpr = {
      values <- reactiveValues()
      
      observeEvent(input$price, {
        
        feedbackWarning(
          "price", 
          input$price < 0,
          "Please select a number greater than 0:"
        )  
        
        values$price <- input$price
      })
      
      observeEvent(input$term, {
        
        feedbackWarning(
          "term", 
          input$term < 0,
          "Please select a number greater than 0:"
        )
        
        values$term <- input$term
      })
      
      observeEvent(input$interest, {
        values$interest <- input$interest
      })
      
      observeEvent(input$min_month, {
        
        feedbackWarning(
          "min_month", 
          input$min_month < 0,
          "Please select a number greater than 0:"
        )
        
        values$min_month <- input$min_month
      })
      
      func_amort_table <- reactive({

        req(values$min_month, values$price > 0)
                
        p = values$price
        i = values$interest
        t = values$term
        
        i2 = (i/100)/12
        
        temp = amort.table(Loan=p,
                           n=t,
                           pmt=NA,
                           i=i/100,
                           ic=12,
                           pf=12,plot=FALSE)
        
        temp = as.data.frame(temp$Schedule)
        
        temp$Year = temp$Year*12
        
        temp
        
      })
      
      observeEvent(func_amort_table(), {
        
        temp <- func_amort_table()
        
        temp$cum_paid <- cumsum(temp$Payment)
        
        values$amort_table <- temp
        
        values$mortgage <- temp[1,2]
        
        values$totalpaid <- temp[360,6]
        
        values$interestpaid <- temp[360,6] - values$price
        
      })
      
      output$mortgage_message <- renderUI({
        str1 <- "Your monthly mortgage payment is ["
        str2 <- paste("R", as.character(format(values$mortgage, nsmall = 2)))
        str3 <- "] . You would have paid a total of ["
        str4 <- paste("R", as.character(format(values$totalpaid, nsmall = 2)))
        str5 <- "] over the course of the loan term with ["
        str6 <- paste("R", as.character(format(values$interestpaid, nsmall = 2)))
        str7 <- "] being interest payments."
        
        messagetoShow <- paste(str1, "<font color=\"#FF0000\"><b>", str2, "</b></font>", str3,
                               "<font color=\"#FF0000\"><b>", str4, "</b></font>", str5,
                               "<font color=\"#FF0000\"><b>", str6, "</b></font>", str7
                               )
        
        HTML(paste(messagetoShow))
        
      })
      
      output$amort_table <- renderTable({
        
        temp <- values$amort_table
        
        t = values$term
        
        min_month = values$min_month
        if (min_month > t - 12)
          max_month = t
        else
          max_month = min_month + 12
        
        names(temp)[names(temp) == "cum_paid"] <- "Cumulative Paid"
        
        temp[min_month:max_month,]
      })
      
      output$payment_plot <- renderPlotly({
        req(input$submit_loc)
        isolate({
          
          temp <- values$amort_table
          
          ## Define a blank plot with the desired layout (don't add any traces yet)
          g <- plot_ly()%>%
            layout(title = "Amortization Table",
                   xaxis = list(title = "Month"),
                   yaxis = list (title = "Amount") )
          
          ## Make sure our list of columns to add doesnt include the Month Considered
          ToAdd <- c("Balance", "cum_paid")
          chart_names <- c("Balance", "Cumulative Paid")
          line_colours <- c("chartreuse", "darkorange")
          
          ## Add the traces one at a time
          j = 1
          for(i in ToAdd){
            g <- g %>% add_trace(x = temp[["Year"]],
                                 y = temp[[i]],
                                 name = chart_names[j],
                                 type = 'scatter',
                                 mode = 'line',
                                 line = list(color = line_colours[j], width = 3))
            j = j+1
            }
          g
        })
        
      })
    }
  )
  
  } # function
) # ShinyServer

app <- shinyApp(ui = ui, server = server)

runApp(app)
