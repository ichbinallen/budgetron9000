#-------------------------------------------------------------------------------
# Load Libraries and helpers
#-------------------------------------------------------------------------------
library(dplyr)
library(shiny)
library(shinydashboard)
library(shinyBS)
library(shinyjs)
library(DT)
library(shinyWidgets) 
library(plotly)

# globals.R  - helper functions
source("./globals.R")

# UI functions
source("./ui_functions.R")

# load DB functions for DB/DB_helpers.R
source("./DB/db_helpers.R")

# load CSS from CSS_List.R
source("./CSS_List.R")


#--------------------------------------------------------------------------------
# Shiny UI 
#--------------------------------------------------------------------------------
ui = dashboardPage(
  dashboardHeader(title = "Budgetron 9000"),
  dashboardSidebar(
    useShinyjs(),
    inlineCSS(CSS_list),
    sidebarMenu(id="menu",
                menuItem(text="Transactions", tabName="transactions", icon=icon("credit-card")),
                menuItem(text="Set Budget", tabName="budget", icon=icon("balance-scale")),
                menuItem(text="Graphs", tabName="graphs", icon=icon("area-chart"))
    )
  ),
  dashboardBody(
    tabItems(
      #--------------------------------------------------------------------------------
      # Transactions
      #--------------------------------------------------------------------------------
      tabItem(
        tabName="transactions",
        transaction_ui()
      ),
      
      #--------------------------------------------------------------------------------
      # Budget
      #--------------------------------------------------------------------------------
      tabItem(
        tabName="budget",
        budget_ui()
      ),
      
      #--------------------------------------------------------------------------------
      # Graphs
      #--------------------------------------------------------------------------------
      tabItem(
        tabName="graphs",
        graph_ui()
      )
      
      
    )
  )
)

#-------------------------------------------------------------------------------
# Shiny Server 
#-------------------------------------------------------------------------------
server = function(input, output, session) {
  #--------------------------------------------------------------------------------
  # Reactive Values
  #--------------------------------------------------------------------------------
  transactions <- reactive({
    req(input$transaction_upload)
    
    transactions = read.csv(input$transaction_upload$datapath) %>%
      mutate(
        transaction_date = as.Date(transaction_date)
      )
    updateDateRangeInput(
      session, inputId = "dr_filter",
      start=min(transactions$transaction_date), 
      end=max(transactions$transaction_date)
    )
    updateCheckboxGroupInput(
      session, inputId = "cat_filter",
      choices = as.character(levels(transactions$category)),
      inline=TRUE
    )
    transactions
  })
  #--------------------------------------------------------------------------------
  # Transaction Tab 
  #--------------------------------------------------------------------------------
  output$transaction_dt = DT::renderDT(transactions())
  
  #--------------------------------------------------------------------------------
  # Budget Tab 
  #--------------------------------------------------------------------------------
  
  #--------------------------------------------------------------------------------
  # Graph Tab 
  #--------------------------------------------------------------------------------
  observe({
    updateCheckboxGroupInput(
      session,
      'cat_filter',
      choices=levels(transactions()$category), 
      selected=if(input$all_cats) {levels(transactions()$category)},
      inline=TRUE
    )
  })
  
  output$budget_plot = renderPlot({
    req(transactions())
    req(input$dr_filter)
    req(input$cat_filter)
    req(input$graph_type=="Monthly")
    
    monthly_spending_plot(
      transactions(),  
      start=input$dr_filter[1], 
      end=input$dr_filter[2],
      categories=input$cat_filter)
  })
  
  output$lollipop_plot = renderPlotly({
    req(transactions())
    req(input$dr_filter)
    req(input$cat_filter)
    req(input$graph_type=="Transactions")
    
    lp = lollipop_plot(
      transactions(),  
      start=input$dr_filter[1], 
      end=input$dr_filter[2],
      categories=input$cat_filter)
    ggplotly(lp, tooltip=c("label", "label2", "label3", "label4"))
  })
  
  output$savings_plot = renderPlot({
    req(transactions())
    req(input$dr_filter)
    req(input$cat_filter)
    req(input$graph_type=="Savings")
    
   savings_graph(
      transactions(),  
      start=input$dr_filter[1], 
      end=input$dr_filter[2]
   )
  })
  
  
}

shinyApp(ui, server)