# ------------------------------------------------------------------------------
# ---- Load Libraries
# ------------------------------------------------------------------------------
library(dplyr)
library(ggplot2)
library(scales)
library(janitor)

# ------------------------------------------------------------------------------
# ---- Load Data
# ------------------------------------------------------------------------------

# ----------
# TCF
tcf = read.csv("./FormatedStatements/TCF.csv") %>%
  mutate(
    transaction_date = as.Date(Date, "%m/%d/%y"),
    charge_amount = ifelse(is.na(Credit), Debit, Credit)
  ) %>%
  clean_names %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(tcf)

# ----------
# citibank - Allen
citi = read.csv("./FormatedStatements/CitiAllen.csv") %>%
  mutate(
    transaction_date = as.Date(Date, "%m/%d/%y"),
    charge_amount = ifelse(is.na(Credit), -Debit, Credit),
    account = "Citi - Allen"
  ) %>%
  clean_names %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
  
head(citi)
# --------------
# USBANK - joint
usbank = read.csv("./FormatedStatements/USBankJoint.csv") %>%
  mutate(
    transaction_date = as.Date(Date, "%Y-%m-%d")
  ) %>%
  clean_names %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(usbank, 20)

# ----------------
# Discover - allen
discover = read.csv("./FormatedStatements/Discover.csv") %>%
  clean_names %>% 
  mutate(
    transaction_date = as.Date(trans_date, "%m/%d/%y"),
    account = "Discover - Allen",
    charge_amount = - amount
  ) %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(discover)

# ------------------
# CapitalOne - allen
capitalone = read.csv("./FormatedStatements/CapitalOne.csv") %>%
  clean_names %>%
  mutate(
    transaction_date = as.Date(transaction_date, "%Y-%m-%d"),
    account = "CapitalOne - Allen",
    charge_amount = ifelse(is.na(credit), - debit, credit)
  ) %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(capitalone)

# --------------
# Chase - Ziming
chase = read.csv("./FormatedStatements/Chase_Ziming.csv") %>%
  clean_names %>%
  mutate(
    transaction_date = as.Date(transaction_date, "%m/%d/%y"),
    account = "Chase - Ziming",
    charge_amount = amount
  ) %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(chase)

# --------------
# Chase - Allen
chase_allen = read.csv("./FormatedStatements/Chase_Allen.csv") %>%
  clean_names %>%
  mutate(
    transaction_date = as.Date(transaction_date, "%m/%d/%y"),
    account = "Chase - Allen",
    charge_amount = amount
  ) %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(chase_allen)

# --------------
# Cash
cash = read.csv("./FormatedStatements/Cash.csv") %>%
  clean_names %>%
  mutate(
    transaction_date = as.Date(date, "%Y-%m-%d"),
    account = "Cash Spending"# ,
    # subcategory = ifelse(is.na(subcategory), "", subcategory)
  ) %>%
  select(
    transaction_date, account, description, category, subcategory, charge_amount
  ) %>%
  arrange(desc(transaction_date))
head(cash)


# ---------------------------
# Bunch all spending together
spending = do.call(
  rbind.data.frame, 
  list(tcf, discover, usbank, capitalone, chase, cash, chase_allen, citi)
  ) %>%
  arrange(transaction_date) %>%
  mutate(
    category = as.factor(ifelse(as.character(category)=="Clothing", "Shopping", as.character(category)))
  ) %>%
  arrange(desc(transaction_date))
head(spending, 20)

# set monthly rent payments
spending = spending %>%
  filter(category!= "Rent")
rent = data.frame(
  transaction_date = seq.Date(
    as.Date("2020-01-01"), as.Date("2020-09-01"), by="month"
  ),
  account="Rent",
  description="Rent",
  category="Shelter",
  subcategory="Rent",
  charge_amount=-995.0
)
spending = rbind.data.frame(spending, rent) %>%
  arrange(desc(transaction_date))
spending = spending %>%
  filter(!(category=="Gift" & subcategory=="Received")) %>%
  filter(!category %in% c("House", "Investment", "Taxes", "Jewelry")) %>%
  filter(category != "Shelter" | subcategory %in%  c("Mortgage", "Rent")) %>%
  droplevels

spending %>%
  count(category) %>%
  as.data.frame

spending %>% filter(category == "Home")

# --------------------------
# Save to a file
write.csv(x = spending, file="./FormatedStatements/Spending.csv", row.names = F)

budget = read.csv("./FormatedStatements/Budget.csv") %>%
  mutate(
    yearly_budget = Budget * 12,
    monthly_budget = Budget
  ) %>%
  select(Category, yearly_budget, monthly_budget)
names(budget)[names(budget) == "Category"] = "category"

year_2021 = spending %>% mutate(
  month = substr(transaction_date, 6, 7),
  year = substr(transaction_date, 1, 4)
) %>% 
  filter(year == 2021) %>%
  group_by(year, category) %>%
  summarize(
    yearly_spend = abs(sum(charge_amount))
  ) %>%
  mutate(monthly_spend = yearly_spend / 12) %>%
  merge(y=budget, on="Category") %>%
  mutate(
    yearly_balance = yearly_budget - yearly_spend,
    monthly_balance = monthly_budget - monthly_spend
  )

sum(budget$yearly_budget, na.rm=T)
year_2021
sum(year_2021$yearly_balance, na.rm=T)
sum()

spending %>% 
  filter(category != "Income") %>%
  filter(transaction_date >= '2021-01-01') %>%
  filter(transaction_date <= '2021-12-31') %>%
  summarize(yearly_spend = sum(charge_amount))

spending %>% 
  filter(transaction_date >= '2021-12-01') %>%
  filter(transaction_date <= '2021-12-31') %>%
  group_by(category) %>%
  summarize(
    yearly_spend = sum(charge_amount)
  ) %>%
  mutate(monthly_spend = yearly_spend / 12)

spending %>% filter(
  category=="Entertainment"
)

spending %>% mutate(
  month = substr(transaction_date, 6, 7),
  year = substr(transaction_date, 1, 4)
) %>% 
  filter(category != "income") %>%
  group_by(year) %>%
  summarize(avg_spend = sum(charge_amount)) %>%
  mutate(baby_spend = avg_spend * 1.2)
