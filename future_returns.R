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
connect = dbConnect(RMySQL::MySQL(),
                    host     = "localhost",
                    dbname   = "company_db",
                    user     = "root",
                    password = "Mkhohliswa@1407",
                    port     = 3306
)

SQL_data_base = dbReadTable(connect, "INFO_TABLE")
SQL_Risk_Adj_Returns = dbReadTable(connect, "Risk_Adj_Returns" )
SQL_CAPITAL = dbReadTable(connect, "CAPITAL")
GI_FUTURE_RETURNS = dbReadTable(connect, "GI_FUTURE_RETURNS")
ME_INTERNAL_TABLE = dbReadTable(connect, "ME_INTERNAL_TABLE")
Income_Metrics = dbReadTable(connect, "Income_Metrics")
SECTORS_SQL = dbReadTable(connect, "sectors")
#===================== Income =====================
BasicMat_IM = dbReadTable(connect, "BasicMat_IM")
CommServ_IM = dbReadTable(connect, "CommServ_IM")
ConsCycl_IM = dbReadTable(connect, "ConsCycl_IM")
ConsDef_IM = dbReadTable(connect, "ConsDef_IM")
ENER_IM = dbReadTable(connect, "ENER_IM")
FinServ_IM = dbReadTable(connect, "FinServ_IM")
HealthCare_IM = dbReadTable(connect, "HealthCare_IM")
Indust_IM = dbReadTable(connect, "Indust_IM")
RealEst_IM = dbReadTable(connect, "RealEst_IM")
Tech_IM = dbReadTable(connect, "Tech_IM")
Utility_IM = dbReadTable(connect, "Utility_IM")

#  ===================== CAPITAL =====================
BasicMat_Capital = dbReadTable(connect, "BasicMat_Capital")
CommServ_Capital = dbReadTable(connect, "CommServ_Capital")
ConsCycl_Capital = dbReadTable(connect, "ConsCycl_Capital")
ConsDef_Capital = dbReadTable(connect, "ConsDef_Capital")
Ener_Capital = dbReadTable(connect, "Ener_Capital")
FinServ_Capital = dbReadTable(connect, "FinServ_Capital")
HealCare_Capital = dbReadTable(connect, "HealCare_Capital")
Indust_Capital = dbReadTable(connect, "Indust_Capital")
RealEst_Capital = dbReadTable(connect, "RealEst_Capital")
Tech_Capital = dbReadTable(connect, "Tech_Capital")
Utility_Capital  = dbReadTable(connect, "Utility_Capital")

# ===================== GI_Future_Returns =====================
BasicMat_FutureReturns = dbReadTable(connect, "BasicMat_FutureReturns")
CommServ_FutureReturns  = dbReadTable(connect, "CommServ_FutureReturns")
ConsCycl_FutureReturns  = dbReadTable(connect, "ConsCycl_FutureReturns")
ConsDef_FutureReturns = dbReadTable(connect, "ConsDef_FutureReturns")
Ener_FutureReturns = dbReadTable(connect, "Ener_FutureReturns")
FinServ_FutureReturns = dbReadTable(connect, "FinServ_FutureReturns")
HealCare_FutureReturns = dbReadTable(connect, "HealCare_FutureReturns")
Indust_FutureReturns = dbReadTable(connect, "Indust_FutureReturns")
RealEst_FutureReturns = dbReadTable(connect, "RealEst_FutureReturns")
Tech_FutureReturns = dbReadTable(connect, "Tech_FutureReturns")
Utility_FutureReturns = dbReadTable(connect, "Utility_FutureReturns")

# ===================== Risk_Adj_Returns =====================
BasicMat_AdjReturns = dbReadTable(connect, "BasicMat_AdjReturns")
CommServ_AdjReturns = dbReadTable(connect, "CommServ_AdjReturns")
ConsCycl_AdjReturns = dbReadTable(connect, "ConsCycl_AdjReturns")
ConsDef_AdjReturns  = dbReadTable(connect, "ConsDef_AdjReturns")
Ener_AdjReturns = dbReadTable(connect, "Ener_AdjReturns")
FinServ_AdjReturns = dbReadTable(connect, "FinServ_AdjReturns")
HealCare_AdjReturns = dbReadTable(connect, "HealCare_AdjReturns")
Indust_AdjReturns = dbReadTable(connect, "Indust_AdjReturns")
RealEst_AdjReturns = dbReadTable(connect, "RealEst_AdjReturns")
Tech_AdjReturns = dbReadTable(connect, "Tech_AdjReturns")
Utility_AdjReturns = dbReadTable(connect, "Utility_AdjReturns")

# ===================== ME_INTERNAL_TABLE =====================
BasicMat_ManagementEff = dbReadTable(connect, "BasicMat_ManagementEff")
CommServ_ManagementEff = dbReadTable(connect, "CommServ_ManagementEff")
ConsCycl_ManagementEff = dbReadTable(connect, "ConsCycl_ManagementEff")
ConsDef_ManagementEff = dbReadTable(connect, "ConsDef_ManagementEff")
Ener_ManagementEff = dbReadTable(connect, "Ener_ManagementEff")
FinServ_ManagementEff = dbReadTable(connect, "FinServ_ManagementEff")
HealCare_ManagementEff = dbReadTable(connect, "HealCare_ManagementEff")
Indust_ManagementEff = dbReadTable(connect, "Indust_ManagementEff")
RealEst_ManagementEff = dbReadTable(connect, "RealEst_ManagementEff")
Tech_ManagementEff = dbReadTable(connect, "Tech_ManagementEff")
Utility_ManagementEff = dbReadTable(connect, "Utility_ManagementEff")

# 1. Stack all Income Metrics tables
sector_list = list(
  Basic_Materials = BasicMat_Capital, Communication_Serv = CommServ_Capital,
  Consumer_Cycle = ConsCycl_Capital, Consumer_Defense = ConsDef_Capital,
  Energy = Ener_Capital, Financial_Serv = FinServ_Capital,
  Healthcare = HealCare_Capital, Industrials = Indust_Capital,
  Real_Estate = RealEst_Capital, Technology = Tech_Capital,
  Utilities = Utility_Capital
)

All_Sectors_Capital = rbindlist(sector_list, idcol = "Sector")

future_list = list(
  Basic_Materials = BasicMat_FutureReturns, Communication_Serv = CommServ_FutureReturns,
  Consumer_Cycle = ConsCycl_FutureReturns, Consumer_Defense = ConsDef_FutureReturns,
  Energy = Ener_FutureReturns, Financial_Serv = FinServ_FutureReturns,
  Healthcare = HealCare_FutureReturns, Industrials = Indust_FutureReturns,
  Real_Estate = RealEst_FutureReturns, Technology = Tech_FutureReturns,
  Utilities = Utility_FutureReturns
)

# Combine into one long table
All_Future_Growth = rbindlist(future_list, idcol = "Sector")
write.csv(All_Future_Growth, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\All_Future_Growth.csv")

# 2. Merge with your Return Data (assuming Symbol is the common key)
# This creates one master 'Quant_DF' for the regression
Quant_DF = merge(All_Sectors_Capital, All_Future_Growth, by = "Symbol")

setDT(All_Sectors_Capital)

# 2. Calculate the returns inside All_Sectors_Capital
All_Sectors_Capital[, `:=`(
  Stock_Momentum = (currentPrice - twoHundredDayAverageChange) / twoHundredDayAverageChange,
  Return_Proxy = (currentPrice - fiftyTwoWeekLowChangePercent) / fiftyTwoWeekLowChangePercent
)]
All_Sectors_Capital[, Excess_Return_Proxy := Return_Proxy - SandP52WeekChange]

# 3. MERGE this with your Future Returns data to create Quant_DF
# (Assuming All_Future_Growth is your stacked Future Returns tables)
Quant_DF = merge(All_Sectors_Capital, All_Future_Growth, by = "Symbol")
# The Regression using actual values from your Future Returns data
setnames(Quant_DF, "Sector.x", "Sector")
Quant_DF[, Sector.y := NULL] 

# Now the original code will work perfectly
quant_growth_lm = lm(Excess_Return_Proxy ~ revenueGrowth + earningsGrowth + Sector, 
                     data = Quant_DF)
#This model explains the relationship between excess return, revenue and earnings growth.
#It analyses whether financial health predicts stock performance.
#That we'll be able to tell whether revenue/earning growth are safe measures for prediction analysis.
summary(quant_growth_lm)
# View the Beta coefficients

# Check for extreme skewness in predictors
hist(Quant_DF$earningsGrowth, breaks = 50, main = "Earnings Growth Dist")

# If it's as skewed as the PEG ratio, consider a 'Robust' Regression
quant_robust <- rlm(Excess_Return_Proxy ~ revenueGrowth + earningsGrowth + Sector, 
                    data = Quant_DF)
summary(quant_robust)

# ====================================================================================================================
#                               INTERPRETATION: QUANT GROWTH & EXCESS RETURNS
# ====================================================================================================================

# 1. PREDICTIVE POWER OF GROWTH METRICS
# ------------------------------------
# - The model 'quant_growth_lm' tests if current market outperformance (Excess_Return_Proxy) 
#   is fundamentally anchored in Revenue and Earnings Growth.
# - revenueGrowth: Measures the "top-line" expansion. If significant, it indicates that the 
#   market rewards market-share expansion.
# - earningsGrowth: Measures "bottom-line" efficiency. If this coefficient is higher than 
#   revenue growth, it suggests the market prioritizes profitability over raw scale.

# 2. SECTOR AS A FIXED EFFECT
# ---------------------------
# - By including 'Sector' in the regression, you are controlling for the "average" return 
#   of each industry. 
# - This ensures that the growth coefficients aren't biased by one high-performing sector 
#   (e.g., Technology) and instead represent a broader market truth.

# 3. ROBUSTNESS VS. OUTLIERS (LM vs. RLM)
# ---------------------------------------
# - The histogram for 'earningsGrowth' likely shows extreme right-skewness (long tail), 
#   typical of "turnaround" stocks or small-cap growth companies.
# - LM (Linear Model): Highly sensitive to outliers. A few stocks with 500% growth but 
#   mediocre returns can "drag" the regression line and mask the true trend.
# - RLM (Robust Linear Model): Down-weights extreme outliers. 
#   - If RLM coefficients remain significant: The growth-return relationship is a reliable 
#     market fundamental.
#   - If RLM coefficients disappear: The perceived relationship in the standard LM was 
#     likely an illusion caused by a handful of "moonshot" stocks.

# 4. INVESTMENT IMPLICATIONS
# --------------------------
# - Reliable Predictors: If the p-values for revenue/earnings growth are < 0.05, these 
#   metrics are "safe" measures for predictive analysis in your portfolio strategy.
# - Speculative Predictors: If only the LM shows significance while the RLM does not, 
#   relying on growth metrics alone is risky, as success is concentrated in rare 
#   outlier events rather than a repeatable trend.

# 5. DATA QUALITY NOTE
# --------------------
# - The merge between 'All_Sectors_Capital' and 'All_Future_Growth' using 'Symbol' 
#   is the backbone of this analysis. 
# - Ensure that any 'NA' values in earningsGrowth (common for loss-making companies) 
#   are handled, as they can drop significant portions of your sample size during 
#   the regression.
# ====================================================================================================================