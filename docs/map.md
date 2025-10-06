/state_development_bank_analytics_2015_2024
│
├── data_raw/                                                      # Raw data
│   ├── bank_financials_raw_overview_2015_2019.csv
│   └── bank_financials_raw_overview_2020_2025.csv
│
├── data_clean/                                                    # Cleaned dataset
│   └── bank_financials_clean_overview_2015_2024.xlsx
│
├── dashboard/                                                     # Main dashboard
│   └── bank_financials_dashboard_overview_2015_2024.xlsm
│
├── docs/                                                          # Project documentation
│   └── map.md    
│
├── style/                                                         # Styling resources
│   ├── tables/                                                    # Table templates
│   │   ├── tbl_capital_adequacy.xltx
│   │   ├── tbl_financial_performance.xltx
│   │   ├── tbl_profitability_analysis.xltx
│   │   └── tbl_risk_assessment.xltx
│   ├── dashboard/                                                  # Dashboard template
│   │   └── dashboard_state_bank.xltx
│   ├── charts/                                                     # Chart templates
│   │   ├── viz_capital_adequacy.crtx
│   │   └── viz_risk_assessment.crtx                                   
│   └── palette.md                                                  # Color palette and typography
│
├── screenshots/                                                    # Screenshots
│   ├── project_info.png
│   ├── dashboard_overview.png
│   ├── financial_perfomance.png
│   ├── profitability_analysis.png
│   ├── risk_assessment.png
│   ├── capital_adequacy.png
│   └── shock_simulator.png
│
├── vba_code/                                                       # VBA modules
│   └── mod_Shock_Simulator.bas
│
├── sql/                                                            # SQL schema and queries
│   ├── insert_data.sql
│   ├── queries.sql
│   └── schema.sql
│
├── visualizations/                                                 # Exported visuals
│   ├── tables/                                                     # Exported tables
│   │   ├── tbl_capital_adequacy.png
│   │   ├── tbl_financial_performance.png
│   │   ├── tbl_profitability_analysis.png
│   │   └── tbl_risk_assessment.png
│   ├── dashboard/                                                  # Exported dashboard
│   │   └── dashboard_state_bank.png
│   └── charts/                                                     # Exported charts
│       ├── viz_capital_adequacy.png
│       └── viz_risk_assessment.png                                   
│   
├── assets/                                                          # Branding assets
│   ├── banner/                                                      # Banner image
│   │   └── banner.png
│   └── logo/                                                        # Logo files
│       └── logo.png
│
├── reports/                                                         # Exported reports
│   ├── .pdf/                                                        # PDF export
│   │   └── bank_financials_dashboard_overview_2015_2024_report.pdf
│   └── .htm/                                                        # HTML export
│       └── bank_financials_dashboard_overview_2015_2024_report.htm
│
├── README.md                                                        # Project overview
├── DISCLAIMER.md                                                    # Legal disclaimer
├── LICENSE                                                          # Project license 
├── NOTICE                                                           # Data provenance
├── CHANGELOG.md                                                     # Version history
├── .gitignore                                                       # Git ignore rules
└── .gitattributes                                                   # Git attributes
