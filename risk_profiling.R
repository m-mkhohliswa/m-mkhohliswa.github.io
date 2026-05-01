setwd("C:\\Users\\musam\\Portfolio_Analysis\\scripts\\r_scripts")
library(quantmod)
library(pander)
library(xts)
library(DBI)
library(RMySQL)
library(data.table)
library(tidyr)
library(FSA)
library(car)
library(rstatix)
library(ggplot2)
library(MASS)
library(e1071)
library(dplyr)
library(purrr)
library(arrow)
library(PerformanceAnalytics)
# ======================================= Horizon Bancorp ================================
HBNC = read_parquet("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Daily\\HBNC.parquet")
HBNC = as.data.frame(HBNC)
Price = HBNC$`Adj Close`

Daily_Returns = function(Price){
  result = numeric(length(Price))
  for(i in 2:length(Price)){
    result[i] = (Price[i] - Price[i-1]) / Price[i-1]
  }
  return(result)
}

##### Daily Returns 

PricesHBNC = cbind(Daily_Returns(Price), HBNC$Date)
#PricesHBNC = PricesHBNC[-1, drop = FALSE]
colnames(PricesHBNC) = c("Daily_ReturnsHBNC", "Date")
PricesHBNC = as.data.frame(PricesHBNC)
#HBNC[5714,]
HBNC = merge(HBNC, PricesHBNC, by = "Date", all.x = TRUE)
HBNC_Date = as.Date(HBNC$Date)
Returns_HBNC = as.xts(HBNC$`Adj Close`, order.by = HBNC_Date)
Returns_HBNC = Return.calculate(Returns_HBNC, method = "simple")
Returns_HBNC = as.data.frame(Returns_HBNC)
Returns_HBNC = cbind(Returns_HBNC, HBNC$Date)
colnames(Returns_HBNC) = c("Daily_ReturnsPA", "Date")
HBNC = merge(HBNC, Returns_HBNC, by = "Date", all.x = TRUE)

#### Volatility 
Risk_DevHBNC = StdDev.annualized(HBNC$Daily_ReturnsPA, scale = 252)

### ROI
#ROI_Total
ROI_HBNC = Return.annualized(HBNC$Daily_ReturnsPA, scale = 252)
#ROI_HBNC_Total = (HBNC$`Adj Close`[5714] - HBNC$`Adj Close`[2])/(HBNC$`Adj Close`[2])
Sharpe_HBNC = ROI_HBNC/Risk_DevHBNC

#=========================== Microsoft MSFT ====================================
######## Daily Returns
MSFT = read_parquet("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Daily\\MSFT.parquet")
MSFT = as.data.frame(MSFT)
MSFT_Date = as.Date(MSFT$Date)
Returns_MSFT = as.xts(MSFT$`Adj Close`, order.by = MSFT_Date)
Returns_MSFT = Return.calculate(Returns_MSFT, method = "simple")
Returns_MSFT = as.data.frame(Returns_MSFT)
Returns_MSFT = cbind(Returns_MSFT, MSFT$Date)
colnames(Returns_MSFT)=c("Daily_ReturnsPA", "Date")
MSFT = merge(MSFT, Returns_MSFT, by = "Date", all.x = TRUE)

#### Volatility
Risk_DevMSFT = StdDev.annualized(MSFT$Daily_ReturnsPA, scale = 252)

### Risk
ROI_MSFT = Return.annualized(MSFT$Daily_ReturnsPA, scale = 252)

### Sharpe
Sharpe_MSFT = ROI_MSFT/Risk_DevMSFT

# ==================================== PPL =====================================
###### Daily Returns
PPL = read_parquet("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Daily\\PPL.parquet")
PPL = as.data.frame(PPL)
PPL_Date = as.Date(PPL$Date)
Returns_PPL = as.xts(PPL$`Adj Close`, order.by = PPL_Date)
Returns_PPL = Return.calculate(Returns_PPL, method = "simple")
Returns_PPL = as.data.frame(Returns_PPL)
Returns_PPL = cbind(Returns_PPL, PPL$Date)
colnames(Returns_PPL)=c("Daily_ReturnsPA", "Date")
PPL = merge(PPL, Returns_PPL, by = "Date", all.x = TRUE)

##### Volatility
Risk_DevPPL = StdDev.annualized(PPL$Daily_ReturnsPA, scale = 252)

#### ROI
ROI_PPL = Return.annualized(PPL$Daily_ReturnsPA, scale =252)

#### Sharpe
Sharpe_PPL = ROI_PPL/Risk_DevPPL

#summary dataframe
summary_data <- data.frame(
  Ticker = c("HBNC", "MSFT", "PPL"),
  ROI = c(ROI_HBNC, ROI_MSFT, ROI_PPL),
  Risk = c(Risk_DevHBNC, Risk_DevMSFT, Risk_DevPPL),
  Sharpe = c(Sharpe_HBNC, Sharpe_MSFT, Sharpe_PPL)
)

write.csv(summary_data, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\summary_data.csv")
# 1. Bar Chart for Sharpe Ratio (Efficiency)
ggplot(summary_data, aes(x = reorder(Ticker, -Sharpe), y = Sharpe, fill = Ticker)) +
  geom_bar(stat = "identity") +
  theme_minimal() +
  labs(title = "Risk-Adjusted Returns (Sharpe Ratio)", 
       x = "Stock", y = "Sharpe Ratio")

# 2. Scatter Plot (Risk vs Return) - The "Gold Standard" for interpretation
ggplot(summary_data, aes(x = Risk, y = ROI, label = Ticker)) +
  geom_point(size = 4, color = "blue") +
  geom_text(vjust = -1) +
  theme_minimal() +
  labs(title = "Risk vs. Return Profile", 
       x = "Annualized Volatility (Risk)", 
       y = "Annualized Return (ROI)")

###Interpretation
# ---------------------------
# MSFT (Microsoft): Aggressive (Medium High)
# It has the highest ROI (~25.9%) and the highest Sharpe Ratio (~0.77). 
# This indicates that MSFT provides the best compensation for the risk taken.

# PPL (PPL Corp): The Low-Beta/Conservative Choice. 
# Lowest ROI (~9.8%) but also the lowest Risk (~21.9%). 
# Its Sharpe Ratio (~0.45) suggests it is a stable, albeit slower, grower.

# HBNC (Horizon Bancorp): Balanced (Medium Low)
# High risk (~32.5%) similar to MSFT, but significantly lower ROI (~10%). 
# The low Sharpe Ratio (~0.31) suggests the volatility isn't "paying off" 
# as well as the other two assets.

### 3. Visualization: Risk vs. Return Scatter Plot
# -----------------------------------------------
# This graph is the best way to visualize the "Efficient Frontier" concept.
# We want stocks to be as far "Northwest" (Top-Left) as possible.


data = read.csv("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\DividendYields.csv", header = T)
returns_data <- data / 100
calculate_sector_metrics <- function(column_data) {
  # Volatility
  vol <- StdDev.annualized(column_data, scale = 252)
  
  # ROI (Annualized Return)
  roi <- Return.annualized(column_data, scale = 252)
  
  # Sharpe Ratio
  sharpe <- roi / vol
  
  return(c(ROI = roi, Volatility = vol, Sharpe_Ratio = sharpe))
}

# Apply the function to all columns and create the data frame
metrics_results <- as.data.frame(t(apply(returns_data, 2, calculate_sector_metrics)))

# Rename the columns for clarity
colnames(metrics_results) <- c("ROI", "Volatility", "Sharpe_Ratio")

# Display the final data frame
print(metrics_results)
write.csv(metrics_results, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\metrics_results.csv")

calc_summary <- function(x) {
  roi <- mean(x, na.rm = TRUE)
  vol <- sd(x, na.rm = TRUE)
  sharpe <- roi / vol
  return(c(Average_Yield = roi, Sector_SD = vol, Ratio = sharpe))
}

# 1. Create the data frame
sector_analysis <- as.data.frame(t(apply(data, 2, calc_summary)))
print(sector_analysis)
write.csv(sector_analysis, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\sector_analysis.csv")

sector_data <- read.csv("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Sector_Performance_Averages.csv")

# 2. Categorize based on markers
modeled_profiles <- sector_data %>%
  mutate(Risk_Profile = case_when(
    Avg_Sharpe > 0.35  ~ "Aggressive",
    Avg_Sharpe >= 0.25 ~ "Balanced",
    TRUE               ~ "Conservative"
  ))

# 3. Create the frequency data for the Doughnut Chart
doughnut_data <- modeled_profiles %>%
  group_by(Risk_Profile) %>%
  summarise(
    Sector_Count = n(),
    Sectors = paste(Sector, collapse = ", ")
  ) %>%
  mutate(Proportion = Sector_Count / sum(Sector_Count))

# View the result
print(doughnut_data)
write.csv(doughnut_data, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\Doughnut_data.csv")

