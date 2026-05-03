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

# Create a list of all your sector capital tables
sector_list = list(
  Basic_Materials = BasicMat_Capital, Communication_Serv = CommServ_Capital,
  Consumer_Cycle = ConsCycl_Capital, Consumer_Defense = ConsDef_Capital,
  Energy = Ener_Capital, Financial_Serv = FinServ_Capital,
  Healthcare = HealCare_Capital, Industrials = Indust_Capital,
  Real_Estate = RealEst_Capital, Technology = Tech_Capital,
  Utilities = Utility_Capital
)

sector_list2 = list(
  Basic_Materials = BasicMat_ManagementEff, Communication_Serv = CommServ_ManagementEff,
  Consumer_Cycle = ConsCycl_ManagementEff, Consumer_Defense = ConsDef_ManagementEff,
  Energy = Ener_ManagementEff, Financial_Serv = FinServ_ManagementEff,
  Healthcare = HealCare_ManagementEff, Industrials = Indust_ManagementEff,
  Real_Estate = RealEst_ManagementEff, Technology = Tech_ManagementEff,
  Utilities = Utility_ManagementEff
)


# Combine them into one dataframe and keep the Sector name as a column
All_Sectors_Capital = rbindlist(sector_list, idcol = "Sector")

capital_df <- imap_dfr(sector_list, ~ .x %>% mutate(Sector = .y))
management_df <- imap_dfr(sector_list2, ~ .x %>% mutate(Sector = .y))
Metrics_Table <- full_join(capital_df, management_df, by = c("Symbol", "Sector"))
colnames(Metrics_Table) <- make.names(colnames(Metrics_Table))

# Check the result
head(Metrics_Table)

#write.csv(Metrics_Table, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Metrics_Table.csv",
#          row.names = FALSE)
# Calculate Momentum and Returns for the entire market at once
All_Sectors_Capital[, `:=`(
  Stock_Momentum = (currentPrice - twoHundredDayAverageChange) / twoHundredDayAverageChange,
  Return_Proxy = (currentPrice - fiftyTwoWeekLowChangePercent) / fiftyTwoWeekLowChangePercent
)]
write.csv(All_Sectors_Capital, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\All_Sectors_Capital.csv",
          row.names = FALSE)
# Calculate Excess Return Proxy
All_Sectors_Capital[, Excess_Return_Proxy := Return_Proxy - SandP52WeekChange]
#Does the effect of momentum on returns change depending on which sector you are in?
# The '*' creates an interaction between Momentum and Sector
sector_interaction_lm = lm(Excess_Return_Proxy ~ Stock_Momentum * Sector, data = All_Sectors_Capital)
summary(sector_interaction_lm)
ggplot(All_Sectors_Capital, aes(x = Stock_Momentum, y = Excess_Return_Proxy, color = Sector)) +
  geom_point(alpha = 0.4) +
  geom_smooth(method = "lm", se = FALSE) + # Adds a regression line for EACH sector
  theme_minimal() +
  labs(title = "Momentum vs Excess Return: Cross-Sector Comparison",
       x = "Stock Momentum",
       y = "Excess Return Proxy")

summary(sector_interaction_lm)
# ====================================================================================================================
#                                          INTERPRETATION: momentum_vs_excessReturns.png
# ====================================================================================================================

# 1. THE "BIG PICTURE" INTERPRETATION
# ----------------------------------
# The chart "momentum_vs_excessReturns.png" shows a weak and highly inconsistent relationship between 
# Stock Momentum and Excess Return across the market. While the standard "Momentum Factor" theory 
# suggests a positive slope, this plot reveals a chaotic distribution with significant sector-based anomalies.

# 2. SECTOR-SPECIFIC OBSERVATIONS
# ------------------------------

# Healthcare (Light Blue): 
# - Exhibits the most dramatic vertical spikes in the plot.
# - Suggests "jump" returns (e.g., biotech trial results or FDA approvals) that occur 
#   independently of the 200-day momentum trend.

# Basic Materials (Red): 
# - Shows a notable negative slope.
# - Interpretation: As momentum increases, the excess return proxy actually decreases. 
# - This reflects classic cyclical behavior where high momentum signals a cycle peak rather than continued growth.

# Industrials & Real Estate (Darker Blue/Purple): 
# - These regression lines appear flatter or slightly negative.
# - High momentum in these sectors may act as a "mean reversion" or "overbought" signal 
#   rather than a predictor of future excess returns.

# 3. STATISTICAL & MODEL IMPLICATIONS
# -----------------------------------

# Interaction Effects:
# - The diverging slopes for different colors confirm that Sector membership is a 
#   significant moderator. You cannot use a "one-size-fits-all" momentum strategy.
# - The interaction term (Stock_Momentum * Sector) in your 'sector_interaction_lm' 
#   is likely the most critical variable in the output.

# R-Squared and Noise:
# - Given the massive vertical spread of data points (residuals) in the png, 
#   the model likely has a low R-squared. 
# - Momentum alone is not explaining the majority of the variance in excess returns here.

# 4. RECOMMENDATIONS FOR REFINEMENT
# ---------------------------------

# Data Scaling/Cleaning:
# - The axes (X up to 2000, Y up to 20,000) suggest extreme outliers are skewing the visual.
# - These are often caused by "penny stocks" or low-denominator price moves.
# - Strategy: Consider Winsorizing the data or filtering for a minimum Market Cap 
#   (e.g., > $200M) to remove noise and see the true sector trends more clearly.

# ====================================================================================================================
#                                               END OF INTERPRETATION
# ====================================================================================================================