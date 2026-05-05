"""
Genera los fondos PNG para el dashboard de Power BI.
Ejecutar desde la raíz del proyecto: python powerbi/generate_backgrounds.py
3 páginas: Sales, Operations, Customers & Sellers
Canvas: 1280x720px (16:9)
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import os

os.makedirs('powerbi', exist_ok=True)

# Paleta
BG      = "#0B1929"
HEADER  = "#0F2336"
SURFACE = "#162D43"
TEAL    = "#00C4B4"
ORANGE  = "#FF8C42"
GREEN   = "#3DDB96"
TEXT    = "#F0F4F8"
MUTED   = "#7A9BB5"

W, H = 12.8, 7.2  # 1280x720px a 100 DPI

# Layout constants
PAD     = 0.20
GAP     = 0.15

# KPI zone
KPI_Y_BOT = H - 1.84
KPI_Y_TOP = H - 0.92
CARD_H    = (KPI_Y_TOP - KPI_Y_BOT) - 0.14
CARD_Y    = KPI_Y_BOT + 0.07
CARD_W    = (W - 2*PAD - 3*GAP) / 4

# Chart area
CHART_TOP = KPI_Y_BOT - 0.16
CHART_BOT = 0.38
ROW_H     = (CHART_TOP - CHART_BOT - GAP) / 2
ROW1_Y    = CHART_TOP - ROW_H
ROW2_Y    = CHART_BOT

# Chart widths
W_FULL       = W - 2*PAD
W_2_3        = 8.10
W_1_3        = W_FULL - W_2_3 - GAP
W_HALF       = (W_FULL - GAP) / 2
X_RIGHT_2_3  = PAD + W_2_3 + GAP
X_RIGHT_HALF = PAD + W_HALF + GAP


def card_zone(ax, x, y, w, h, label, accent):
    """Card KPI: borde sólido + título en esquina superior izquierda."""
    ax.add_patch(patches.Rectangle(
        (x, y), w, h,
        linewidth=0.7, edgecolor=accent,
        facecolor=SURFACE, alpha=0.30,
        zorder=3
    ))
    ax.text(x + 0.13, y + h - 0.15, label.upper(),
            color=accent, fontsize=7.5, fontweight='bold', alpha=0.80,
            va='center', ha='left', zorder=4)


def placeholder(ax, x, y, w, h, label, color):
    """Chart zone: borde sólido sutil + título en esquina superior izquierda."""
    ax.add_patch(patches.Rectangle(
        (x, y), w, h,
        linewidth=0.6, edgecolor=color,
        facecolor=SURFACE, alpha=0.25,
        zorder=3
    ))
    ax.text(x + 0.15, y + h - 0.22, label.upper(),
            color=color, fontsize=8.5, fontweight='bold', alpha=0.80,
            va='center', ha='left', zorder=4)


pages = [
    {
        "title": "Sales & Revenue",
        "accent": TEAL,
        "icon": "sales",
        "cards": [
            {"label": "Total Revenue"},
            {"label": "Total Orders"},
            {"label": "Avg Order Value"},
            {"label": "Avg Review Score"},
        ],
        "row1": [
            {"label": "Revenue by Month (2016–2018)",          "x": PAD,          "w": W_2_3},
            {"label": "Top 10 Product Categories by Revenue",  "x": X_RIGHT_2_3,  "w": W_1_3},
        ],
        "row2": [
            {"label": "Which Brazilian States Buy the Most?",  "x": PAD,          "w": W_HALF},
            {"label": "How Do Customers Prefer to Pay?",       "x": X_RIGHT_HALF, "w": W_HALF},
        ],
    },
    {
        "title": "Operations & Delivery",
        "accent": ORANGE,
        "icon": "operations",
        "cards": [
            {"label": "Avg Delivery Days"},
            {"label": "Median Delivery Days"},
            {"label": "% Late Orders"},
            {"label": "Total Delivered"},
        ],
        "row1": [
            {"label": "Average Delivery Time by State",        "x": PAD,          "w": W_2_3},
            {"label": "On-Time vs. Late Deliveries",           "x": X_RIGHT_2_3,  "w": W_1_3},
        ],
        "row2": [
            {"label": "Delivery Performance Across Brazil",    "x": PAD,          "w": W_HALF},
            {"label": "Monthly Late Order Rate",               "x": X_RIGHT_HALF, "w": W_HALF},
        ],
    },
    {
        "title": "Customers & Sellers",
        "accent": GREEN,
        "icon": "customers",
        "cards": [
            {"label": "Total Customers"},
            {"label": "Active Sellers"},
            {"label": "Top Seller Revenue"},
            {"label": "Avg Satisfaction"},
        ],
        "row1": [
            {"label": "Where Are Our Customers?",              "x": PAD,          "w": W_HALF},
            {"label": "Avg Review Score by Product Category",  "x": X_RIGHT_HALF, "w": W_HALF},
        ],
        "row2": [
            {"label": "Top 20 Sellers by Revenue",             "x": PAD,          "w": W_2_3},
            {"label": "Active Sellers by State",               "x": X_RIGHT_2_3,  "w": W_1_3},
        ],
    },
]

for page_num, page in enumerate(pages, 1):
    fig, ax = plt.subplots(figsize=(W, H), dpi=100)
    fig.patch.set_facecolor(BG)
    fig.subplots_adjust(left=0, right=1, top=1, bottom=0)
    ax.set_xlim(0, W)
    ax.set_ylim(0, H)
    ax.axis('off')

    # Subtle dot grid
    for gx in [gi * 0.45 for gi in range(1, 29)]:
        for gy in [gj * 0.45 for gj in range(1, 17)]:
            if gy < H - 0.88 and gy > 0.32:
                ax.plot(gx, gy, '.', color=MUTED, markersize=0.8, alpha=0.2, zorder=0)

    # Header bar
    ax.add_patch(patches.FancyBboxPatch(
        (0, H - 0.80), W, 0.80,
        boxstyle="square,pad=0",
        facecolor=HEADER, edgecolor='none', zorder=1
    ))

    # Accent line
    ax.add_patch(patches.Rectangle(
        (0, H - 0.84), W, 0.04,
        facecolor=page['accent'], edgecolor='none', zorder=2
    ))

    # OLIST + subtítulo
    ax.text(0.27, H - 0.34, "OLIST",
            color=page['accent'], fontsize=16, fontweight='bold',
            va='center', ha='left', zorder=3)
    ax.text(0.27, H - 0.58, "Brazil Commerce Pulse",
            color=MUTED, fontsize=8,
            va='center', ha='left', zorder=3)

    # Título de página
    ax.text(3.0, H - 0.40, page['title'].upper(),
            color=TEXT, fontsize=14, fontweight='bold',
            va='center', ha='left', zorder=3)

    # Separador vertical (zona slicers)
    ax.add_patch(patches.Rectangle(
        (7.30, H - 0.68), 0.02, 0.56,
        facecolor=MUTED, edgecolor='none', alpha=0.3, zorder=2
    ))

    # KPI zone background
    ax.add_patch(patches.Rectangle(
        (0, KPI_Y_BOT), W, KPI_Y_TOP - KPI_Y_BOT,
        facecolor=SURFACE, edgecolor='none', alpha=0.5, zorder=1
    ))

    # KPI card zones (borde + título en esquina)
    for j, card in enumerate(page['cards']):
        cx = PAD + j * (CARD_W + GAP)
        card_zone(ax, cx, CARD_Y, CARD_W, CARD_H, card['label'], page['accent'])

    # Footer bar
    ax.add_patch(patches.Rectangle(
        (0, 0), W, 0.28,
        facecolor=HEADER, edgecolor='none', zorder=1
    ))
    ax.text(W / 2, 0.14, "Brazilian E-Commerce Public Dataset by Olist  |  2016 – 2018",
            color=MUTED, fontsize=7,
            va='center', ha='center', zorder=2)

    # Chart zones — Row 1
    for chart in page['row1']:
        placeholder(ax, chart['x'], ROW1_Y, chart['w'], ROW_H, chart['label'], MUTED)

    # Chart zones — Row 2
    for chart in page['row2']:
        placeholder(ax, chart['x'], ROW2_Y, chart['w'], ROW_H, chart['label'], MUTED)

    fname = f"powerbi/bg_page{page_num}_{page['icon']}.png"
    plt.savefig(fname, dpi=100, bbox_inches=None, pad_inches=0, facecolor=BG)
    plt.close()
    print(f"OK {fname}")

print("Fondos generados en powerbi/")
