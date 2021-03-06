transaction_ui = function() {
  out = fluidPage(
    fileInput("transaction_upload", label = "Upload Transactions From CSV"),
    DT::DTOutput("transaction_dt")
  )
  return(out)
}

budget_ui = function() {
  out = fluidPage(
    p("Budget user interface"),
    p(id = "coming_soon", "Budgeting Feature coming '''soon'''")
  )
  return(out)
}

graph_ui = function() {
  out = fluidPage(
    box(title="Plot Options", status="info", solidHeader=T, width=12, collapsible=T, collapsed=T,
      selectInput("graph_type", label="Graph Type", choices=c("Transactions", "Monthly")),
      dateRangeInput(
        "dr_filter", label = "Date Range", 
        start=format(Sys.Date(), "%Y-01-01"), 
        end=format(Sys.Date(), "%Y-%m-01")
      ),
      checkboxGroupInput(
        "cat_filter", label = "Categories", choices = letters[1:3], inline=TRUE
      )
    ),
    plotOutput("budget_plot"), 
    plotlyOutput("lollipop_plot"), 
  )
  return(out)
}