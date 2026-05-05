-- =============================================================
-- Olist E-Commerce — Business Analysis Queries
-- Ejecutar después de schema.sql y carga de datos
-- =============================================================

USE olist_db;

-- =============================================================
-- VENTAS
-- =============================================================

-- VW-01: Revenue mensual con crecimiento MoM
CREATE OR REPLACE VIEW vw_monthly_revenue AS
SELECT
    purchase_year_month,
    purchase_year,
    purchase_month,
    purchase_month_name,
    month_order,
    revenue,
    orders,
    avg_ticket,
    LAG(revenue) OVER (ORDER BY purchase_year_month)               AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY purchase_year_month))
        / LAG(revenue) OVER (ORDER BY purchase_year_month) * 100, 1
    )                                                               AS revenue_growth_pct
FROM agg_monthly
ORDER BY purchase_year_month;

-- VW-02: Top categorías por revenue con % del total
CREATE OR REPLACE VIEW vw_category_revenue AS
SELECT
    product_category_name_english                                   AS category,
    revenue,
    orders,
    items,
    avg_price,
    avg_review,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2)                 AS pct_of_total_revenue,
    RANK() OVER (ORDER BY revenue DESC)                            AS revenue_rank
FROM agg_category
ORDER BY revenue DESC;

-- VW-03: Revenue y clientes por estado
CREATE OR REPLACE VIEW vw_state_performance AS
SELECT
    customer_state                                                  AS state,
    revenue,
    orders,
    customers,
    ROUND(revenue / orders, 2)                                     AS avg_order_value,
    avg_delivery_days,
    ROUND(pct_late * 100, 1)                                       AS pct_late,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2)                AS pct_of_total_revenue,
    RANK() OVER (ORDER BY revenue DESC)                           AS revenue_rank
FROM agg_state
ORDER BY revenue DESC;

-- =============================================================
-- OPERACIONES
-- =============================================================

-- VW-04: Performance de entrega por estado del cliente
CREATE OR REPLACE VIEW vw_delivery_performance AS
SELECT
    customer_state                                                  AS state,
    orders,
    ROUND(avg_delivery_days, 1)                                    AS avg_delivery_days,
    ROUND(pct_late * 100, 1)                                       AS pct_late,
    CASE
        WHEN pct_late >= 0.15 THEN 'Critical'
        WHEN pct_late >= 0.10 THEN 'Warning'
        ELSE 'OK'
    END                                                             AS delivery_status
FROM agg_state
ORDER BY pct_late DESC;

-- VW-05: KPIs operacionales generales (1 fila)
CREATE OR REPLACE VIEW vw_operations_kpis AS
SELECT
    ROUND(AVG(delivery_days), 1)                                   AS avg_delivery_days,
    ROUND(MEDIAN_APPROX, 0)                                        AS median_delivery_days,
    ROUND(SUM(is_late) / COUNT(*) * 100, 1)                       AS pct_late,
    COUNT(DISTINCT order_id)                                       AS total_delivered_orders,
    SUM(is_late)                                                   AS total_late_orders
FROM (
    SELECT delivery_days, is_late, order_id,
           PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY delivery_days)
               OVER () AS MEDIAN_APPROX
    FROM orders_features
) t;

-- =============================================================
-- CLIENTES
-- =============================================================

-- VW-06: Ticket promedio y satisfacción por estado
CREATE OR REPLACE VIEW vw_customer_metrics AS
SELECT
    customer_state                                                  AS state,
    customers,
    orders,
    ROUND(revenue / orders, 2)                                     AS avg_order_value,
    ROUND(avg_delivery_days, 1)                                    AS avg_delivery_days,
    ROUND(pct_late * 100, 1)                                       AS pct_late
FROM agg_state
ORDER BY customers DESC;

-- VW-07: Categorías con mejores y peores reviews
CREATE OR REPLACE VIEW vw_category_satisfaction AS
SELECT
    product_category_name_english                                   AS category,
    orders,
    avg_review,
    avg_price,
    revenue,
    RANK() OVER (ORDER BY avg_review DESC)                        AS satisfaction_rank,
    CASE
        WHEN avg_review >= 4.3 THEN 'High'
        WHEN avg_review >= 3.8 THEN 'Medium'
        ELSE 'Low'
    END                                                             AS satisfaction_tier
FROM agg_category
WHERE orders >= 100
ORDER BY avg_review DESC;

-- =============================================================
-- VENDEDORES
-- =============================================================

-- VW-08: Top sellers con métricas de performance
CREATE OR REPLACE VIEW vw_seller_performance AS
SELECT
    seller_id,
    seller_state,
    seller_city,
    revenue,
    orders,
    items,
    ROUND(avg_price, 2)                                            AS avg_price,
    ROUND(avg_review, 2)                                           AS avg_review,
    ROUND(revenue / SUM(revenue) OVER () * 100, 3)                AS pct_of_total_revenue,
    RANK() OVER (ORDER BY revenue DESC)                           AS revenue_rank
FROM agg_sellers
ORDER BY revenue DESC;

-- VW-09: Distribución de sellers por estado
CREATE OR REPLACE VIEW vw_seller_by_state AS
SELECT
    seller_state                                                   AS state,
    COUNT(*)                                                       AS sellers,
    ROUND(SUM(revenue), 0)                                        AS total_revenue,
    ROUND(AVG(revenue), 0)                                        AS avg_revenue_per_seller,
    ROUND(SUM(orders), 0)                                         AS total_orders
FROM agg_sellers
GROUP BY seller_state
ORDER BY total_revenue DESC;

-- =============================================================
-- PAGOS
-- =============================================================

-- VW-10: Métodos de pago
CREATE OR REPLACE VIEW vw_payment_methods AS
SELECT
    payment_type,
    orders,
    ROUND(revenue, 0)                                              AS revenue,
    ROUND(avg_installments, 1)                                     AS avg_installments,
    ROUND(orders / SUM(orders) OVER () * 100, 1)                  AS pct_orders,
    ROUND(revenue / SUM(revenue) OVER () * 100, 1)                AS pct_revenue
FROM agg_payment
ORDER BY orders DESC;

-- =============================================================
-- QUERIES DE VALIDACIÓN
-- =============================================================

-- Verificar revenue total
SELECT ROUND(SUM(revenue), 0) AS total_revenue FROM orders_features;

-- Verificar órdenes únicas
SELECT COUNT(DISTINCT order_id) AS total_orders FROM orders_features;

-- Verificar rango de fechas
SELECT
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS last_order
FROM orders_features;
