########### load packages ##########
library(dplyr)
library(ggplot2)
library(openxlsx)
library(reshape2)
library(scales)
library(patchwork)

########## USER ACCESS ##########

########## Read Data Functions ##########
# read_xxx = function(xlsxFile) {
#   out = openxlsx::read.xlsx(xlsxFile)
#   return(out)
# }

########### Graph functions ##########
monthly_spending_plot = function(
  transactions,
  start_date = min(transactions$transaction_date),
  end_date = max(transactions$transaction_date),
  categories = levels(transactions$category)
  ) { 
  # Calculate Spending by category by month
  monthly_spending = transactions %>%
    filter(
      transaction_date >= start_date & transaction_date <= end_date &
      category %in% categories) %>%
    mutate(
      month = format(transaction_date, "%m"),
      year = format(transaction_date, "%Y")) %>%
    group_by(category, year, month) %>%
    summarize(month_spending = sum(charge_amount, na.rm=T))
  
  # Fill in zero for months with no spending in a category
  missing_months = as.data.frame(expand.grid(
    unique(monthly_spending$category),
    unique(monthly_spending$year),
    unique(monthly_spending$month),
    stringsAsFactors = F
  ))
  names(missing_months) = c("category", "year", "month")
  
  monthly_spending = monthly_spending %>%
    full_join(missing_months) %>%
    mutate(month_spending = ifelse(is.na(month_spending), 0, month_spending)) %>%
    mutate(
      avg_spending = mean(month_spending),
      date = as.Date(paste0(year, "-", month, "-01")),
      month_spending = month_spending * -1,
      avg_spending = avg_spending * -1) %>%
    arrange(category, year, month)
  
  gg = ggplot(
    monthly_spending, aes(x=date, y=month_spending, group=category, color=category)
  ) +
    geom_line() +
    geom_point() +
    geom_line(aes(x=date, y=avg_spending), linetype="dashed") +
    scale_y_continuous(label=dollar) +
    scale_x_date(date_breaks = "1 month", date_minor_breaks = "1 week",
                 date_labels = "%m/%Y") +
    labs(x=NULL, y="Spending", title="Spending By Category", 
         subtitle="Solid = Actual Spending; Dashed = Category Average") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  return(gg)
}

lollipop_plot = function(
  transactions,
  start_date = min(transactions$transaction_date),
  end_date = max(transactions$transaction_date),
  categories = levels(transactions$category)
) {                
  transactions = transactions %>%
    filter(
      transaction_date >= start_date & transaction_date <= end_date &
      category %in% categories) %>%
    mutate(charge_amount = - charge_amount)
  date_break_vec = sort(transactions$transaction_date)
  pop_plot = ggplot(transactions,  aes(
    x=transaction_date, y=charge_amount, 
    label=charge_amount, label2=description, label3=category, label4=subcategory)) +
    geom_point(aes(
      x=transaction_date, y=charge_amount, fill = category),
      color="black", alpha=0.7, shape=21, stroke=1, size=3) +
    geom_segment(
      aes(x=transaction_date, xend=transaction_date, y=0, yend=charge_amount),
      size=0.5, linetype="dashed") +
    scale_y_continuous(label=dollar) +
    scale_x_date(breaks = date_break_vec) +
    labs(x=NULL, y="Spending", title="Transactions By Category") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  return(pop_plot)
}

savings_graph = function(data, start_date, end_date) {
  data = data %>% filter(
    transaction_date >= start_date &
    end_date >= end_date
  )
  monthly_wide = data %>% 
    mutate(
      type = ifelse(category=="Income", "earnings", "spending"),
      year_month = strftime(transaction_date, "%Y-%m"),
    ) %>% 
    group_by(year_month, type) %>%
    summarise(total = sum(charge_amount, na.rm=T)) %>%
    mutate(
      month_date = as.Date(paste0(year_month, "-01")),
      total = ifelse(type=="spending", -total, total)
    ) %>%
    dcast(month_date ~ type, value.var="total") %>%
    mutate(savings_rate = 1 - spending / earnings)
   
  savings_rate_plot = ggplot(monthly_wide, aes(x=month_date, y=savings_rate)) +
    geom_point() + 
    geom_line() +
    scale_x_date(date_breaks="1 month", date_labels="%m/%Y") +
    scale_y_continuous(labels=percent) +
    labs(x=NULL, y="savings rate", title="Monthly Savings Rate") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  monthly = monthly_wide %>%
    mutate(
      savings = earnings + spending,
    ) %>% melt(
      id.vars="month_date",
      measure_vars=c("earnings", "spending", "savings"),
      value.name="amount",
      variable.name="type"
    )
  
  graph_data = monthly %>% 
    filter(type %in% c("earnings", "spending")) %>%
    droplevels
  
  savings_earnings_plot = ggplot() +
    geom_point(data=graph_data, aes(x=month_date, y=amount, color=type)) +
    geom_line(data=graph_data, aes(x=month_date, y=amount, color=type)) +
    geom_ribbon(data=monthly_wide, aes(
      x=month_date, ymin=-spending, ymax=earnings),
      fill="skyblue", alpha=0.2) +
    scale_x_date(date_breaks="1 month", date_labels="%m/%Y") +
    scale_y_continuous(labels=dollar, limits=c(0,NA)) +
    labs(x=NULL, y=NULL, title="Earnings and Spending") +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  
  return(savings_rate_plot)
  
  return(savings_earnings_plot /  savings_rate_plot)
}

########### Other functions ##########

## Testing Section:
# spending = read.csv("./FormatedStatements/Spending.csv") %>%
#   mutate(transaction_date = as.Date(transaction_date))
# head(spending)
# monthly_spending_plot(spending, "2020-05-01", "2020-08-01")
# levels(spending$category)
