-- Schema for cleaned bank financials overview (2015–2024)

CREATE TABLE bank_financials_clean_overview (
    id SERIAL PRIMARY KEY,                  -- unique row identifier
    year INTEGER NOT NULL,                  -- reporting year
    metric VARCHAR(50) NOT NULL,            -- financial indicator
    value NUMERIC(15,2) NOT NULL            -- numeric value of the indicator
);