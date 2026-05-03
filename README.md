# m-mkhohliswa.github.io
# Multi-Factor Equity Research & Portfolio Risk Analytics

> An end-to-end quantitative equity research framework for determining which S&P 500 sectors
> offer the best risk-adjusted returns for optimal portfolio construction.

**Author:** Musa Mkhohliswa  
**Stack:** R · Python · MySQL · HTML

---

## Overview

This framework integrates S&P 500 market data with corporate financials to evaluate sector
performance across five fundamental pillars: income yield, management efficiency, growth
potential, risk-adjusted returns, and customer behaviour modelling.

Statistical rigour is maintained throughout — raw distributions are tested for normality and
homogeneity of variance before selecting the appropriate model (Welch's ANOVA, GLS, or robust
regression). Findings are presented in an interactive single-page HTML dashboard.

---

## Dashboard Structure

| Section | Focus | Methods |
|---------|-------|---------|
| 01 — Income & Risk | Dividend yields, Sharpe ratios, risk profiles | Kruskal-Wallis, Welch's ANOVA, Games-Howell |
| 02 — Efficiency & Growth | ROE, ROA, profit margins, future returns | GLM, GLS (varIdent), robust regression (rlm) |
| 03 — Momentum & PEG | Beta, trailing PEG, GARP analysis | Welch's ANOVA, log1p transform, Levene's test |
| 04 — Time-Series & VAR | Daily returns, cumulative growth, Sharpe | PerformanceAnalytics, VAR, OHLC |
| 05 — Markov Transitions | Customer state churn modelling | Markov chain (10-step projection) |

---

## Repository Structure

Raw Data (Yahoo Finance / Kaggle S&P 500)
↓
Python ingestion → MySQL (company_db)
↓
R: Normality tests (Q-Q, histogram)
↓
R: Levene's test → heteroscedasticity check
↓
R: log1p transform → re-diagnose
↓
R: Welch's ANOVA / GLM / GLS (varIdent)
↓
R: Games-Howell post-hoc / Robust regression
↓
CSV export → HTML dashboard


## Key Findings

- **Real Estate, Utilities, and Consumer Defense** return the highest dividend yields above the S&P 500 grand mean
- **Technology** leads on management efficiency (ROE/ROA) but carries above-average market beta
- **Technology and Healthcare** offer the best GARP profile — PEG ratios below 1.5
- **Communication Services** trades at a significant premium (avg PEG ~20.5)
- **Markov chain projection** shows customer retention states decay to near-zero within 10 steps without intervention

---

## Dependencies

**R packages**
```r
quantmod, PerformanceAnalytics, xts, DBI, RMySQL, data.table,
tidyr, FSA, car, rstatix, ggplot2, MASS, nlme, markovchain,
e1071, dplyr, purrr, arrow
```

**Python packages**
sqlalchemy, pymysql, pandas, cryptography
**Database:** MySQL 8.0+ · **Data source:** S&P 500 financials via Yahoo Finance / Kaggle

---

## Live Dashboard

> Open `index.html` directly in a browser — no build step required.  
> All dependencies (Chart.js, Google Fonts) load from CDN.
