# Imports

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
from matplotlib.ticker import PercentFormatter
from pandas import IndexSlice as idx
from IPython.display import display

# Load data

PATH = r"..\data_clean\bank_financials_clean_overview_2015_2024.xlsx"
df = pd.read_excel(PATH, header=0, decimal=",", thousands=".", engine="openpyxl")
df = df.rename(columns={df.columns[0]: "Metric"})
years = [c for c in df.columns if c != "Metric"]

# Return one metric as series

def get_metric(name: str):
    row = df[df["Metric"].astype(str).str.strip().str.lower() == name.lower()]
    if row.empty:
        return None
    s = row.iloc[0, 1:].astype(float)
    s.index = years
    return s

# Build KPIs

ta   = get_metric("Total assets")
ni   = get_metric("Net income")
cet1 = get_metric("CET1 ratio")
cir  = get_metric("Cost-Income-Ratio")
roa  = get_metric("Return on assets")


if roa is None and (ni is not None and ta is not None):
    roa = ni / ta

def mean_or_nan(s): return float(np.nan if s is None else s.mean())
def std_or_nan(s):  return float(np.nan if s is None else s.std(ddof=0))
def med_or_nan(s):  return float(np.nan if s is None else s.median())

kpis = {
    "Average ROA": mean_or_nan(roa),
    "ROA Std. Deviation": std_or_nan(roa),
    "Median Cost–Income Ratio": med_or_nan(cir),
    "Average CET1": mean_or_nan(cet1),
    "Average Total Assets (EUR mn)": mean_or_nan(ta),
    "Highest Net Income (value, year)": (
        float(np.nan) if ni is None else float(ni.max()),
        None if ni is None else int(ni.idxmax()),
    ),
}

# Visual theme

PALETTE = {
    "page_bg": "#F4F1EC",
    "card_bg": "#FFFFFF",
    "card_border": "#E3DED4",
    "text": "#0F1F2A",
    "muted": "#3B4A54",
    "header_teal": "#0B7A75",
    "grid": "#EAE6DE",
    "cet1": "#F6C000",
    "total_cap": "#1D5B52",
    "bars": "#0B7A75",
    "threshold": "#E07B39",
}
plt.rcParams.update({
    "figure.facecolor": PALETTE["page_bg"],
    "axes.facecolor": PALETTE["card_bg"],
    "axes.edgecolor": PALETTE["card_bg"],
    "axes.labelcolor": PALETTE["text"],
    "text.color": PALETTE["text"],
    "xtick.color": PALETTE["muted"],
    "ytick.color": PALETTE["muted"],
    "grid.color": PALETTE["grid"],
    "savefig.facecolor": PALETTE["page_bg"],
})

# Numeric formatting

def fmt_eu(x):
    if pd.isna(x): return ""
    return f"{x:,.2f}".replace(",", " ").replace(".", ",")
def fmt_pct(x):
    if pd.isna(x): return ""
    return f"{x:.2%}".replace(".", ",")

# KPI summary tiles

def draw_kpi_grid(k):
    titles = [
        "Average ROA",
        "ROA Std. Deviation",
        "Median Cost–Income Ratio",
        "Average CET1",
        "Average Total Assets",
        "Highest Net Income",
    ]
    values = [
        fmt_pct(k["Average ROA"]),
        fmt_pct(k["ROA Std. Deviation"]),
        fmt_pct(k["Median Cost–Income Ratio"]),
        fmt_pct(k["Average CET1"]),
        fmt_eu(k["Average Total Assets (EUR mn)"]) + " EUR mn",
        (fmt_eu(k["Highest Net Income (value, year)"][0]) + " EUR m"
         + ("" if k["Highest Net Income (value, year)"][1] is None else f"\n({k['Highest Net Income (value, year)'][1]})")),
    ]
    fig, axes = plt.subplots(2, 3, figsize=(13.2, 4.8))
    for ax, t, v in zip(axes.ravel(), titles, values):
        ax.axis("off")
        card = FancyBboxPatch(
            (0, 0), 1, 1,
            boxstyle="round,pad=0.02,rounding_size=14",
            linewidth=1.0,
            edgecolor=PALETTE["card_border"],
            facecolor=PALETTE["card_bg"],
        )
        ax.add_patch(card)
        ax.text(0.5, 0.74, t, ha="center", va="center", fontsize=11, color=PALETTE["muted"])
        ax.text(0.5, 0.36, v, ha="center", va="center", fontsize=18, fontweight="bold", color=PALETTE["text"])
        ax.set_xlim(0, 1); ax.set_ylim(0, 1)
    plt.tight_layout(); plt.show()

draw_kpi_grid(kpis)

# Build table

tbl = df.set_index("Metric").copy()
tbl.index.name = None
tbl.columns.name = None

# Mark rows that are percentages

ratio_rows_all = {
    "CET1 ratio","Total capital ratio","Return on equity",
    "Return on assets","Cost-Income-Ratio","Leverage Ratio"
}
available = set(tbl.index.astype(str))
ratio_rows = list(ratio_rows_all & available)
abs_rows   = list(available - set(ratio_rows))

# Style table

styler = (
    tbl.style
    .format(fmt_pct, subset=idx[ratio_rows, years])
    .format(fmt_eu,  subset=idx[abs_rows,   years])
    .set_table_styles([
        {"selector":"", "props":[
            ("background-color", PALETTE["card_bg"]),
            ("color", PALETTE["text"]),
            ("border","1px solid " + PALETTE["card_border"]),
        ]},
        {"selector":"th.col_heading", "props":[
            ("background", PALETTE["header_teal"]),
            ("color","#FFFFFF"),
            ("font-weight","600"),
            ("padding","8px 10px"),
            ("border-bottom","1px solid " + PALETTE["card_border"]),
        ]},
        {"selector":"th.row_heading", "props":[
            ("background", PALETTE["card_bg"]),
            ("color", PALETTE["text"]),
            ("font-weight","600"),
            ("padding","8px 12px"),
            ("border-right","1px solid " + PALETTE["card_border"]),
        ]},
        {"selector":"td", "props":[
            ("background", PALETTE["card_bg"]),
            ("color", PALETTE["text"]),
            ("padding","8px 12px"),
            ("border-bottom","1px solid #F0F0F0"),
        ]},
    ])
)
display(styler)

# Plot charts

def plot_dashboard_charts():
    
    # CET1 vs Total Capital
    
    plt.figure(figsize=(8.9, 4.2))
    for metric, color in [("CET1 ratio", PALETTE["cet1"]), ("Total capital ratio", PALETTE["total_cap"])]:
        y = get_metric(metric)
        if y is None: continue
        plt.plot(y.index, y.astype(float).values, marker="o", linewidth=2.4, label=metric, color=color)
    plt.title("Consistent Growth in CET1 vs Total Capital Ratio (2015–2024)", fontweight="bold")
    plt.xlabel("Year"); plt.ylabel("Capital Ratios (%)")
    plt.gca().yaxis.set_major_formatter(PercentFormatter(1.0))
    plt.ylim(0, 0.30); plt.grid(axis="y", alpha=0.35)
    plt.legend(loc="upper center", bbox_to_anchor=(0.5, -0.18), ncol=2, frameon=False)
    plt.tight_layout(); plt.show()

    # Cost–Income Ratio vs Threshold
    
    threshold = 0.60
    y = get_metric("Cost-Income-Ratio")
    if y is not None:
        y = y.astype(float)
        plt.figure(figsize=(8.9, 4.2))
        plt.bar(y.index, y.values, color=PALETTE["bars"], label="Cost-Income-Ratio")
        plt.axhline(threshold, color=PALETTE["threshold"], linewidth=2.0, label="Risk Threshold")
        plt.title("Cost-Income Ratio and Risk Threshold Analysis", fontweight="bold")
        plt.xlabel("Year"); plt.ylabel("Risk Threshold")
        plt.gca().yaxis.set_major_formatter(PercentFormatter(1.0))
        plt.ylim(0, 0.70); plt.grid(axis="y", alpha=0.35)
        plt.legend(loc="upper center", bbox_to_anchor=(0.5, -0.18), ncol=2, frameon=False)
        plt.tight_layout(); plt.show()

plot_dashboard_charts()