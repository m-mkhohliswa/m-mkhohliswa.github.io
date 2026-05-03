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
library(nlme)
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
# MANAGEMENT EFFICIENCY METRICS: ONE-FACTOR ANOVA ANALYSIS
#
# Metrics analysed:
#   1. Return on Equity  (ROE)
#   2. Return on Assets  (ROA)
#   3. Profit Margins    (PM)
#
# Pipeline (applied to each metric):
#   1. Build wide-format data frame & export
#   2. Reshape to long format
#   3. Kruskal-Wallis + Dunn post-hoc (non-parametric)
#   4. Normality diagnostics (Q-Q + histogram)
#   5. Levene's test for homogeneity of variance
#   6. log1p transform -> re-diagnose
#   7. ANOVA model (GLM or GLS depending on variance structure)
#   8. Residual diagnostics & visualisation
# ============================================================


# ---- HELPER: SECTOR COLUMN NAMES ----------------------------

SECTOR_NAMES <- c(
  "Basic_Materials", "Communication_Serv", "Consumer_Cycle",
  "Consumer_Defense", "Energy", "Financial_Serv", "Healthcare",
  "Industrials", "Real_Estate", "Technology", "Utilities"
)


# ==============================================================
# METRIC 1: RETURN ON EQUITY (ROE)
# ==============================================================

# ---- 1.1 Build & Export -----------------------------------------

ROEs <- as.data.frame(cbind(
  Basic_Materials    = BasicMat_ManagementEff$returnOnEquity,
  Communication_Serv = CommServ_ManagementEff$returnOnEquity,
  Consumer_Cycle     = ConsCycl_ManagementEff$returnOnEquity,
  Consumer_Defense   = ConsDef_ManagementEff$returnOnEquity,
  Energy             = Ener_ManagementEff$returnOnEquity,
  Financial_Serv     = FinServ_ManagementEff$returnOnEquity,
  Healthcare         = HealCare_ManagementEff$returnOnEquity,
  Industrials        = Indust_ManagementEff$returnOnEquity,
  Real_Estate        = RealEst_ManagementEff$returnOnEquity,
  Technology         = Tech_ManagementEff$returnOnEquity,
  Utilities          = Utility_ManagementEff$returnOnEquity
))

write.csv(ROEs,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\ROEs.csv",
          row.names = FALSE)

# ---- 1.2 Reshape ------------------------------------------------

ROE_long <- pivot_longer(ROEs,
                         cols      = everything(),
                         names_to  = "Sector",
                         values_to = "ReturnOnEquity")
ROE_long$Sector <- as.factor(ROE_long$Sector)

write.csv(ROE_long, "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\ROE_long.csv", row.names = FALSE)
# ---- 1.3 Kruskal-Wallis & Dunn Post-Hoc (Raw) ------------------

kruskal_result_ROE <- kruskal.test(ReturnOnEquity ~ Sector, data = ROE_long)
print(kruskal_result_ROE)

dunn_result_ROE <- dunnTest(ReturnOnEquity ~ Sector, data = ROE_long, method = "holm")
print(dunn_result_ROE)

# ---- 1.4 Normality Diagnostics (Raw) ---------------------------

par(mfrow = c(1, 2))
qqnorm(ROE_long$ReturnOnEquity, main = "Q-Q Plot: Raw ROE")
qqline(ROE_long$ReturnOnEquity, col = "blue", lwd = 2, lty = 2)
hist(ROE_long$ReturnOnEquity,
     main = "Distribution: Raw ROE", xlab = "ROE",
     col = "steelblue", border = "white")
par(mfrow = c(1, 1))

# ---- 1.5 Levene's Test (Raw) ------------------------------------

leveneTest(ReturnOnEquity ~ Sector, data = ROE_long)
# Result: inspect p-value for heteroscedasticity

# ---- 1.6 Log Transform & Re-Diagnostics ------------------------

ROE_long$LogROE <- log1p(ROE_long$ReturnOnEquity)

par(mfrow = c(1, 2))
qqnorm(ROE_long$LogROE, main = "Q-Q Plot: Log ROE")
qqline(ROE_long$LogROE, col = "red", lwd = 2, lty = 2)
hist(ROE_long$LogROE,
     main = "Distribution: Log ROE", xlab = "log1p(ROE)",
     col = "tomato", border = "white")
par(mfrow = c(1, 1))

# ---- 1.7 GLM ANOVA (No Intercept -> Sector Means) ---------------
# GLM with Gaussian family fits sector-level means directly.

roe_model <- glm(LogROE ~ -1 + Sector, family = gaussian, data = ROE_long)
summary(roe_model)

# ---- 1.8 Residual Diagnostics ----------------------------------

par(mfrow = c(1, 2))
plot(residuals(roe_model) ~ fitted(roe_model),
     xlab = expression(hat(y)[i]),
     ylab = expression(r[i]),
     main = "Residuals vs. Fitted (ROE)")
abline(h = 0, col = "red", lty = 2)
plot(roe_model, which = 2)   # Normal Q-Q of residuals
par(mfrow = c(1, 1))

plot(roe_model, which = 4)   # Cook's Distance - influential points

ROE_long$resids <- residuals(roe_model)

ggplot(ROE_long, aes(x = Sector, y = resids)) +
  geom_jitter(width = 0.2, alpha = 0.4, colour = "steelblue") +
  geom_hline(yintercept = 0, colour = "red", linetype = "dashed") +
  labs(
    title = "Residuals by Sector: ROE",
    x     = NULL,
    y     = "Residuals (log ROE)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    axis.text.x      = element_text(angle = 45, hjust = 1),
    panel.grid.minor = element_blank()
  )


# ==============================================================
# METRIC 2: RETURN ON ASSETS (ROA)
# ==============================================================

# ---- 2.1 Build & Export -----------------------------------------

ROAs <- as.data.frame(cbind(
  Basic_Materials    = BasicMat_ManagementEff$returnOnAssets,
  Communication_Serv = CommServ_ManagementEff$returnOnAssets,
  Consumer_Cycle     = ConsCycl_ManagementEff$returnOnAssets,
  Consumer_Defense   = ConsDef_ManagementEff$returnOnAssets,
  Energy             = Ener_ManagementEff$returnOnAssets,
  Financial_Serv     = FinServ_ManagementEff$returnOnAssets,
  Healthcare         = HealCare_ManagementEff$returnOnAssets,
  Industrials        = Indust_ManagementEff$returnOnAssets,
  Real_Estate        = RealEst_ManagementEff$returnOnAssets,
  Technology         = Tech_ManagementEff$returnOnAssets,
  Utilities          = Utility_ManagementEff$returnOnAssets
))

write.csv(ROAs,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\ROAs.csv",
          row.names = FALSE)

# ---- 2.2 Reshape ------------------------------------------------

ROA_long <- pivot_longer(ROAs,
                         cols      = everything(),
                         names_to  = "Sector",
                         values_to = "ReturnOnAssets")
ROA_long$Sector <- as.factor(ROA_long$Sector)
write.csv(ROA_long,"C:\\Users\\musam\\Portfolio_Analysis\\data_files\\ROA_long.csv", row.names = FALSE)

# ---- 2.3 Kruskal-Wallis & Dunn Post-Hoc (Raw) ------------------

kruskal_result_ROA <- kruskal.test(ReturnOnAssets ~ Sector, data = ROA_long)
print(kruskal_result_ROA)

dunn_result_ROA <- dunnTest(ReturnOnAssets ~ Sector, data = ROA_long, method = "holm")
print(dunn_result_ROA)

# ---- 2.4 Normality Diagnostics (Raw) ---------------------------

par(mfrow = c(1, 2))
qqnorm(ROA_long$ReturnOnAssets, main = "Q-Q Plot: Raw ROA")
qqline(ROA_long$ReturnOnAssets, col = "blue", lwd = 2, lty = 2)
hist(ROA_long$ReturnOnAssets,
     main = "Distribution: Raw ROA", xlab = "ROA",
     col = "steelblue", border = "white")
par(mfrow = c(1, 1))

# ---- 2.5 Levene's Test (Raw) ------------------------------------

leveneTest(ReturnOnAssets ~ Sector, data = ROA_long)
# Result: p < 0.05 -> unequal variances; GLS with varIdent warranted

# ---- 2.6 Log Transform & Re-Diagnostics ------------------------

ROA_long$LogROA <- log1p(ROA_long$ReturnOnAssets)

par(mfrow = c(1, 2))
qqnorm(ROA_long$LogROA, main = "Q-Q Plot: Log ROA")
qqline(ROA_long$LogROA, col = "red", lwd = 2, lty = 2)
hist(ROA_long$LogROA,
     main = "Distribution: Log ROA", xlab = "log1p(ROA)",
     col = "tomato", border = "white")
par(mfrow = c(1, 1))

# ---- 2.7 GLS ANOVA (Sector-Specific Variance Structure) ---------
# GLS with varIdent allows each sector its own residual variance,
# directly addressing the heteroscedasticity flagged by Levene's test.

roa_model <- gls(LogROA ~ Sector - 1,
                 data    = ROA_long,
                 weights = varIdent(form = ~ 1 | Sector))
summary(roa_model)


# ==============================================================
# METRIC 3: PROFIT MARGINS (PM)
# ==============================================================

# ---- 3.1 Build & Export -----------------------------------------

ProfitMargins <- as.data.frame(cbind(
  Basic_Materials    = BasicMat_ManagementEff$profitMargins,
  Communication_Serv = CommServ_ManagementEff$profitMargins,
  Consumer_Cycle     = ConsCycl_ManagementEff$profitMargins,
  Consumer_Defense   = ConsDef_ManagementEff$profitMargins,
  Energy             = Ener_ManagementEff$profitMargins,
  Financial_Serv     = FinServ_ManagementEff$profitMargins,
  Healthcare         = HealCare_ManagementEff$profitMargins,
  Industrials        = Indust_ManagementEff$profitMargins,
  Real_Estate        = RealEst_ManagementEff$profitMargins,
  Technology         = Tech_ManagementEff$profitMargins,
  Utilities          = Utility_ManagementEff$profitMargins
))

write.csv(ProfitMargins,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\ProfitMargins.csv",
          row.names = FALSE)

# ---- 3.2 Reshape ------------------------------------------------

ProfMargins_long <- pivot_longer(ProfitMargins,
                                 cols      = everything(),
                                 names_to  = "Sector",
                                 values_to = "ProfitMargins")
ProfMargins_long$Sector <- as.factor(ProfMargins_long$Sector)
write.csv(ProfMargins_long,
          "C:\\Users\\musam\\Portfolio_Analysis\\data_files\\ProfMargins_long.csv",
          row.names = FALSE)


# ---- 3.3 Kruskal-Wallis (Raw) ----------------------------------
# Note: column name avoids backtick-quoting by using a clean variable name.

kruskal_result_PM <- kruskal.test(ProfitMargins ~ Sector, data = ProfMargins_long)
print(kruskal_result_PM)

# ---- 3.4 Normality Diagnostics (Raw) ---------------------------

par(mfrow = c(1, 2))
qqnorm(ProfMargins_long$ProfitMargins, main = "Q-Q Plot: Raw Profit Margins")
qqline(ProfMargins_long$ProfitMargins, col = "blue", lwd = 2, lty = 2)
hist(ProfMargins_long$ProfitMargins,
     main = "Distribution: Raw Profit Margins", xlab = "Profit Margin",
     col = "steelblue", border = "white")
par(mfrow = c(1, 1))

# ---- 3.5 Log Transform & Re-Diagnostics ------------------------

ProfMargins_long$LogPM <- log1p(ProfMargins_long$ProfitMargins)

kruskal.test(LogPM ~ Sector, data = ProfMargins_long)

par(mfrow = c(1, 2))
qqnorm(ProfMargins_long$LogPM, main = "Q-Q Plot: Log Profit Margins")
qqline(ProfMargins_long$LogPM, col = "red", lwd = 2, lty = 2)
hist(ProfMargins_long$LogPM,
     main = "Distribution: Log Profit Margins", xlab = "log1p(PM)",
     col = "tomato", border = "white")
par(mfrow = c(1, 1))

# ---- 3.6 Levene's Test (Log) ------------------------------------

leveneTest(LogPM ~ Sector, data = ProfMargins_long)
# Result: p < 0.05 -> heteroscedasticity remains; use GLS

# ---- 3.7 GLS ANOVA (Sector-Specific Variance Structure) ---------

profmargs_model <- gls(LogPM ~ Sector - 1,
                       data    = ProfMargins_long,
                       weights = varIdent(form = ~ 1 | Sector))
summary(profmargs_model)

# ---- 3.8 Visualise: Sector Means vs. Grand Mean ----------------

grand_mean_pm <- mean(ProfMargins_long$LogPM)

ggplot(ProfMargins_long, aes(x = reorder(Sector, LogPM, FUN = mean), y = LogPM)) +
  stat_summary(fun = mean, geom = "point", size = 4, colour = "steelblue") +
  stat_summary(fun = mean, geom = "errorbar",
               fun.min = mean, fun.max = mean,
               width = 0.5, colour = "steelblue", linewidth = 0.6) +
  geom_hline(yintercept = grand_mean_pm,
             linetype = "dashed", colour = "red", linewidth = 0.9) +
  coord_flip() +
  labs(
    title    = "Sector Log-Mean Profit Margins vs. Grand Mean",
    subtitle = "Red dashed line = Grand Mean  |  Points = Sector Log-Means",
    x        = NULL,
    y        = "log1p(Profit Margin)"
  ) +
  theme_minimal(base_size = 13) +
  theme(
    plot.title       = element_text(face = "bold"),
    plot.subtitle    = element_text(colour = "grey50"),
    panel.grid.minor = element_blank()
  )

# ====================================================================================================================
#                               INTERPRETATION: ROE/ROA Distribution & Diagnostics
# ====================================================================================================================

# 1. NON-NORMALITY OF RAW DATA
# ----------------------------
# - The Q-Q Plots for raw ROE and ROA show heavy tails and significant deviation from the theoretical line.
# - The histograms are sharply right-skewed, indicating that a few high-performing outliers 
#   are pulling the mean away from the median.
# - Validation: This justifies your use of the Kruskal-Wallis test (non-parametric) and the log1p transformation.

# 2. LOG TRANSFORMATION EFFECTIVENESS
# -----------------------------------
# - The log1p(ROE/ROA) histograms show a more "Gaussian-like" bell curve, though some skew remains.
# - Log transformation was necessary to handle negative or near-zero efficiency values often found 
#   in distressed companies or high-growth Tech/Biotech sectors.

# 3. RESIDUALS BY SECTOR (HETEROSCEDASTICITY)
# ------------------------------------------
# - The 'Residuals by Sector' plot reveals unequal "spread" (variance) across groups.
# - For example, Financial Services and Tech often show a wider vertical dispersion of residuals 
#   compared to Utilities.
# - Validation: This confirms why Levene’s Test failed (p < 0.05) and justifies your use of 
#   the GLS (Generalized Least Squares) model with 'varIdent' to allow for sector-specific variances.

# ====================================================================================================================
#                               INTERPRETATION: ProfitMargin_Sector_Comparison.png
# ====================================================================================================================

# 1. SECTOR HIERARCHY (LOG-MEAN PROFIT MARGINS)
# ---------------------------------------------
# - The "Sector Log-Mean Profit Margins vs. Grand Mean" plot provides a clear ranking of efficiency.
# - High Efficiency: Sectors like Technology and Financial Services typically sit significantly 
#   to the right of the red dashed line (Grand Mean).
# - Low Efficiency: Consumer Cyclical (Retail) and Energy often fall to the left, reflecting 
#   higher cost-of-goods-sold (COGS) or capital-intensive operations.

# 2. THE GRAND MEAN BENCHMARK (RED DASHED LINE)
# ---------------------------------------------
# - The red dashed line represents the "Market Average" efficiency.
# - Sectors whose error bars do not cross this line are statistically significant 
#   outperformers (or underperformers) in management efficiency compared to the broader market.

# 3. REAL ESTATE & UTILITIES OBSERVATION
# --------------------------------------
# - Real Estate often shows high log-means due to the nature of rental income/REIT structures.
# - Utilities typically show very tight error bars, indicating highly regulated, 
#   predictable profit margins with low variance between individual companies.
