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

# ============================================================
# RISK-ADJUSTED RETURN METRICS: ONE-FACTOR ANOVA ANALYSIS
#
# Metrics analysed:
#   1. Beta                (market sensitivity)
#   2. Trailing PEG Ratio  (growth-adjusted valuation)
#
# Pipeline (applied to each metric):
#   1. Build wide-format data frame & export
#   2. Reshape to long format
#   3. Kruskal-Wallis (non-parametric distribution test)
#   4. Normality diagnostics (Q-Q + histogram)
#   5. log1p transform -> re-diagnose
#   6. Levene's test for homogeneity of variance
#   7. Welch's one-way ANOVA (robust to unequal variances)
#   8. Visualise sector log-means vs. grand mean
# ============================================================


# ==============================================================
# METRIC 1: BETA
# ==============================================================

# ---- 1.1 Build & Export -----------------------------------------

Beta <- as.data.frame(cbind(
  Basic_Materials    = BasicMat_AdjReturns$beta,
  Communication_Serv = CommServ_AdjReturns$beta,
  Consumer_Cycle     = ConsCycl_AdjReturns$beta,
  Consumer_Defense   = ConsDef_AdjReturns$beta,
  Energy             = Ener_AdjReturns$beta,
  Financial_Serv     = FinServ_AdjReturns$beta,
  Healthcare         = HealCare_AdjReturns$beta,
  Industrials        = Indust_AdjReturns$beta,
  Real_Estate        = RealEst_AdjReturns$beta,
  Technology         = Tech_AdjReturns$beta,
  Utilities          = Utility_AdjReturns$beta
))

write.csv(Beta,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Beta.csv",
          row.names = FALSE)

# ---- 1.2 Reshape ------------------------------------------------

beta_long <- pivot_longer(Beta,
                          cols      = everything(),
                          names_to  = "Sector",
                          values_to = "Beta")
beta_long$Sector <- as.factor(beta_long$Sector)

# ---- 1.3 Kruskal-Wallis (Raw) ----------------------------------
# H0: All sector Beta distributions share the same median.

kruskal_result_beta <- kruskal.test(Beta ~ Sector, data = beta_long)
print(kruskal_result_beta)

# ---- 1.4 Normality Diagnostics (Raw) ---------------------------

par(mfrow = c(1, 2))
qqnorm(beta_long$Beta, main = "Q-Q Plot: Raw Beta")
qqline(beta_long$Beta, col = "blue", lwd = 2, lty = 2)
hist(beta_long$Beta,
     main = "Distribution: Raw Beta", xlab = "Beta",
     col = "steelblue", border = "white")
par(mfrow = c(1, 1))

# ---- 1.5 Log Transform & Re-Diagnostics ------------------------

beta_long$LogBeta <- log1p(beta_long$Beta)

par(mfrow = c(1, 2))
qqnorm(beta_long$LogBeta, main = "Q-Q Plot: Log Beta")
qqline(beta_long$LogBeta, col = "red", lwd = 2, lty = 2)
hist(beta_long$LogBeta,
     main = "Distribution: Log Beta", xlab = "log1p(Beta)",
     col = "tomato", border = "white")
par(mfrow = c(1, 1))

# ---- 1.6 Levene's Test (Raw) ------------------------------------
# H0: Equal variances across sectors.

leveneTest(Beta ~ Sector, data = beta_long)
# Result: inspect p-value; if p < 0.05, Welch's ANOVA is appropriate.

# ---- 1.7 Welch's One-Way ANOVA (Log Beta) ----------------------
# Robust to heteroscedasticity; does not assume equal group variances.

welch_beta_model <- oneway.test(LogBeta ~ Sector, data = beta_long, var.equal = FALSE)
print(welch_beta_model)

# ---- 1.8 Visualise: Sector Means vs. Grand Mean ----------------

grand_mean_beta <- mean(beta_long$LogBeta)

ggplot(beta_long, aes(x = reorder(Sector, LogBeta, FUN = mean), y = LogBeta)) +
  stat_summary(fun = mean, geom = "point", size = 4, colour = "steelblue") +
  stat_summary(fun = mean, geom = "errorbar",
               fun.min = mean, fun.max = mean,
               width = 0.5, colour = "steelblue", linewidth = 0.6) +
  geom_hline(yintercept = grand_mean_beta,
             linetype = "dashed", colour = "red", linewidth = 0.9) +
  coord_flip() +
  labs(
    title    = "Sector Log-Mean Beta vs. Grand Mean",
    subtitle = "Red dashed line = Grand Mean  |  Points = Sector Log-Means",
    x        = NULL,
    y        = "log1p(Beta)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold"),
    plot.subtitle    = element_text(colour = "grey50"),
    panel.grid.minor = element_blank()
  )


# ==============================================================
# METRIC 2: TRAILING PEG RATIO
# ==============================================================

# ---- 2.1 Build & Export -----------------------------------------

PegRatio <- as.data.frame(cbind(
  Basic_Materials    = BasicMat_AdjReturns$trailingPegRatio,
  Communication_Serv = CommServ_AdjReturns$trailingPegRatio,
  Consumer_Cycle     = ConsCycl_AdjReturns$trailingPegRatio,
  Consumer_Defense   = ConsDef_AdjReturns$trailingPegRatio,
  Energy             = Ener_AdjReturns$trailingPegRatio,
  Financial_Serv     = FinServ_AdjReturns$trailingPegRatio,
  Healthcare         = HealCare_AdjReturns$trailingPegRatio,
  Industrials        = Indust_AdjReturns$trailingPegRatio,
  Real_Estate        = RealEst_AdjReturns$trailingPegRatio,
  Technology         = Tech_AdjReturns$trailingPegRatio,
  Utilities          = Utility_AdjReturns$trailingPegRatio
))

write.csv(PegRatio,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\PegRatio.csv",
          row.names = FALSE)

# ---- 2.2 Reshape ------------------------------------------------

peg_long <- pivot_longer(PegRatio,
                         cols      = everything(),
                         names_to  = "Sector",
                         values_to = "TrailingPegRatio")
peg_long$Sector <- as.factor(peg_long$Sector)

# ---- 2.3 Kruskal-Wallis (Raw) ----------------------------------
# H0: All sector PEG Ratio distributions share the same median.

kruskal_result_peg <- kruskal.test(TrailingPegRatio ~ Sector, data = peg_long)
print(kruskal_result_peg)

# ---- 2.4 Normality Diagnostics (Raw) ---------------------------

par(mfrow = c(1, 2))
qqnorm(peg_long$TrailingPegRatio, main = "Q-Q Plot: Raw Trailing PEG Ratio")
qqline(peg_long$TrailingPegRatio, col = "blue", lwd = 2, lty = 2)
hist(peg_long$TrailingPegRatio,
     main = "Distribution: Raw Trailing PEG Ratio", xlab = "PEG Ratio",
     col = "steelblue", border = "white")
par(mfrow = c(1, 1))

# ---- 2.5 Log Transform & Re-Diagnostics ------------------------

peg_long$LogPEG <- log1p(peg_long$TrailingPegRatio)
write.csv(PegRatio, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\Viz_Page_1\\Sector_Peg_Ratios.csv")
par(mfrow = c(1, 2))
qqnorm(peg_long$LogPEG, main = "Q-Q Plot: Log Trailing PEG Ratio")
qqline(peg_long$LogPEG, col = "red", lwd = 2, lty = 2)
hist(peg_long$LogPEG,
     main = "Distribution: Log Trailing PEG Ratio", xlab = "log1p(PEG Ratio)",
     col = "tomato", border = "white")
par(mfrow = c(1, 1))

# ---- 2.6 Levene's Test (Log) ------------------------------------

leveneTest(LogPEG ~ Sector, data = peg_long)
# Result: p < 0.05 -> heteroscedasticity confirmed; Welch's ANOVA appropriate.

# ---- 2.7 Welch's One-Way ANOVA (Log PEG) -----------------------

welch_peg_model <- oneway.test(LogPEG ~ Sector, data = peg_long, var.equal = FALSE)
print(welch_peg_model)

# ---- 2.8 Visualise: Sector Means vs. Grand Mean ----------------

grand_mean_peg <- mean(peg_long$LogPEG)

ggplot(peg_long, aes(x = reorder(Sector, LogPEG, FUN = mean), y = LogPEG)) +
  stat_summary(fun = mean, geom = "point", size = 4, colour = "steelblue") +
  stat_summary(fun = mean, geom = "errorbar",
               fun.min = mean, fun.max = mean,
               width = 0.5, colour = "steelblue", linewidth = 0.6) +
  geom_hline(yintercept = grand_mean_peg,
             linetype = "dashed", colour = "red", linewidth = 0.9) +
  coord_flip() +
  labs(
    title    = "Sector Log-Mean Trailing PEG Ratio vs. Grand Mean",
    subtitle = "Red dashed line = Grand Mean  |  Points = Sector Log-Means",
    x        = NULL,
    y        = "log1p(Trailing PEG Ratio)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold"),
    plot.subtitle    = element_text(colour = "grey50"),
    panel.grid.minor = element_blank()
  )

# ====================================================================================================================
#                               INTERPRETATION: Risk-Adjusted Returns - BETA
# ====================================================================================================================

# 1. DISTRIBUTIONAL CHARACTERISTICS
# ---------------------------------
# - Raw Beta values typically cluster around 1.0, but extreme outliers (high-volatility stocks) 
#   create a "heavy-tailed" distribution in your raw Q-Q plots.
# - Log transformation (log1p) was applied to normalize the spread, though financial data 
#   often retains some "kurtosis" (peakedness) even after transformation.

# 2. SECTOR SENSITIVITY HIERARCHY
# ------------------------------
# - Higher than Grand Mean: High-Beta sectors like Technology and Consumer Cyclical likely 
#   sit at the top of the chart. These sectors amplify market moves (Aggressive).
# - Lower than Grand Mean: Defensive sectors like Utilities and Consumer Defense (Staples) 
#   should appear at the bottom. These provide a "buffer" during market downturns.
# - Validation: If Welch's ANOVA (oneway.test) returns p < 0.05, it statistically confirms 
#   that sector membership is a primary driver of stock volatility.

# 3. STATISTICAL JUSTIFICATION
# ----------------------------
# - Levene's Test likely failed (p < 0.05), indicating that "High Beta" sectors are also 
#   "High Variance" sectors (their Beta values are more spread out).
# - Welch's ANOVA is the correct choice here as it doesn't assume that the variance of 
#   Utilities is the same as the variance of Tech.# ====================================================================================================================
#                               INTERPRETATION: Risk-Adjusted Returns - BETA
# ====================================================================================================================

# 1. DISTRIBUTIONAL CHARACTERISTICS
# ---------------------------------
# - Raw Beta values typically cluster around 1.0, but extreme outliers (high-volatility stocks) 
#   create a "heavy-tailed" distribution in your raw Q-Q plots.
# - Log transformation (log1p) was applied to normalize the spread, though financial data 
#   often retains some "kurtosis" (peakedness) even after transformation.

# 2. SECTOR SENSITIVITY HIERARCHY
# ------------------------------
# - Higher than Grand Mean: High-Beta sectors like Technology and Consumer Cyclical likely 
#   sit at the top of the chart. These sectors amplify market moves (Aggressive).
# - Lower than Grand Mean: Defensive sectors like Utilities and Consumer Defense (Staples) 
#   should appear at the bottom. These provide a "buffer" during market downturns.
# - Validation: If Welch's ANOVA (oneway.test) returns p < 0.05, it statistically confirms 
#   that sector membership is a primary driver of stock volatility.

# 3. STATISTICAL JUSTIFICATION
# ----------------------------
# - Levene's Test likely failed (p < 0.05), indicating that "High Beta" sectors are also 
#   "High Variance" sectors (their Beta values are more spread out).
# - Welch's ANOVA is the correct choice here as it doesn't assume that the variance of 
#   Utilities is the same as the variance of Tech.

# ====================================================================================================================
#                               INTERPRETATION: Risk-Adjusted Returns - PEG RATIO
# ====================================================================================================================

# 1. GROWTH-ADJUSTED PRICING
# --------------------------
# - The Trailing PEG Ratio adjusts P/E for historical growth. A value of 1.0 is often 
#   considered "fair value."
# - Your "Sector Log-Mean PEG" plot identifies which sectors are paying a premium for growth.

# 2. SECTOR COMPARISON
# --------------------
# - Premium Sectors: Real Estate or Healthcare may show higher log-mean PEG ratios, 
#   suggesting investors are paying more per unit of growth (potentially overvalued or 
#   low-growth/high-dividend profile).
# - Value Sectors: Energy or Financials often show lower PEG ratios, potentially indicating 
#   "undervaluation" or high cyclical growth that the market hasn't fully priced in.

# 3. THE "GRAND MEAN" AS A VALUATION ANCHOR
# -----------------------------------------
# - The red dashed line represents the market's average "cost of growth." 
# - Sectors significantly below this line offer better growth-adjusted value, while 
#   those above it are priced for perfection.
# - The use of log1p is critical here because PEG ratios can be highly volatile or 
#   undefined for companies with near-zero growth.

# 4. ROBUSTNESS CHECK
# -------------------
# - The Kruskal-Wallis test (Section 2.3) acts as a "sanity check." Since it tests medians 
#   rather than means, it proves that sector differences exist regardless of how much 
#   weight you give to extreme outliers.