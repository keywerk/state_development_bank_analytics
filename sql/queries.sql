-- Queries for bank_financials_clean_overview (2015–2024)

-- All data

SELECT year, metric, value
FROM bank_financials_clean_overview
ORDER BY year, metric;

-- Total assets by year

SELECT year, value
FROM bank_financials_clean_overview
WHERE metric = 'Total assets'
ORDER BY year;

-- Avg net income

SELECT AVG(value)
FROM bank_financials_clean_overview
WHERE metric = 'Net income';

-- Max return on equity

SELECT year, value
FROM bank_financials_clean_overview
WHERE metric = 'Return on equity'
ORDER BY value DESC
LIMIT 1;

-- Sum of equity

SELECT SUM(value)
FROM bank_financials_clean_overview
WHERE metric = 'Equity';

-- High cost-income ratio

SELECT year, value
FROM bank_financials_clean_overview
WHERE metric = 'Cost-Income-Ratio' AND value > 0.60;

