USE company_db;
SELECT COUNT(*) FROM company_balance_sheet;

SELECT *
FROM APD
LIMIT 100; 

CREATE TABLE Sector_Grouped
SELECT Symbol, sector, sectorKey, longBusinessSummary
FROM company_info
WHERE dividendYield IS NOT NULL AND 
payoutRatio IS NOT NULL AND
trailingAnnualDividendRate IS NOT NULL AND
trailingAnnualDividendYield IS NOT NULL AND
returnOnEquity IS NOT NULL AND
returnOnAssets IS NOT NULL AND
profitMargins IS NOT NULL AND
earningsGrowth IS NOT NULL AND
revenueGrowth IS NOT NULL AND
beta IS NOT NULL AND
trailingPegRatio IS NOT NULL;
-- ---------------------------------------------------------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------
-- COMPANY INFO --
-- This contains all the information about the company from location details to economic indicators --
-- In total there are 129 Columns --
-- To Do: Create Detaiteld Tables for each Company Aspect
-- Cleaned Info for extraction 
-- Updated Cleaned Table: Info_Table

CREATE TABLE INFO_TABLE AS 
SELECT  Symbol,
sector, 
sectorKey,
longBusinessSummary,
dividendYield, 
payoutRatio, 
trailingAnnualDividendRate,
trailingAnnualDividendYield,
returnOnEquity, 
returnOnAssets,
profitMargins,
earningsGrowth,
revenueGrowth,
beta,
trailingPegRatio,
fitytwoWeekChange,
SandP52WeekChange,
currentPrice,
twoHundredDayAverageChange,
fiftyTwoWeekLowChangePercent
FROM company_info
WHERE dividendYield IS NOT NULL AND 
payoutRatio IS NOT NULL AND
trailingAnnualDividendRate IS NOT NULL AND
trailingAnnualDividendYield IS NOT NULL AND
returnOnEquity IS NOT NULL AND
returnOnAssets IS NOT NULL AND
profitMargins IS NOT NULL AND
earningsGrowth IS NOT NULL AND
revenueGrowth IS NOT NULL AND
beta IS NOT NULL AND
trailingPegRatio IS NOT NULL;

SELECT * FROM company_db.info_table;

CREATE TABLE SECTORS
SELECT Symbol, sector
FROM INFO_TABLE;

SELECT *
FROM SECTORS;

-- Company Profile And Governance (Scores out of 10) --
-- auditRisk: Financial reporting and auditing scores
-- boardRisk: Strength and independence of boards
-- ShareholderRightsRisk: Protection of Shareholders 
-- OverallRisk: Avarage governance from the abovementioned 
-- governanceEpochDate: Last Date these record were updated




-- Dividends and Payouts --
-- dividendRate: Annaul dividend payment per share
-- dividendYield: The annual dividend payment divided by the current share price (%)
-- exDividendDate:The date by which you must own the stock to receive the next dividend.
-- payoutRatio: The percentage of earnings paid out as dividends to shareholders.
-- fiveyearAvgDividendYield: The average dividend yield over the last five years.
-- trailingAnnualDividendRate / Yield: The total dividends paid over the previous 12 months.
-- lastDividendValue / Date: The amount and date of the most recent dividend payment.
-- Updated Table for Income Metrics: Clean_income_Metrics

SELECT Symbol, 
dividendYield, 
payoutRatio, 
trailingAnnualDividendRate,
trailingAnnualDividendYield
FROM company_info;

CREATE TABLE Income_Metrics AS 
SELECT Symbol, 
dividendYield, 
payoutRatio, 
trailingAnnualDividendRate,
trailingAnnualDividendYield
FROM info_table;

SELECT *
FROM Income_Metrics;

-- -----------------------------------------------------------------------------------------------------------
-- Internal Management Efficiency --
-- 	returnOnEquity (ROE): This is arguably the most important metric for portfolio tracking. 
-- It measures how much profit the company generates with the money shareholders have invested.
-- returnOnAssets (ROA): Shows how efficiently the company uses its total resources to generate earnings.
-- profitMargins: Higher margins often lead to higher reinvestment rates, fueling future compounded returns.
-- Updated Management Efficiency Markers table: ME_IINTERNAL_TABLE

CREATE TABLE ME_INTERNAL_TABLE AS
SELECT Symbol,
returnOnEquity, 
returnOnAssets,
profitMargins
FROM info_table;

-- -----------------------------------------------------------------------------------------------------------------
-- Valuation Metric --
-- marketCap: The total market value of all outstanding shares (Share Price * Total Shares).
-- enterpriseValue: A measure of the company's total value, often viewed as the theoretical takeover price (Market Cap + Debt - Cash).
-- trailingPE / forwardPE: The Price-to-Earnings ratio based on the last 12 months of earnings vs. predicted future earnings.
-- priceToSalesTrailing12Months: The company's stock price divided by its revenue per share.
-- priceToBook: Compares the market's valuation of the company to its "book value" (total assets minus liabilities).
-- enterpriseToRevenue / enterpriseToEbitda: Ratios comparing enterprise value to total sales or core operational profits.
-- trailingPegRatio: The P/E ratio divided by the growth rate of its earnings; used to determine if a stock is over/undervalued relative to its growth.

-- Stock Price Performance & Volume --
-- currentPrice: The most recent trading price of the stock.
-- fiftyTwoWeekHigh / Low: The highest and lowest price the stock has reached in the last year.
-- fiftyDayAverage / twoHundredDayAverage: The average stock price over the last 50 and 200 trading days (used to identify trends).
-- fitytwoWeekChange / SandP52WeekChange: The percentage change in the stock price over the last year compared to the S&P 500 index.
-- regularMarketVolume / averageVolume: The number of shares traded in the current session vs. the typical daily volume.
-- fiftyTwoWeekRange: The spread between the 52-week low and high.

-- Financial Health (Income, Balance Sheets, Cash Flow) --
-- totalRevenue / revenueGrowth: Total money brought in and the percentage increase in sales year-over-year.
-- ebitda: Earnings Before Interest, Taxes, Depreciation, and Amortization (a measure of core operational profitability).
-- netIncomeToCommon: The total profit available to common stockholders after all expenses.
-- totalCash / totalCashPerShare: Total liquidity available to the company.
-- totalDebt / debtToEquity: Measures of the company's leverage (how much it owes relative to its equity).
-- quickRatio / currentRatio: Measures of the company’s ability to pay short-term obligations with its most liquid assets.
-- freeCashflow / operatingCashflow: The cash generated by the business after operating expenses and capital expenditures.
-- returnOnAssets (ROA) / returnOnEquity (ROE): Percentages indicating how effectively the company uses its assets or shareholder equity to generate profit.

-- Share and Short Interest Data --
-- sharesOutstanding: The total number of shares currently held by all stockholders.
-- floatShares: The portion of shares outstanding that are actually available to the public for trading.
-- sharesShort: The number of shares that investors have "shorted" (betting the price will go down).
-- shortRatio: The number of days it would take short-sellers to cover their positions based on average volume.
-- shortPercentOfFloat: The percentage of available shares currently being shorted.
-- heldPercentInsiders / Institutions: The percentage of shares owned by company employees/executives vs. large investment firms.

-- Earnings Data -- 
-- trailingEps / forwardEps: Earnings Per Share (Profit / Total Shares) for the past year vs. expected for the next year.
-- earningsQuarterlyGrowth: The percentage increase in earnings compared to the same quarter in the previous year.

-- Analysis and Market Data 
-- recommendationKey: A summary of analyst opinions (e.g., "buy", "hold", "sell").
-- numberOfAnalystOpinions: How many professional analysts are covering and rating the stock.
-- currency / financialCurrency: The currency used for trading and the currency used in the company’s financial reports.
-- exchange / fullExchangeName: The stock exchange where the company is listed (e.g., NYSE, NASDAQ).
-- astSplitFactor / Date: Information regarding the most recent stock split (e.g., 2-for-1).

-- Growth Indicators -- 
CREATE TABLE GI_FUTURE_RETURNS AS
SELECT Symbol, earningsGrowth, revenueGrowth
FROM Info_table;

-- Price Performance --
CREATE TABLE CAPITAL AS
SELECT Symbol, 
fitytwoWeekChange,
SandP52WeekChange,
currentPrice,
twoHundredDayAverageChange,
fiftyTwoWeekLowChangePercent
FROM Info_Table;

-- Risk-Adjusted Returns --
CREATE TABLE Risk_Adj_Returns AS
SELECT Symbol, beta, trailingPegRatio
FROM Info_Table;

-- -----------------------------------------------------------------------------------------------------------

-- PRICE DATA --
-- Date: Trading Day of observation 
-- Open: The initial Opening Price for Stock Trading
-- High: the highest price for each stock recorded during that day
-- Low: Lowest price recorded for each stock that day
-- Close: The final price when the Market closed 
-- Volume: The total number of shares traded during that day: liquidity and market activity
-- Company Analysis: return = Close ((present day) - Close (previous day))/ Close (previous day) 


-- ----------------------------------------------------------------------------------------------------------
-- BALANCE SHEET -- 
-- Financial position (Item) at a specific point in time (Period) — 
-- What it owns, what it owes, and what’s left for owners (Value).

-- ----------------------------------------------------------------------------------------------------------
-- COMPANY FINANCIALS --
-- Financial Statement Position (Item) at a specific point in time (Period)
-- Tax-related-line items, tax and revenue.

-- ----------------------------------------------------------------------------------------------------------
-- COMPAN FILINGS --
-- Company filings are official reports that publicly listed companies must submit to regulators. 

-- -----------------------------------------------------------------------------------------------------------
-- COMPANY OFFICERS --
-- Executive teams for companies

-- -----------------------------------------------------------------------------------------------------------
-- COMPANY NEWS SENTIMENT 
-- Company news, providers, and their publications

-- --------------------------------------------------------------------------------------------------------------------

-- IncomeMetrics for ANOVA --
-- TABLE ONE -- SECTOR: BASIC MATERIALS
-- TABLE TWO -- SECTOR: COMMUNICATION SERVICES
-- :::::::::::::::::::::::::::::::::::::::::::: --
-- TABLE ELEVEN -- SECTOR: UTILITIES
CREATE TABLE BasicMat_IM AS
SELECT *
FROM income_metrics 
WHERE Symbol IN ( "APD", "CF", "EMN" , "FCX" , "LIN" , "MLM", "NEM", "SHW", "VMC" );

SELECT *
FROM BM_DY;

CREATE TABLE CommServ_IM AS
SELECT *
FROM income_metrics
WHERE Symbol IN ("CMCSA", "DIS", "EA", "FOX", "FOXA", "GOOG", "GOOGL", "T", "TMUS", "VZ");

SELECT *
FROM CommServ_IM;

CREATE TABLE ConsCycl_IM AS
SELECT *
FROM Income_Metrics
WHERE Symbol IN ("AMCR", "AVY", "BBY", "DHI", "DRI", "EBAY", "EXPE", "HD", "KSS", "LEN", "LVS", "NKE", "PHM", "PKG", "PVH", "RCL", "RL", "ROL", "ROST", "TJX", "TPR", "TSCO");

CREATE TABLE ConsDef_IM AS
SELECT * 
FROM Income_Metrics
WHERE Symbol IN ("ADM", "CHD", "CLX", "COST", "CPB", "DG", "GIS", "HRL", "HSY", "KHC", "KMB", "KO", "KR", "MDLZ", "MKC", "PEP", "PG", "STZ", "SYY", "TAP", "TGT", "TSN", "WMT");

CREATE TABLE ENER_IM AS
SELECT *
FROM Income_Metrics
WHERE Symbol IN ("APA", "BKR", "COP", "CVX", "DVN", "EOG", "FTI", "KMI", "MPC", "OKE", "PSX", "SLB", "VLO", "WMB", "XOM");

CREATE TABLE FinServ_IM AS 
SELECT *
FROM income_Metrics
WHERE Symbol IN ("AJG", "ALL", "AMP", "AON", "AXP", "BAC", "BEN", "BK", "BLK", 
"C", "CB", "CBOE", "CMA", "CME", "COF", "FITB", "GS", "HBAN", "ICE", "MA", "MCO", "MET", 
"MKTX", "MS", "MTB", "NDAQ", "NTRS", "PGR", "PNC", "PYPL", "RJF", "SCHW", "SPGI", 
"STT", "SYF", "TFC", "TROW", "TRV", "USB", "V", "WFC", "WRB", "WU", "ZION");

CREATE TABLE HealthCare_IM AS
SELECT * 
FROM Income_Metrics
WHERE Symbol IN ("A", "ABT", "AMGN", "BDX", "CI", "CVS", "DGX", "DHR", "GILD", "JNJ", "LH", "LLY","MDT", "MRK",
 "REGN", "RMD", "STE", "SYK", "TMO", "UHS", "UNH", "WST", "ZBH", "ZTS");

CREATE TABLE Indust_IM AS
SELECT *
FROM Income_Metrics
WHERE Symbol IN ("ALLE", "AME", "AOS", "CARR", "CAT", "CHRW", "CMI", "CSX", "CTAS", "DE", "DOV", "EFX", "EMR",
 "ETN", "EXPD", "FAST", "FDX", "GD", "GE", "GPN", "GWW", "HII", "HON", "IEX", "IR", "ITW",
 "JBHT", "JCI", "LHX", "LMT", "LUV", "MAS", "MMM", "NOC", "NSC", "ODFL", "PCAR", "PH", 
"PNR", "PWR", "ROK", "RSG", "RTX", "SNA", "TT", "TXT", "UNP", "UPS", "URI", "WM", "XYL");

CREATE TABLE RealEst_IM AS
SELECT *
FROM Income_Metrics
WHERE Symbol IN ("AMT", "DLR", "EXR", "PLD", "PSA", "REG", "VNO", "WY");

CREATE TABLE Tech_IM AS
SELECT *
FROM Income_Metrics
WHERE Symbol IN ("AAPL", "ACN", "ADI", "ADP", "AMAT", "APH", "AVGO", "BR", "CRM", "CSCO", "CTSH", "FIS",
 "GLW", "GRMN", "HPE", "IBM", "INTU", "JKHY", "KLAC", "LRCX", "MSFT", 
"MSI", "MU", "NTAP", "NVDA", "ORCL", "PAYC", "PAYX", "QCOM", "ROP", "SWKS", "TEL", "TXN");

SELECT *
FROM Tech_IM; 

CREATE TABLE Utility_IM AS
SELECT *
FROM Income_Metrics
WHERE Symbol IN("AEE", "AEP", "ATO", "AWK", "CMS", "CNP", "D", "DTE", "DUK", "ED", 
"EIX", "ES", "ETR", "EVRG", "EXC", "LNT", 
"NEE", "NI", "NRG", "PEG", "PPL", "SO", "SRE", "WEC", "XEL");

-- ------------------------------------------------------------------------------------------------------------------
-- Next, Capital (Price Performance) --

CREATE TABLE BasicMat_Capital AS
SELECT * 
FROM CAPITAL
WHERE Symbol IN ( "APD", "CF", "EMN" , "FCX" , "LIN" , "MLM", "NEM", "SHW", "VMC");

CREATE TABLE CommServ_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("CMCSA", "DIS", "EA", "FOX", "FOXA", "GOOG", "GOOGL", "T", "TMUS", "VZ");

CREATE TABLE ConsCycl_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("AMCR", "AVY", "BBY", "DHI", "DRI", "EBAY", "EXPE", "HD", "KSS", "LEN", "LVS", "NKE", "PHM", "PKG", "PVH", "RCL", "RL", "ROL", "ROST", "TJX", "TPR", "TSCO");

CREATE TABLE ConsDef_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("ADM", "CHD", "CLX", "COST", "CPB", "DG", "GIS", "HRL", "HSY", "KHC", "KMB", "KO", "KR", "MDLZ", "MKC", "PEP", "PG", "STZ", "SYY", "TAP", "TGT", "TSN", "WMT");

CREATE TABLE Ener_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("APA", "BKR", "COP", "CVX", "DVN", "EOG", "FTI", "KMI", "MPC", "OKE", "PSX", "SLB", "VLO", "WMB", "XOM");

CREATE TABLE FinServ_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("AJG", "ALL", "AMP", "AON", "AXP", "BAC", "BEN", "BK", "BLK",
"C", "CB", "CBOE", "CMA", "CME", "COF", "FITB", "GS", "HBAN", "ICE", "JPM", "MA", "MCO", "MET",
"MKTX", "MS", "MTB", "NDAQ", "NTRS", "PGR", "PNC", "PYPL", "RJF", "SCHW", "SPGI",
"STT", "SYF", "TFC", "TROW", "TRV", "USB", "V", "WFC", "WRB", "WU", "ZION");

CREATE TABLE HealCare_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("A", "ABT", "AMGN", "BDX", "CI", "CVS", "DGX", "DHR", "GILD", "JNJ", "LH", "LLY", "MDT", "MRK",
"REGN", "RMD", "STE", "SYK", "TMO", "UHS", "UNH", "WST", "ZBH", "ZTS");

CREATE TABLE Indust_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("ALLE", "AME", "AOS", "CARR", "CAT", "CHRW", "CMI", "CSX", "CTAS", "DE", "DOV", "EFX", "EMR",
"ETN", "EXPD", "FAST", "FDX", "GD", "GE", "GPN", "GWW", "HII", "HON", "IEX", "IR", "ITW",
"JBHT", "JCI", "LHX", "LMT", "LUV", "MAS", "MMM", "NOC", "NSC", "ODFL", "PCAR", "PH",
"PNR", "PWR", "ROK", "RSG", "RTX", "SNA", "TT", "TXT", "UNP", "UPS", "URI", "WM", "XYL");

CREATE TABLE RealEst_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("AMT", "DLR", "EXR", "PLD", "PSA", "REG", "VNO", "WY");

CREATE TABLE Tech_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("AAPL", "ACN", "ADI", "ADP", "AMAT", "APH", "AVGO", "BR", "CRM", "CSCO", "CTSH", "FIS",
"GLW", "GRMN", "HPE", "IBM", "INTU", "JKHY", "KLAC", "LRCX", "MSFT",
"MSI", "MU", "NTAP", "NVDA", "ORCL", "PAYC", "PAYX", "QCOM", "ROP", "SWKS", "TEL", "TXN");

CREATE TABLE Utility_Capital AS
SELECT *
FROM Capital
WHERE Symbol IN ("AEE", "AEP", "ATO", "AWK", "CMS", "CNP", "D", "DTE", "DUK", "ED",
"EIX", "ES", "ETR", "EVRG", "EXC", "LNT",
"NEE", "NI", "NRG", "PEG", "PPL", "SO", "SRE", "WEC", "XEL");

-- ===================== GI_Future_Returns =====================

CREATE TABLE BasicMat_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("APD", "CF", "EMN", "FCX", "LIN", "MLM", "NEM", "SHW", "VMC");

CREATE TABLE CommServ_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("CMCSA", "DIS", "EA", "FOX", "FOXA", "GOOG", "GOOGL", "T", "TMUS", "VZ");

CREATE TABLE ConsCycl_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("AMCR", "AVY", "BBY", "DHI", "DRI", "EBAY", "EXPE", "HD", "KSS", "LEN", "LVS", "NKE", "PHM", "PKG", "PVH", "RCL", "RL", "ROL", "ROST", "TJX", "TPR", "TSCO");

CREATE TABLE ConsDef_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("ADM", "CHD", "CLX", "COST", "CPB", "DG", "GIS", "HRL", "HSY", "KHC", "KMB", "KO", "KR", "MDLZ", "MKC", "PEP", "PG", "STZ", "SYY", "TAP", "TGT", "TSN", "WMT");

CREATE TABLE Ener_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("APA", "BKR", "COP", "CVX", "DVN", "EOG", "FTI", "KMI", "MPC", "OKE", "PSX", "SLB", "VLO", "WMB", "XOM");

CREATE TABLE FinServ_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("AJG", "ALL", "AMP", "AON", "AXP", "BAC", "BEN", "BK", "BLK",
"C", "CB", "CBOE", "CMA", "CME", "COF", "FITB", "GS", "HBAN", "ICE", "JPM", "MA", "MCO", "MET",
"MKTX", "MS", "MTB", "NDAQ", "NTRS", "PGR", "PNC", "PYPL", "RJF", "SCHW", "SPGI",
"STT", "SYF", "TFC", "TROW", "TRV", "USB", "V", "WFC", "WRB", "WU", "ZION");

CREATE TABLE HealCare_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("A", "ABT", "AMGN", "BDX", "CI", "CVS", "DGX", "DHR", "GILD", "JNJ", "LH", "LLY", "MDT", "MRK",
"REGN", "RMD", "STE", "SYK", "TMO", "UHS", "UNH", "WST", "ZBH", "ZTS");

CREATE TABLE Indust_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("ALLE", "AME", "AOS", "CARR", "CAT", "CHRW", "CMI", "CSX", "CTAS", "DE", "DOV", "EFX", "EMR",
"ETN", "EXPD", "FAST", "FDX", "GD", "GE", "GPN", "GWW", "HII", "HON", "IEX", "IR", "ITW",
"JBHT", "JCI", "LHX", "LMT", "LUV", "MAS", "MMM", "NOC", "NSC", "ODFL", "PCAR", "PH",
"PNR", "PWR", "ROK", "RSG", "RTX", "SNA", "TT", "TXT", "UNP", "UPS", "URI", "WM", "XYL");

CREATE TABLE RealEst_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("AMT", "DLR", "EXR", "PLD", "PSA", "REG", "VNO", "WY");

CREATE TABLE Tech_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("AAPL", "ACN", "ADI", "ADP", "AMAT", "APH", "AVGO", "BR", "CRM", "CSCO", "CTSH", "FIS",
"GLW", "GRMN", "HPE", "IBM", "INTU", "JKHY", "KLAC", "LRCX", "MSFT",
"MSI", "MU", "NTAP", "NVDA", "ORCL", "PAYC", "PAYX", "QCOM", "ROP", "SWKS", "TEL", "TXN");

CREATE TABLE Utility_FutureReturns AS
SELECT * FROM GI_Future_Returns
WHERE Symbol IN ("AEE", "AEP", "ATO", "AWK", "CMS", "CNP", "D", "DTE", "DUK", "ED",
"EIX", "ES", "ETR", "EVRG", "EXC", "LNT",
"NEE", "NI", "NRG", "PEG", "PPL", "SO", "SRE", "WEC", "XEL");


-- ===================== Risk_Adj_Returns =====================

CREATE TABLE BasicMat_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("APD", "CF", "EMN", "FCX", "LIN", "MLM", "NEM", "SHW", "VMC");

CREATE TABLE CommServ_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("CMCSA", "DIS", "EA", "FOX", "FOXA", "GOOG", "GOOGL", "T", "TMUS", "VZ");

CREATE TABLE ConsCycl_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("AMCR", "AVY", "BBY", "DHI", "DRI", "EBAY", "EXPE", "HD", "KSS", "LEN", "LVS", "NKE", "PHM", "PKG", "PVH", "RCL", "RL", "ROL", "ROST", "TJX", "TPR", "TSCO");

CREATE TABLE ConsDef_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("ADM", "CHD", "CLX", "COST", "CPB", "DG", "GIS", "HRL", "HSY", "KHC", "KMB", "KO", "KR", "MDLZ", "MKC", "PEP", "PG", "STZ", "SYY", "TAP", "TGT", "TSN", "WMT");

CREATE TABLE Ener_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("APA", "BKR", "COP", "CVX", "DVN", "EOG", "FTI", "KMI", "MPC", "OKE", "PSX", "SLB", "VLO", "WMB", "XOM");

CREATE TABLE FinServ_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("AJG", "ALL", "AMP", "AON", "AXP", "BAC", "BEN", "BK", "BLK",
"C", "CB", "CBOE", "CMA", "CME", "COF", "FITB", "GS", "HBAN", "ICE", "JPM", "MA", "MCO", "MET",
"MKTX", "MS", "MTB", "NDAQ", "NTRS", "PGR", "PNC", "PYPL", "RJF", "SCHW", "SPGI",
"STT", "SYF", "TFC", "TROW", "TRV", "USB", "V", "WFC", "WRB", "WU", "ZION");

CREATE TABLE HealCare_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("A", "ABT", "AMGN", "BDX", "CI", "CVS", "DGX", "DHR", "GILD", "JNJ", "LH", "LLY", "MDT", "MRK",
"REGN", "RMD", "STE", "SYK", "TMO", "UHS", "UNH", "WST", "ZBH", "ZTS");

CREATE TABLE Indust_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("ALLE", "AME", "AOS", "CARR", "CAT", "CHRW", "CMI", "CSX", "CTAS", "DE", "DOV", "EFX", "EMR",
"ETN", "EXPD", "FAST", "FDX", "GD", "GE", "GPN", "GWW", "HII", "HON", "IEX", "IR", "ITW",
"JBHT", "JCI", "LHX", "LMT", "LUV", "MAS", "MMM", "NOC", "NSC", "ODFL", "PCAR", "PH",
"PNR", "PWR", "ROK", "RSG", "RTX", "SNA", "TT", "TXT", "UNP", "UPS", "URI", "WM", "XYL");

CREATE TABLE RealEst_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("AMT", "DLR", "EXR", "PLD", "PSA", "REG", "VNO", "WY");

CREATE TABLE Tech_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("AAPL", "ACN", "ADI", "ADP", "AMAT", "APH", "AVGO", "BR", "CRM", "CSCO", "CTSH", "FIS",
"GLW", "GRMN", "HPE", "IBM", "INTU", "JKHY", "KLAC", "LRCX", "MSFT",
"MSI", "MU", "NTAP", "NVDA", "ORCL", "PAYC", "PAYX", "QCOM", "ROP", "SWKS", "TEL", "TXN");

CREATE TABLE Utility_AdjReturns AS
SELECT * FROM Risk_Adj_Returns
WHERE Symbol IN ("AEE", "AEP", "ATO", "AWK", "CMS", "CNP", "D", "DTE", "DUK", "ED",
"EIX", "ES", "ETR", "EVRG", "EXC", "LNT",
"NEE", "NI", "NRG", "PEG", "PPL", "SO", "SRE", "WEC", "XEL");


-- ===================== ME_INTERNAL_TABLE =====================

CREATE TABLE BasicMat_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("APD", "CF", "EMN", "FCX", "LIN", "MLM", "NEM", "SHW", "VMC");

CREATE TABLE CommServ_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("CMCSA", "DIS", "EA", "FOX", "FOXA", "GOOG", "GOOGL", "T", "TMUS", "VZ");

CREATE TABLE ConsCycl_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("AMCR", "AVY", "BBY", "DHI", "DRI", "EBAY", "EXPE", "HD", "KSS", "LEN", "LVS", "NKE", "PHM", "PKG", "PVH", "RCL", "RL", "ROL", "ROST", "TJX", "TPR", "TSCO");

CREATE TABLE ConsDef_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("ADM", "CHD", "CLX", "COST", "CPB", "DG", "GIS", "HRL", "HSY", "KHC", "KMB", "KO", "KR", "MDLZ", "MKC", "PEP", "PG", "STZ", "SYY", "TAP", "TGT", "TSN", "WMT");

CREATE TABLE Ener_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("APA", "BKR", "COP", "CVX", "DVN", "EOG", "FTI", "KMI", "MPC", "OKE", "PSX", "SLB", "VLO", "WMB", "XOM");

CREATE TABLE FinServ_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("AJG", "ALL", "AMP", "AON", "AXP", "BAC", "BEN", "BK", "BLK",
"C", "CB", "CBOE", "CMA", "CME", "COF", "FITB", "GS", "HBAN", "ICE", "JPM", "MA", "MCO", "MET",
"MKTX", "MS", "MTB", "NDAQ", "NTRS", "PGR", "PNC", "PYPL", "RJF", "SCHW", "SPGI",
"STT", "SYF", "TFC", "TROW", "TRV", "USB", "V", "WFC", "WRB", "WU", "ZION");

CREATE TABLE HealCare_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("A", "ABT", "AMGN", "BDX", "CI", "CVS", "DGX", "DHR", "GILD", "JNJ", "LH", "LLY", "MDT", "MRK",
"REGN", "RMD", "STE", "SYK", "TMO", "UHS", "UNH", "WST", "ZBH", "ZTS");

CREATE TABLE Indust_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("ALLE", "AME", "AOS", "CARR", "CAT", "CHRW", "CMI", "CSX", "CTAS", "DE", "DOV", "EFX", "EMR",
"ETN", "EXPD", "FAST", "FDX", "GD", "GE", "GPN", "GWW", "HII", "HON", "IEX", "IR", "ITW",
"JBHT", "JCI", "LHX", "LMT", "LUV", "MAS", "MMM", "NOC", "NSC", "ODFL", "PCAR", "PH",
"PNR", "PWR", "ROK", "RSG", "RTX", "SNA", "TT", "TXT", "UNP", "UPS", "URI", "WM", "XYL");

CREATE TABLE RealEst_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("AMT", "DLR", "EXR", "PLD", "PSA", "REG", "VNO", "WY");

CREATE TABLE Tech_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("AAPL", "ACN", "ADI", "ADP", "AMAT", "APH", "AVGO", "BR", "CRM", "CSCO", "CTSH", "FIS",
"GLW", "GRMN", "HPE", "IBM", "INTU", "JKHY", "KLAC", "LRCX", "MSFT",
"MSI", "MU", "NTAP", "NVDA", "ORCL", "PAYC", "PAYX", "QCOM", "ROP", "SWKS", "TEL", "TXN");

CREATE TABLE Utility_ManagementEff AS
SELECT * FROM ME_INTERNAL_TABLE
WHERE Symbol IN ("AEE", "AEP", "ATO", "AWK", "CMS", "CNP", "D", "DTE", "DUK", "ED",
"EIX", "ES", "ETR", "EVRG", "EXC", "LNT",
"NEE", "NI", "NRG", "PEG", "PPL", "SO", "SRE", "WEC", "XEL");


