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
library(ggridges)
library(dplyr)
library(tidyverse)
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


# ============================================================
# METHOD OF ANALYSIS: ONE-FACTOR ANOVA (Treatment Effects Model)
# 
# Objective: Compare dividend yield means across S&P 500 sectors
# to identify whether any sector significantly outperforms the broader market.
#
# Pipeline:
#   1. Reshape data to long format
#   2. Test normality  -> Kruskal-Wallis (non-parametric)
#   3. Test variance homogeneity -> Levene's Test
#   4. If heteroscedastic: apply log1p transform, re-test
#   5. Welch's ANOVA (robust to unequal variances)
#   6. Post-hoc pairwise: Games-Howell Test
#   7. Visualise sector log-means vs. grand mean
# ============================================================


# ---- 1. BUILD & EXPORT DIVIDEND YIELD DATA ------------------

divYield = as.data.frame(cbind(
  Basic_Materials      = BasicMat_IM$dividendYield,
  Communication_Serv   = CommServ_IM$dividendYield,
  Consumer_Cycle       = ConsCycl_IM$dividendYield,
  Consumer_Defense     = ConsDef_IM$dividendYield,
  Energy               = ENER_IM$dividendYield,
  Financial_Serv       = FinServ_IM$dividendYield,
  Healthcare           = HealthCare_IM$dividendYield,
  Industrials          = Indust_IM$dividendYield,
  Real_Estate          = RealEst_IM$dividendYield,
  Technology           = Tech_IM$dividendYield,
  Utilities            = Utility_IM$dividendYield
))

sectors_List = as.data.frame(cbind(
  Basic_Materials      = BasicMat_IM$Symbol,
  Communication_Serv   = CommServ_IM$Symbol,
  Consumer_Cycle       = ConsCycl_IM$Symbol,
  Consumer_Defense     = ConsDef_IM$Symbol,
  Energy               = ENER_IM$Symbol,
  Financial_Serv       = FinServ_IM$Symbol,
  Healthcare           = HealthCare_IM$Symbol,
  Industrials          = Indust_IM$Symbol,
  Real_Estate          = RealEst_IM$Symbol,
  Technology           = Tech_IM$Symbol,
  Utilities            = Utility_IM$Symbol
))
#==============================================================================
#RDS
#==============================================================================


# 1. Initialize the master list
Sector_IM_Data <- list()

# 2. Loop through each sector (column) in your sectors_list dataframe
for (sector_name in colnames(sectors_List)) {
  
  # Get unique tickers for the CURRENT sector in the loop
  # We use na.omit to ensure we don't try to query a 'blank' table
  current_tickers <- na.omit(unique(sectors_List[[sector_name]]))
  
  # Create the sub-list for this sector
  Sector_IM_Data[[sector_name]] <- list()
  
  # 3. Load each ticker's dataframe INTO the list
  for (ticker in current_tickers) {
    if(ticker != "") {
      # Use backticks `` for MySQL reserved words like 'ALL'
      query <- paste0("SELECT * FROM `", ticker, "`")
      
      # SUCCESS KEY: Assign the data directly to the list slot
      Sector_IM_Data[[sector_name]][[ticker]] <- dbGetQuery(connect, query)
    }
  }
}

# Now this will work because Sector_IM_Data is actually full of dataframes!
all_summaries <- lapply(Sector_IM_Data, function(sector) {
  lapply(sector, summary)
})


write.csv(divYield,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\DividendYields.csv",
          row.names = FALSE)

write.csv(sectors_List, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Sectors_List_DY.csv", row.names = FALSE)
# ---- 2. RESHAPE TO LONG FORMAT ------------------------------

data_long <- pivot_longer(divYield,
                          cols      = everything(),
                          names_to  = "Sector",
                          values_to = "Yield")
Sects = cbind(data_long$Sector)
colnames(Sects) = c("Sector")
write.csv(Sects, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Sectors_Names.csv", row.names = FALSE)
# ---- 3. NON-PARAMETRIC TEST (RAW YIELDS) --------------------
# Kruskal-Wallis: tests whether sector yield distributions share the same median.
# H0: All sector medians are equal.

kruskal_result <- kruskal.test(Yield ~ Sector, data = data_long)
print(kruskal_result)

# Post-hoc pairwise comparisons (Holm correction for familywise error)
dunn_result <- dunnTest(Yield ~ Sector, data = data_long, method = "holm")
print(dunn_result)





# ---- 4. NORMALITY DIAGNOSTICS (RAW YIELDS) ------------------

par(mfrow = c(1, 2))
qqnorm(data_long$Yield, main = "Q-Q Plot: Raw Dividend Yields")
qqline(data_long$Yield, col = "blue", lwd = 2, lty = 2)
hist(data_long$Yield,
     main  = "Distribution: Raw Dividend Yields",
     xlab  = "Yield",
     col   = "steelblue",
     border = "white")
par(mfrow = c(1, 1))
# Result: Non-normal distribution confirmed by Q-Q plot and histogram skew.


# ---- 5. HOMOGENEITY OF VARIANCE (RAW YIELDS) ----------------
# Levene's Test: H0 = equal variances across sectors.

leveneTest(Yield ~ Sector, data = data_long)
# Result: p < 0.05 -> heteroscedasticity present; log-transform required.


# ---- 6. LOG TRANSFORMATION & RE-DIAGNOSTICS -----------------

data_long$LogYield <- log1p(data_long$Yield)

par(mfrow = c(1, 2))
qqnorm(data_long$LogYield, main = "Q-Q Plot: Log Dividend Yields")
qqline(data_long$LogYield, col = "red", lwd = 2, lty = 2)
hist(data_long$LogYield,
     main   = "Distribution: Log Dividend Yields",
     xlab   = "log1p(Yield)",
     col    = "tomato",
     border = "white")
par(mfrow = c(1, 1))

# Re-test variance homogeneity on transformed data
leveneTest(LogYield ~ Sector, data = data_long)


# ---- 7. WELCH'S ONE-WAY ANOVA (LOG YIELDS) ------------------
# Used in place of classic ANOVA given persistent heteroscedasticity.
# H0: All sector log-mean yields are equal.

welch_log <- oneway.test(LogYield ~ Sector, data = data_long, var.equal = FALSE)
print(welch_log)
# Result: p < 0.05 -> at least one sector mean differs significantly.


# ---- 8. POST-HOC: GAMES-HOWELL TEST -------------------------
# Appropriate for unequal variances and sample sizes.

gh_test_yield <- games_howell_test(data_long, LogYield ~ Sector)
print(gh_test_yield, n = 20)


# ---- 9. VISUALISE: SECTOR MEANS vs. GRAND MEAN --------------

grand_mean_log <- mean(data_long$LogYield)

ggplot(data_long, aes(x = reorder(Sector, LogYield, FUN = mean), y = LogYield)) +
  stat_summary(fun = mean, geom = "point", size = 4, colour = "steelblue") +
  stat_summary(fun = mean, geom = "errorbar",
               fun.min = mean, fun.max = mean,
               width = 0.5, colour = "steelblue", linewidth = 0.6) +
  geom_hline(yintercept = grand_mean_log,
             linetype = "dashed", colour = "red", linewidth = 0.9) +
  coord_flip() +
  labs(
    title    = "Sector Log-Mean Dividend Yields vs. Grand Mean",
    subtitle = "Red dashed line = Grand Mean  |  Points = Sector Log-Means",
    x        = NULL,
    y        = "log1p(Dividend Yield)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title    = element_text(face = "bold"),
    plot.subtitle = element_text(colour = "grey50"),
    panel.grid.minor = element_blank()
  )

# ---- INTERPRETATION ------------------------------------------
# Sectors with log-means above the grand mean offer superior cash-yield profiles
# relative to the broader S&P 500 universe:
#   -> Real Estate, Utilities, Energy, Consumer Defense, Financial Services
# These sectors return more immediate income per dollar invested than average.


raw_data <- read.csv("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\Sector_Peg_Ratios.csv")

# 2. Transform the data
# We remove the index column, pivot the sectors into a single column, 
# and then calculate the mean for each group.
peg_summary <- raw_data %>%
  select(-1) %>% # Removes the first 'Unnamed' index column
  pivot_longer(
    cols = everything(), 
    names_to = "Sector", 
    values_to = "PEG_Ratio"
  ) %>%
  group_by(Sector) %>%
  summarise(
    Average_PEG_Ratio = mean(PEG_Ratio, na.rm = TRUE)
  ) %>%
  arrange(Sector) # Keeps sectors in alphabetical order

# 3. View the result to ensure it's correct
print(peg_summary)

# 4. Save the summarized data for Tableau
write.csv(peg_summary, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\PEG_Summary_Tableau.csv", row.names = FALSE)


# Load libraries
library(tidyverse)

# 1. Read the raw Dividend Yield data
yield_raw <- read.csv("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\DividendYields.csv")

# 2. Reshape, Calculate Mean, and Filter Top 5
top_5_yields <- yield_raw %>%
  pivot_longer(
    cols = everything(), 
    names_to = "Sector", 
    values_to = "Yield"
  ) %>%
  group_by(Sector) %>%
  summarise(
    Avg_Dividend_Yield = mean(Yield, na.rm = TRUE)
  ) %>%
  # Slice the top 5 highest yields
  slice_max(Avg_Dividend_Yield, n = 5) %>%
  arrange(desc(Avg_Dividend_Yield))

# 3. Save for Tableau
write.csv(top_5_yields, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\Top_5_Yield_Summary.csv", row.names = FALSE)


# 1. Read the raw Dividend Yield data
yield_raw <- read.csv("C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\DividendYields.csv")

# 2. Reshape and Calculate Mean for ALL sectors
full_yield_summary <- yield_raw %>%
  pivot_longer(
    cols = everything(), 
    names_to = "Sector", 
    values_to = "Yield"
  ) %>%
  group_by(Sector) %>%
  summarise(
    Avg_Dividend_Yield = mean(Yield, na.rm = TRUE)
  ) %>%
  arrange(desc(Avg_Dividend_Yield)) # Sorted for easier validation

# 3. Save for the Treemap
write.csv(full_yield_summary, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\Full_Sector_Yield_Summary.csv", row.names = FALSE)