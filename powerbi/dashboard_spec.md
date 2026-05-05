# Brazil Commerce Pulse — Dashboard Spec

Canvas: 1280x720px · Tema: theme_olist.json · Fondos: bg_page*.png

---

## Medidas DAX globales (tabla orders_features)

```dax
Total Revenue      = ROUND(SUM(orders_features[revenue]), 0)
Total Orders       = DISTINCTCOUNT(orders_features[order_id])
Avg Order Value    = DIVIDE([Total Revenue], [Total Orders])
Avg Review Score   = ROUND(AVERAGE(orders_features[review_score]), 1)
Avg Delivery Days  = ROUND(AVERAGE(orders_features[delivery_days]), 1)
Median Delivery Days = ROUND(PERCENTILEINC(orders_features[delivery_days], 0.5), 1)
Pct Late Orders    = ROUND(DIVIDE(SUM(orders_features[is_late]), COUNT(orders_features[order_id])) * 100, 1)
Total Delivered    = DISTINCTCOUNT(orders_features[order_id])
Total Customers    = DISTINCTCOUNT(orders_features[customer_unique_id])
Active Sellers     = DISTINCTCOUNT(orders_features[seller_id])
```

---

## Columna calculada (orders_features)

```dax
Delivery Status = IF(orders_features[is_late] = 1, "Late", "On Time")
```

---

## Página 1 — Sales & Revenue

### KPI Cards
| Card | Medida | Formato |
|------|--------|---------|
| Total Revenue | `[Total Revenue]` | R$ #,##0 |
| Total Orders | `[Total Orders]` | #,##0 |
| Avg Order Value | `[Avg Order Value]` | R$ #,##0.00 |
| Avg Review Score | `[Avg Review Score]` | #,##0.0 |

### Visual 1 — Revenue by Month (2016–2018)
- Tipo: Gráfico de líneas
- Eje X: `purchase_year_month` (agg_monthly) — ordenar por columna: sí mismo, ascendente
- Eje Y: `revenue` (Suma)
- Título: desactivar (está en el fondo)

### Visual 2 — Top 10 Product Categories by Revenue
- Tipo: Gráfico de barras horizontal
- Eje Y: `product_category_name_english` (agg_category)
- Eje X: `revenue` (Suma)
- Ordenar: revenue DESC · Máx categorías: 10
- Título: desactivar

### Visual 3 — Which Brazilian States Buy the Most?
- Tipo: Gráfico de barras horizontal
- Eje Y: `customer_state` (agg_state)
- Eje X: `revenue` (Suma)
- Ordenar: revenue DESC
- Título: desactivar

### Visual 4 — How Do Customers Prefer to Pay?
- Tipo: Gráfico de anillos (Donut)
- Leyenda: `payment_type` (agg_payment) — renombrar en Power Query
- Valores: `orders` (Suma)
- Título: desactivar

---

## Página 2 — Operations & Delivery

### KPI Cards
| Card | Medida | Formato |
|------|--------|---------|
| Avg Delivery Days | `[Avg Delivery Days]` | #,##0.0 |
| Median Delivery Days | `[Median Delivery Days]` | #,##0.0 |
| % Late Orders | `[Pct Late Orders]` | #,##0.0"%" |
| Total Delivered | `[Total Delivered]` | #,##0 |

### Visual 1 — Average Delivery Time by State
- Tipo: Gráfico de barras horizontal
- Eje Y: `seller_state` (agg_delivery)
- Eje X: `avg_delivery_days` (Promedio)
- Ordenar: avg_delivery_days DESC
- Título: desactivar

### Visual 2 — On-Time vs. Late Deliveries
- Tipo: Gráfico de anillos (Donut)
- Leyenda: `Delivery Status` (columna calculada en orders_features)
- Valores: `order_id` (Recuento distinto)
- Colores: On Time = #00C4B4 · Late = #FF8C42
- Título: desactivar

### Visual 3 — Delivery Performance Across Brazil
- Tipo: Gráfico de barras horizontal
- Eje Y: `customer_state` (agg_state)
- Eje X: `avg_delivery_days`
- Color condicional: verde (bajo) → rojo (alto) según pct_late
- Título: desactivar

### Visual 4 — Monthly Late Order Rate
- Tipo: Gráfico de líneas
- Eje X: `purchase_year_month` (agg_monthly) — ordenar ascendente
- Eje Y: `[Pct Late Orders]` desde orders_features
- Título: desactivar

---

## Página 3 — Customers & Sellers

### KPI Cards
| Card | Medida | Formato |
|------|--------|---------|
| Total Customers | `[Total Customers]` | #,##0 |
| Active Sellers | `[Active Sellers]` | #,##0 |
| Top Seller Revenue | `MAXX(agg_sellers, agg_sellers[revenue])` | R$ #,##0 |
| Avg Satisfaction | `[Avg Review Score]` | #,##0.0 |

### Visual 1 — Where Are Our Customers?
- Tipo: Gráfico de barras horizontal
- Eje Y: `customer_state` (agg_state)
- Eje X: `customers`
- Ordenar: customers DESC
- Título: desactivar

### Visual 2 — Avg Review Score by Product Category
- Tipo: Gráfico de barras horizontal
- Eje Y: `product_category_name_english` (agg_category)
- Eje X: `avg_review`
- Ordenar: avg_review DESC · Máx categorías: 15
- Título: desactivar

### Visual 3 — Top 20 Sellers by Revenue
- Tipo: Gráfico de barras horizontal
- Eje Y: `seller_id` (agg_sellers)
- Eje X: `revenue`
- Ordenar: revenue DESC · Máx categorías: 20
- Título: desactivar

### Visual 4 — Active Sellers by State
- Tipo: Gráfico de barras horizontal
- Eje Y: `seller_state` (agg_sellers)
- Eje X: COUNT de seller_id
- Ordenar: COUNT DESC
- Título: desactivar

---

## Configuración común a todos los visuales

- **Fondo del visual**: desactivar (transparente)
- **Título**: desactivar (los títulos están en el fondo)
- **Borde**: desactivar
- **Sombra**: desactivar
- **Colores de ejes**: `#7A9BB5` (MUTED)
- **Colores de datos**: primer color = accent de la página

## Slicers (header, todas las páginas)
- **Year**: `purchase_year` · Tipo: Lista desplegable · X=732, Y=11, W=229, H=75
- **State**: `customer_state` · Tipo: Lista desplegable · X=968, Y=11, W=229, H=75
- Fuente: tabla `orders_features`
